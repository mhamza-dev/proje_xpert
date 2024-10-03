defmodule ProjeXpertWeb.TasksLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks

  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(current_tab: Map.get(params, "tab"))
     |> stream(:tasks, Enum.filter(Tasks.list_tasks(), &Enum.empty?(&1.worker_tasks)))}
  end
end
