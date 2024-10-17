defmodule ProjeXpertWeb.ProjectsLive.Show do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.{Column, Task}
  alias ProjeXpert.Repo

  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(ProjeXpert.PubSub, "project:#{id}")
    {:ok, socket}
  end

  def handle_params(%{"id" => id} = params, _url, socket) do
    {:noreply,
     socket
     |> assign(
       project: Tasks.get_project!(id),
       columns: Enum.map(Tasks.project_columns(id), &{&1.name, &1.id})
     )
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(page_title: "Project Detail")
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(page_title: "Edit Project")
  end

  defp apply_action(socket, :new_column, _params) do
    socket
    |> assign(page_title: "New Column", column: %Column{})
  end

  defp apply_action(socket, :edit_column, %{"column_id" => column_id}) do
    socket
    |> assign(
      page_title: "Edit Column",
      column: Tasks.get_column!(column_id)
    )
  end

  defp apply_action(socket, :projects_new_task, _) do
    socket
    |> assign(
      page_title: "New Task",
      task: %Task{},
      column: %Column{}
    )
  end

  defp apply_action(socket, :projects_edit_task, %{"task_id" => task_id}) do
    socket
    |> assign(
      page_title: "Edit Task",
      task: Tasks.get_task!(task_id),
      column: %Column{}
    )
  end

  defp apply_action(socket, :projects_show_task, %{"task_id" => task_id}) do
    socket
    |> assign(
      page_title: "Task Details",
      task: Tasks.get_task!(task_id),
      column: %Column{}
    )
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
         task <- Repo.preload(task, :column) do
      Phoenix.PubSub.broadcast!(
        ProjeXpert.PubSub,
        "project:#{socket.assigns.project.id}",
        {:task_moved, socket.assigns.project.id}
      )

      {:noreply,
       socket
       |> put_flash(:info, "Project moved to \"#{task.column.name}\" column successfully")
       |> push_patch(to: ~p"/projects/#{socket.assigns.project.id}/show")}
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
    {:noreply, assign(socket, project: Tasks.get_project!(project_id) |> dbg())}
  end

  def handle_info({:return_to_home, project}, socket) do
    {:noreply,
     push_patch(socket, to: ~p"/projects/#{project.id}/show")
     |> put_flash(
       :error,
       "You can't perform this action as this project has been #{camel_case_string(project.status)}"
     )}
  end
end
