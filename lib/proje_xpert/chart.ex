defmodule ProjeXpert.Chart do
  import ProjeXpertWeb.LiveHelpers

  def tasks_chart(projects) do
    grouped_data = group_tasks_by_date(projects)

    %{
      type: "line",
      heading: "Tasks",
      labels: Map.keys(grouped_data),
      datasets: Map.values(grouped_data)
    }
  end

  def projects_chart(projects) do
    grouped_data = group_projects_by_date(projects)

    %{
      type: "line",
      heading: "Projects",
      labels: Map.keys(grouped_data),
      datasets: Map.values(grouped_data)
    }
  end

  defp group_projects_by_date(projects) do
    projects
    |> Enum.group_by(&NaiveDateTime.to_date(&1.inserted_at))
    |> Enum.map(fn {date, projects} -> {stringify_date(date), length(projects)} end)
    |> Enum.into(%{})
  end

  defp group_tasks_by_date(projects) do
    projects
    |> Enum.flat_map(fn project ->
      Enum.map(project.tasks, fn task ->
        {NaiveDateTime.to_date(task.inserted_at), task}
      end)
    end)
    # Grouping by task inserted_at date
    |> Enum.group_by(fn {date, _task} -> date end)
    |> Enum.map(fn {date, tasks} ->
      # Counting tasks for each date
      {stringify_date(date), length(tasks)}
    end)
    |> Enum.into(%{})
  end
end
