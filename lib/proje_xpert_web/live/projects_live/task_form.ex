defmodule ProjeXpertWeb.ProjectsLive.TaskForm do
  use ProjeXpertWeb, :live_component

  alias ProjeXpert.Tasks

  def update(%{task: task, project: project} = assigns, socket) do
    changeset = Tasks.change_task(task, %{project_id: project.id})
    {:ok, socket |> assign(assigns) |> assign(changeset: changeset)}
  end

  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset =
      socket.assigns.task
      |> Tasks.change_task(task_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    case socket.assigns.action do
      :new_task ->
        create_task(task_params, socket)

      :edit_task ->
        update_task(task_params, socket)
    end
  end

  defp create_task(task_params, socket) do
    case Tasks.create_task(task_params) do
      {:ok, task} ->
        Phoenix.PubSub.broadcast!(
          ProjeXpert.PubSub,
          "project:#{socket.assigns.project.id}",
          {:task, socket.assigns.project.id}
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
          "project:#{socket.assigns.project.id}",
          {:task, socket.assigns.project.id}
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
