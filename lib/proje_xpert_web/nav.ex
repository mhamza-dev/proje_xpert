defmodule ProjeXpertWeb.Nav do
  def on_mount(_, _, _, socket) do
    main_module = socket.view |> to_string() |> String.split(".") |> Enum.at(2)
    active_tab = get_active_tab(main_module)
    {:cont, Phoenix.Component.assign(socket, active_tab: active_tab)}
  end

  defp get_active_tab("DashboardLive"), do: :dashboard
  defp get_active_tab("ProjectsLive"), do: :projects
  defp get_active_tab("TasksLive"), do: :tasks
  defp get_active_tab("BidsLive"), do: :bids
  defp get_active_tab(_), do: nil
end
