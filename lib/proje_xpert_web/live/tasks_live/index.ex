defmodule ProjeXpertWeb.TasksLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks

  def mount(params, _session, %{assigns: %{current_user: current_user}} = socket) do
    {:ok,
     socket
     |> assign(
       current_tab: Map.get(params, "tab"),
       tasks: Tasks.list_tasks_for_worker(current_user, params)
     )}
  end
end
