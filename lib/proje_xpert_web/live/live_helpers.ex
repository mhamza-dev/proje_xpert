defmodule ProjeXpertWeb.LiveHelpers do
  def camel_case_string(value) when is_atom(value) do
    value |> to_string() |> camel_case_string()
  end

  def camel_case_string(value) when is_binary(value) do
    value |> String.split("_") |> Enum.join(" ") |> String.capitalize()
  end

  def get_tasks_by_current_user(%{id: id, role: :worker}, tasks),
    do: Enum.filter(tasks, &Enum.any?(&1.worker_tasks, fn wt -> wt.worker_id == id end))

  def get_tasks_by_current_user(_, tasks), do: tasks
end
