defmodule ProjeXpert.Chart do
  import ProjeXpertWeb.LiveHelpers

  def tasks_chart(projects) do
    grouped_data = group_tasks_by_month(projects)

    %{
      type: "doughnut",
      heading: "Tasks by Months",
      labels: Map.keys(grouped_data),
      datasets: Map.values(grouped_data)
    }
  end

  def projects_chart(projects) do
    grouped_data = group_projects_by_date(projects)

    %{
      type: "doughnut",
      labels: Map.keys(grouped_data),
      datasets: Map.values(grouped_data)
    }
  end

  defp group_projects_by_date(projects) do
    projects
    |> Enum.group_by(& &1.status)
    |> Enum.map(fn {status, projects} -> {camel_case_string(status), length(projects)} end)
    |> Enum.into(%{})
  end

  defp group_tasks_by_month(projects) do
    projects
    |> Enum.flat_map(fn project ->
      Enum.map(project.tasks, fn task ->
        {NaiveDateTime.to_date(task.inserted_at), task}
      end)
    end)
    # Grouping by month and year
    |> Enum.group_by(fn {date, _task} ->
      {date.year, date.month}
    end)
    |> Enum.map(fn {{year, month}, tasks} ->
      # Counting tasks for each month
      month_name = month_name(month)
      {month_name <> " " <> Integer.to_string(year), length(tasks)}
    end)
    |> Enum.into(%{})
  end

  defp month_name(month) do
    case month do
      1 -> "January"
      2 -> "February"
      3 -> "March"
      4 -> "April"
      5 -> "May"
      6 -> "June"
      7 -> "July"
      8 -> "August"
      9 -> "September"
      10 -> "October"
      11 -> "November"
      12 -> "December"
      _ -> "Unknown"
    end
  end
end
