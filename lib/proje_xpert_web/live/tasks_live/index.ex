defmodule ProjeXpertWeb.TasksLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks

  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(current_tab: Map.get(params, "tab"))
     |> assign(
       :tasks,
       Enum.filter(Tasks.list_tasks(), & &1.find_worker?)
     )}
  end
end
