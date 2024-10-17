defmodule ProjeXpertWeb.ProjectsLive.TaskForm do
  alias Ecto.Changeset
  use ProjeXpertWeb, :live_component

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.{Comment, Reply}

  def update(%{task: task, project: project, action: :projects_show_task} = assigns, socket) do
    changeset = Tasks.change_task(task, %{project_id: project.id})
    cc = Tasks.change_comment(%Comment{}, %{task_id: task.id})
    rc = Tasks.change_reply(%Reply{}, %{task_id: task.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       changeset: changeset,
       cc: cc,
       rc: rc,
       comment: %Comment{},
       add_new_comment: false,
       add_new_reply: false,
       selected_comment: nil
     )}
  end

  def update(%{task: task, project: project, action: action} = assigns, socket) do
    changeset = Tasks.change_task(task, %{project_id: project.id})

    if action != :projects_show_task and project.status == :completed do
      send(self(), {:return_to_home, project})
    end

    {:ok, socket |> assign(assigns) |> assign(changeset: changeset)}
  end

  def update(%{task: task, projects: projects} = assigns, socket) do
    project = List.first(projects)
    columns = Tasks.project_columns(project.id)
    column = List.first(columns)
    changeset = Tasks.change_task(task, %{project_id: project.id, column_id: column.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       changeset: changeset,
       projects: Enum.map(projects, &{&1.title, &1.id}),
       columns: Enum.map(columns, &{&1.name, &1.id})
     )}
  end

  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset =
      socket.assigns.task
      |> Tasks.change_task(task_params)
      |> Map.put(:action, :validate)

    changeset =
      if check_project_budget_for_task(task_params["budget"], socket.assigns.project) do
        changeset
        |> Changeset.add_error(
          :budget,
          "Task exceeds project budget. Adjust task or increase project budget."
        )
        |> Map.put(:is_valid?, false)
      else
        changeset
      end

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    case socket.assigns.action do
      action when action in [:projects_new_task, :bids_new_task] ->
        create_task(task_params, socket)

      :projects_edit_task ->
        update_task(task_params, socket)
    end
  end

  def handle_event("validate_comment", %{"comment" => comment_params}, socket) do
    cc =
      socket.assigns.comment
      |> Tasks.change_comment(comment_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(cc: cc)}
  end

  def handle_event("save_comment", %{"comment" => comment_params}, socket) do
    case Tasks.create_comment(comment_params) do
      {:ok, _comment} ->
        Phoenix.PubSub.broadcast!(
          ProjeXpert.PubSub,
          "project:#{socket.assigns.task.project_id}",
          {:task, socket.assigns.task.project_id}
        )

        {:noreply, socket |> put_flash(:info, "Comment created successfully")}

      {:error, cc} ->
        {:noreply, socket |> assign(cc: cc)}
    end
  end

  def handle_event("validate_reply", %{"reply" => reply_params}, socket) do
    cc =
      socket.assigns.reply
      |> Tasks.change_reply(reply_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(cc: cc)}
  end

  def handle_event("save_reply", %{"reply" => reply_params}, socket) do
    case Tasks.create_reply(reply_params) do
      {:ok, _reply} ->
        Phoenix.PubSub.broadcast!(
          ProjeXpert.PubSub,
          "project:#{socket.assigns.task.project_id}",
          {:task, socket.assigns.task.project_id}
        )

        {:noreply, socket |> put_flash(:info, "Reply created successfully")}

      {:error, cc} ->
        {:noreply, socket |> assign(cc: cc)}
    end
  end

  def handle_event("add_new_comment", _unsigned_params, socket) do
    {:noreply, socket |> assign(add_new_comment: !socket.assigns.add_new_comment)}
  end

  def handle_event("add_new_reply", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(
       add_new_reply: !socket.assigns.add_new_reply,
       selected_comment: elem(Integer.parse(id), 0)
     )}
  end

  defp create_task(task_params, socket) do
    case Tasks.create_task(task_params) do
      {:ok, task} ->
        Phoenix.PubSub.broadcast!(
          ProjeXpert.PubSub,
          "project:#{task.project_id}",
          {:task, task.project_id}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Task created successfully")
         |> push_navigate(to: ~p"/projects/#{task.project_id}/show")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  defp update_task(task_params, socket) do
    case Tasks.update_task(socket.assigns.task, task_params) do
      {:ok, task} ->
        Phoenix.PubSub.broadcast!(
          ProjeXpert.PubSub,
          "project:#{task.project_id}",
          {:task, task.project_id}
        )

        {:noreply,
         socket
         |> put_flash(:info, "task updated successfully")
         |> push_navigate(to: ~p"/projects/#{task.project_id}/show")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end
end
