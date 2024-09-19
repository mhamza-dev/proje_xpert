defmodule ProjeXpertWeb.ProjectsLive.Show do
  alias ProjeXpert.Repo
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.{Column, Task}

  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket), do: ProjeXpertWeb.Endpoint.subscribe("project:#{id}")
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(page_title: "Project Detail", project: Tasks.get_project!(id))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(page_title: "Edit Project", project: Tasks.get_project!(id))
  end

  defp apply_action(socket, :new_column, %{"id" => id}) do
    socket
    |> assign(page_title: "New Column", column: %Column{}, project: Tasks.get_project!(id))
  end

  defp apply_action(socket, :edit_column, %{"id" => id, "column_id" => column_id}) do
    socket
    |> assign(
      page_title: "Edit Column",
      column: Tasks.get_column!(column_id),
      project: Tasks.get_project!(id)
    )
  end

  defp apply_action(socket, :new_task, %{"id" => id}) do
    socket
    |> assign(
      page_title: "New Task",
      task: %Task{},
      project: Tasks.get_project!(id),
      column: %Column{},
      columns: Enum.map(Tasks.project_columns(id), &{&1.name, &1.id})
    )
  end

  defp apply_action(socket, :edit_task, %{"id" => id, "task_id" => task_id}) do
    socket
    |> assign(
      page_title: "Edit Task",
      task: Tasks.get_task!(task_id),
      project: Tasks.get_project!(id),
      column: %Column{},
      columns: Enum.map(Tasks.project_columns(id), &{&1.name, &1.id})
    )
  end

  def handle_event("drag-drop", params, socket) do
    send(self(), {:drag_drop, params})
    {:noreply, socket}
  end

  def handle_info({:drag_drop, params}, socket) do
    with %Task{} = task <- Tasks.get_task!(params["draggedId"]),
         {:ok, task} <- Tasks.update_task(task, %{"column_id" => params["dropzoneId"]}),
         task <- Repo.preload(task, :column) do
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
end
