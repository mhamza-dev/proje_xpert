defmodule ProjeXpertWeb.ProjectsLive.ColumnForm do
  use ProjeXpertWeb, :live_component

  alias ProjeXpert.Tasks

  def update(%{column: column, project: project} = assigns, socket) do
    changeset = Tasks.change_column(column, %{project_id: project.id})
    {:ok, socket |> assign(assigns) |> assign(changeset: changeset)}
  end

  def handle_event("validate", %{"column" => column_params}, socket) do
    changeset =
      socket.assigns.column
      |> Tasks.change_column(column_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("save", %{"column" => column_params}, socket) do
    case socket.assigns.action do
      :new_column ->
        create_column(column_params, socket)

      :edit_column ->
        update_column(column_params, socket)
    end
  end

  defp create_column(column_params, socket) do
    case Tasks.create_column(column_params) do
      {:ok, column} ->
        {:noreply,
         socket
         |> put_flash(:info, "Column created successfully")
         |> push_navigate(to: ~p"/projects/#{column.project_id}/show")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  defp update_column(column_params, socket) do
    case Tasks.update_column(socket.assigns.column, column_params) do
      {:ok, column} ->
        {:noreply,
         socket
         |> put_flash(:info, "Column updated successfully")
         |> push_navigate(to: ~p"/projects/#{column.project_id}/show")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end
end
