defmodule ProjeXpertWeb.LiveHelpers do
  alias ProjeXpert.Repo
  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Project
  alias ProjeXpert.Tasks.Bid

  def is_worker?(user), do: user.role == :worker

  def is_client?(user), do: user.role == :client

  def full_name(user), do: user.first_name <> " " <> user.last_name

  def camel_case_string(value) when is_atom(value) do
    value |> to_string() |> camel_case_string()
  end

  def camel_case_string(value) when is_binary(value) do
    value |> String.split("_") |> Enum.join(" ") |> String.capitalize()
  end

  def get_tasks_by_current_user(%{id: id, role: :worker}, tasks),
    do: Enum.filter(tasks, &Enum.any?(&1.worker_tasks, fn wt -> wt.worker_id == id end))

  def get_tasks_by_current_user(_, tasks), do: tasks

  def get_worker_ids_of_a_project(project) do
    project.tasks
    |> Enum.flat_map(fn task ->
      task.worker_tasks
      |> Enum.filter(fn wt -> wt.worker_id end)
      |> Enum.map(& &1.worker_id)
    end)
    |> Enum.uniq()
  end

  def get_worker_names_of_a_project(project) do
    project.tasks
    |> Enum.flat_map(fn task ->
      task.worker_tasks
      |> Enum.filter(fn wt -> wt.worker_id end)
      |> Enum.map(&full_name(Repo.preload(&1, :worker).worker))
    end)
    |> Enum.uniq()
  end

  def format_datetime(%NaiveDateTime{} = dt), do: stringify_date(dt) <> " " <> stringify_time(dt)
  def format_datetime(%DateTime{} = dt), do: stringify_date(dt) <> " " <> stringify_time(dt)

  def stringify_time(%DateTime{} = dt),
    do: DateTime.to_time(dt) |> Time.truncate(:second) |> Time.to_string()

  def stringify_time(%NaiveDateTime{} = dt),
    do: NaiveDateTime.to_time(dt) |> Time.truncate(:second) |> Time.to_string()

  def stringify_time(%Time{} = t), do: Date.to_string(t)

  def stringify_date(%NaiveDateTime{} = dt), do: NaiveDateTime.to_date(dt) |> Date.to_string()
  def stringify_date(%DateTime{} = dt), do: DateTime.to_date(dt) |> Date.to_string()
  def stringify_date(%Date{} = d), do: Date.to_string(d)

  def relative_time(later, now \\ DateTime.utc_now()) do
    diff_in_seconds = DateTime.diff(now, later)

    seconds_in_day = 24 * 3600
    seconds_in_hour = 3600
    seconds_in_minute = 60

    cond do
      # Future times
      diff_in_seconds <= -seconds_in_day ->
        "in #{div(-diff_in_seconds, seconds_in_day)} days"

      diff_in_seconds <= -seconds_in_hour ->
        "in #{div(-diff_in_seconds, seconds_in_hour)} hours"

      diff_in_seconds <= -seconds_in_minute ->
        "in #{div(-diff_in_seconds, seconds_in_minute)} minutes"

      diff_in_seconds < -5 ->
        "in #{-diff_in_seconds} seconds"

      # Present time (close to now)
      abs(diff_in_seconds) <= 5 ->
        "just now"

      # Past times
      diff_in_seconds <= seconds_in_minute ->
        "#{diff_in_seconds} seconds ago"

      diff_in_seconds <= seconds_in_hour ->
        "#{div(diff_in_seconds, seconds_in_minute)} minutes ago"

      diff_in_seconds <= seconds_in_day ->
        "#{div(diff_in_seconds, seconds_in_hour)} hours ago"

      # More than a day ago
      true ->
        "#{div(diff_in_seconds, seconds_in_day)} days ago"
    end
  end

  def get_color_by_status(status) when status in [:submitted], do: "text-blue-500 bg-blue-100/80"

  def get_color_by_status(status) when status in [:in_progress, :under_review],
    do: "text-yellow-500 bg-yellow-100/80"

  def get_color_by_status(status) when status in [:completed, :accepted],
    do: "text-green-500 bg-green-100/80"

  def get_color_by_status(status) when status in [:on_hold, :pending, :rejected, :withdrawn],
    do: "text-red-500 bg-red-100/80"

  def get_tailwind_width_class(project) do
    percentage = get_task_percentage(project)

    cond do
      percentage <= 24 -> "w-1 bg-red-500"
      percentage >= 25 and percentage <= 50 -> "w-1/4 bg-yellow-500"
      percentage >= 51 and percentage <= 75 -> "w-1/2 bg-blue-500"
      percentage >= 76 and percentage <= 99 -> "w-3/4 bg-green-500"
      true -> "w-full bg-green-500"
    end
  end

  def get_task_percentage(project) do
    if length(project.tasks) > 0,
      do: Enum.count(project.tasks, & &1.is_completed?) / Enum.count(project.tasks) * 100,
      else: 0
  end

  def get_resources_by_role(resource, %{id: id, role: role}, params \\ %{}, search_term \\ %{}) do
    apply(get_function_by_resource(resource, role), [id, search_term])
    |> get_resources_by_tab(params)
  end

  def check_project_budget_for_task(task, project) when is_binary(task) do
    if task == "" do
      false
    else
      task = elem(Float.parse(task), 0)
      get_budget(task, project)
    end
  end

  def check_project_budget_for_task(task, project) when is_float(task),
    do: get_budget(task, project)

  def fetch_tab_param(current_tab) do
    if is_nil(current_tab), do: Map.new(), else: %{"tab" => current_tab}
  end

  defp get_budget(task, project) do
    project = Repo.preload(project, [:tasks])
    project_budget = Decimal.to_float(project.budget)

    total_task_budget =
      project.tasks
      |> Enum.map(&Decimal.to_float(&1.budget))
      |> Enum.sum()

    project_budget <= task + total_task_budget
  end

  defp get_function_by_resource(Project, :client), do: &Tasks.list_client_projects/2
  defp get_function_by_resource(Project, :worker), do: &Tasks.list_worker_projects/2

  defp get_function_by_resource(Bid, :client), do: &Tasks.list_client_bids/2
  defp get_function_by_resource(Bid, :worker), do: &Tasks.list_worker_bids/2

  defp get_resources_by_tab(resources, %{"tab" => tab}) when is_binary(tab) do
    Enum.filter(resources, &(&1.status == String.to_atom(tab)))
  end

  defp get_resources_by_tab(resources, %{"tab" => tab}) when is_atom(tab) do
    Enum.filter(resources, &(&1.status == tab))
  end

  defp get_resources_by_tab(resources, _), do: resources
end
