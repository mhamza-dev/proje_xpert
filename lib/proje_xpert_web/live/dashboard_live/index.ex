defmodule ProjeXpertWeb.DashboardLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Chart
  alias ProjeXpert.Tasks.Project

  def mount(params, _session, socket) do
    projects = get_resources_by_role(Project, socket.assigns.current_user, params)

    {:ok,
     assign(socket,
       projects: projects,
       total_projects: total_projects(projects),
       projects_this_month: projects_this_month(projects),
       ongoing_projects: ongoing_projects(projects),
       ongoing_projects_this_month: ongoing_projects_this_month(projects),
       hired_workers: hired_workers(projects),
       hired_workers_this_month: hired_workers_this_month(projects)
     )}
  end

  defp total_projects(projects), do: Enum.count(projects)

  defp projects_this_month(projects) do
    start_of_month = start_of_month()

    projects
    |> Enum.filter(&(DateTime.compare(&1.inserted_at, start_of_month) != :lt))
    |> Enum.count()
  end

  defp ongoing_projects(projects),
    do:
      projects
      |> Enum.filter(&(&1.status == :in_progress))
      |> Enum.count()

  defp ongoing_projects_this_month(projects) do
    start_of_month = start_of_month()

    projects
    |> Enum.filter(&(DateTime.compare(&1.inserted_at, start_of_month) != :lt))
    |> Enum.filter(&(&1.status == :in_progress))
    |> Enum.count()
  end

  defp hired_workers(projects),
    do:
      projects
      |> Enum.flat_map(& &1.tasks)
      |> Enum.flat_map(& &1.worker_tasks)
      |> Enum.uniq_by(& &1.id)
      |> Enum.count()

  defp hired_workers_this_month(projects) do
    start_of_month = start_of_month()

    projects
    |> Enum.filter(&(DateTime.compare(&1.inserted_at, start_of_month) != :lt))
    |> Enum.flat_map(& &1.tasks)
    |> Enum.flat_map(& &1.worker_tasks)
    |> Enum.uniq_by(& &1.id)
    |> Enum.count()
  end

  defp start_of_month do
    today = Date.utc_today()
    beginning_of_month = Date.beginning_of_month(today)

    beginning_of_month
    |> NaiveDateTime.new!(~T[00:00:00])
    |> DateTime.from_naive!("Etc/UTC")
  end
end
