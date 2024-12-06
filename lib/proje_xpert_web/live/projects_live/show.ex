defmodule ProjeXpertWeb.ProjectsLive.Show do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Accounts
  alias ProjeXpert.Chats.Channel
  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.{Column, Sprint, Task}
  alias ProjeXpertWeb.ProjectsLive.Components

  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(ProjeXpert.PubSub, "project:#{id}")
    {:ok, socket}
  end

  def handle_params(%{"id" => id} = params, _url, socket) do
    project = Tasks.get_project!(id)

    selected_sprint =
      Enum.find(project.sprints, fn sprint ->
        sprint.start_date >= Date.utc_today() and sprint.start_date <= Date.utc_today()
      end) || Enum.at(project.sprints, 0)

    dbg(selected_sprint)
    {:noreply,
     socket
     |> assign(
       project: project,
       columns: Enum.map(Tasks.sprint_columns(selected_sprint.id), &{&1.name, &1.id}),
       sprint_options: get_sprints(project),
       selected_sprint: selected_sprint,
       kanban_board: true
     )
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(
      page_title: "Project Detail"
    )
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(
      page_title: "Edit Project"
    )
  end

  defp apply_action(socket, :new_column, _params) do
    socket
    |> assign(
      page_title: "New Column",
      column: %Column{}
    )
  end

  defp apply_action(socket, :edit_column, %{"column_id" => column_id} = _params) do
    socket
    |> assign(
      page_title: "Edit Column",
      column: Tasks.get_column!(column_id)
    )
  end

  defp apply_action(socket, :new_sprint, _params) do
    socket
    |> assign(
      page_title: "New sprint",
      sprint: %Sprint{},
      column: %Column{}
    )
  end

  defp apply_action(socket, :edit_sprint, %{"sprint_id" => id} = _params) do
    socket
    |> assign(
      page_title: "Edit Sprint",
      sprint: Tasks.get_sprint!(id),
      column: %Column{}
    )
  end

  defp apply_action(socket, :new_task, _params) do
    socket
    |> assign(
      page_title: "New Task",
      task: %Task{},
      column: %Column{}
    )
  end

  defp apply_action(socket, :edit_task, %{"task_id" => task_id} = _params) do
    socket
    |> assign(
      page_title: "Edit Task",
      task: Tasks.get_task!(task_id),
      column: %Column{}
    )
  end

  defp apply_action(socket, :show_task, %{"task_id" => task_id} = _params) do
    socket
    |> assign(
      page_title: "Task Details",
      task: Tasks.get_task!(task_id),
      column: %Column{}
    )
  end

  defp apply_action(socket, :new_channel, _params) do
    socket
    |> assign(
      page_title: "New Channel",
      channel: %Channel{}
    )
  end

  def handle_event("kanban_board", _params, socket) do
    {:noreply, assign(socket, kanban_board: !socket.assigns.kanban_board)}
  end

  def handle_event("select_sprint", %{"select_sprint" => %{"sprint_id" => id}}, socket) do
    selected_sprint = Tasks.get_sprint!(id)

    {:noreply,
     assign(socket,
       selected_sprint: selected_sprint,
       columns: Enum.map(Tasks.sprint_columns(selected_sprint.id), &{&1.name, &1.id})
     )}
  end

  def handle_event("complete_sprint", %{"id" => id}, socket) do
    with %Sprint{} = sprint <- Tasks.get_sprint!(id),
         {:ok, _} <- Tasks.update_sprint(sprint, %{"status" => :completed}),
         :ok <- sprint_complete_notification(sprint, socket.assigns.project) do
      Phoenix.PubSub.broadcast!(
        ProjeXpert.PubSub,
        "project:#{socket.assigns.project.id}",
        {:column_deleted, socket.assigns.project.id}
      )

      send(self(), {:notification, socket.assigns.project.client_id, "notification"})

      {:noreply,
       socket
       |> put_flash(
         :info,
         "\"#{sprint.title}\" has been completed successfully"
       )
       |> push_patch(to: ~p"/projects/#{socket.assigns.project.id}/show")}
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong while completing sprint")
         |> push_patch(to: ~p"/projects/#{socket.assigns.project.id}/show")}
    end
  end

  def handle_event("ask_for_payment", %{"id" => task_id}, socket) do
    with %Task{} = task <- Tasks.get_task!(task_id),
         {:ok, _} <- Tasks.update_task(task, %{"ask_for_payment" => true}),
         {:ok, notification} <- ask_payment_notification(task, socket.assigns.project) do
      Phoenix.PubSub.broadcast!(
        ProjeXpert.PubSub,
        "project:#{socket.assigns.project.id}",
        {:column_deleted, socket.assigns.project.id}
      )

      send(self(), {:notification, socket.assigns.project.client_id, notification})

      {:noreply,
       socket
       |> put_flash(
         :info,
         "Sent notification to #{full_name(socket.assigns.project.client)} for the task \"#{task.title}\" "
       )
       |> push_patch(to: ~p"/projects/#{socket.assigns.project.id}/show")}
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong while asking for the payment")
         |> push_patch(to: ~p"/projects/#{socket.assigns.project.id}/show")}
    end
  end

  def handle_event("delete_column", %{"id" => column_id}, socket) do
    with %Column{} = column <- Tasks.get_column!(column_id),
         {:ok, _} <- Tasks.delete_column(column) do
      Phoenix.PubSub.broadcast!(
        ProjeXpert.PubSub,
        "project:#{socket.assigns.project.id}",
        {:column_deleted, socket.assigns.project.id}
      )

      {:noreply,
       socket
       |> put_flash(:info, "Column: \"#{column.name}\" deleted successfully")
       |> push_patch(to: ~p"/projects/#{socket.assigns.project.id}/show")}
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong while deleting the Task")
         |> push_patch(to: ~p"/projects/#{socket.assigns.project.id}/show")}
    end
  end

  def handle_event("delete_task", %{"id" => task_id}, socket) do
    with %Task{} = task <- Tasks.get_task!(task_id),
         {:ok, _} <- Tasks.delete_task(task) do
      Phoenix.PubSub.broadcast!(
        ProjeXpert.PubSub,
        "project:#{socket.assigns.project.id}",
        {:task_deleted, socket.assigns.project.id}
      )

      {:noreply,
       socket
       |> put_flash(:info, "Task: \"#{task.title}\" deleted successfully")
       |> push_patch(to: ~p"/projects/#{socket.assigns.project.id}/show")}
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong while deleting the Task")
         |> push_patch(to: ~p"/projects/#{socket.assigns.project.id}/show")}
    end
  end

  def handle_event("drag-drop", params, socket) do
    if params["dropzoneId"] != params["fromdropzoneId"] do
      send(self(), {:drag_drop, params})
    end

    {:noreply, socket}
  end

  def handle_info({:drag_drop, params}, socket) do
    with %Task{} = task <- Tasks.get_task!(params["draggedId"]),
         {:ok, task} <- Tasks.update_task(task, %{"column_id" => params["dropzoneId"]}),
         task <- get_preload(task, :column) do
      if task.column.name == "Completed" do
        Tasks.update_task(task, %{"is_completed?" => true})
      else
        Tasks.update_task(task, %{"is_completed?" => false})
      end

      Phoenix.PubSub.broadcast!(
        ProjeXpert.PubSub,
        "project:#{socket.assigns.project.id}",
        {:task_moved, socket.assigns.project.id}
      )

      {:noreply, push_patch(socket, to: ~p"/projects/#{socket.assigns.project.id}/show")}
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong while moving to column")
         |> push_patch(to: ~p"/projects/#{socket.assigns.project.id}/show")}
    end
  end

  def handle_info({:project_update, project_id}, socket) do
    {:noreply, assign(socket, project: Tasks.get_project!(project_id))}
  end

  def handle_info({:task_moved, project_id}, socket) do
    {:noreply, assign(socket, project: Tasks.get_project!(project_id))}
  end

  def handle_info({:task_deleted, project_id}, socket) do
    {:noreply, assign(socket, project: Tasks.get_project!(project_id))}
  end

  def handle_info({:column_deleted, project_id}, socket) do
    {:noreply, assign(socket, project: Tasks.get_project!(project_id))}
  end

  def handle_info({:task, project_id}, socket) do
    {:noreply, assign(socket, project: Tasks.get_project!(project_id))}
  end

  def handle_info({:column, project_id}, socket) do
    {:noreply, assign(socket, project: Tasks.get_project!(project_id))}
  end

  def handle_info({:sprint, project_id}, socket) do
    {:noreply, assign(socket, project: Tasks.get_project!(project_id))}
  end

  def handle_info({:return_to_home, project}, socket) do
    {:noreply,
     push_patch(socket, to: ~p"/projects/#{project.id}/show")
     |> put_flash(
       :error,
       "You can't perform this action as this project has been #{camel_case_string(project.status)}"
     )}
  end

  defp ask_payment_notification(task, project) do
    Accounts.create_notification(%{
      "type" => "push",
      "user_id" => project.client_id,
      "link" => "/projects/#{project.id}/tasks/#{task.id}/show",
      "message" => """
        <p><strong>#{full_name(task.freelancer)}</strong> asked to release payment for the task #{task.title} associated with the project #{project.title} </p>
      """
    })
  end

  defp sprint_complete_notification(sprint, project) do
    Enum.each(sprint.tasks, fn task ->
      if !is_nil(task.freelancer_id) do
        Accounts.create_notification(%{
          "type" => "push",
          "user_id" => task.freelancer_id,
          "link" => "/projects/#{project.id}/show",
          "message" => """
            <p>Dear <strong>#{full_name(task.freelancer)}</strong>,</p>
            <p>The sprint <strong>#{sprint.title}</strong> for the project <strong>#{project.title}</strong> has been successfully completed. Please check the sprint details for any pending tasks or updates.</p>
          """
        })
      end
    end)
  end
end
