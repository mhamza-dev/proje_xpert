defmodule ProjeXpertWeb.LiveHelpers do
  alias ProjeXpert.Chats
  alias ProjeXpert.Chats.Channel
  alias ProjeXpert.Tasks.Task
  alias Phoenix.LiveView
  alias ProjeXpert.Repo
  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Project
  alias ProjeXpert.Tasks.Bid
  alias ProjeXpert.Tasks.Payment
  alias ProjeXpertWeb.UserPresence, as: Presence

  def is_freelancer?(user), do: user.role == :freelancer

  def is_client?(user), do: user.role == :client

  def full_name(user), do: user.first_name <> " " <> user.last_name

  def camel_case_string(value) when is_atom(value) do
    value |> to_string() |> camel_case_string()
  end

  def camel_case_string(value) when is_binary(value) do
    value |> String.split("_") |> Enum.join(" ") |> String.capitalize()
  end

  def get_tasks_by_current_user(%{id: id, role: :freelancer}, tasks),
    do: Enum.filter(tasks, &(&1.freelancer_id == id))

  def get_tasks_by_current_user(_, tasks), do: tasks

  def get_freelancer_ids_of_a_project(project) do
    project.tasks
    |> Enum.flat_map(& &1.freelancer_id)
    |> Enum.uniq()
  end

  def get_freelancers_of_a_project(project) do
    project.tasks
    |> Enum.filter(&(!is_nil(&1.freelancer)))
    |> Enum.uniq_by(& &1.freelancer_id)
    |> Enum.map(& &1.freelancer)
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

  def get_color_by_status(status) when status in [:submitted], do: "text-blue-600 bg-blue-600/15"

  def get_color_by_status(status) when status in [:pending, :in_progress, :under_review],
    do: "text-yellow-500 bg-yellow-100"

  def get_color_by_status(status) when status in [:completed, :accepted],
    do: "text-green-500 bg-green-100"

  def get_color_by_status(status)
      when status in [:failed, :cancelled, :on_hold, :pending, :rejected, :withdrawn],
      do: "text-red-500 bg-red-100"

  def get_color_by_status(status) when status in [:refunded],
    do: "text-gray-500 bg-gray-100"

  def get_tailwind_width_class(project) do
    percentage = get_task_percentage(project)

    cond do
      percentage <= 24 -> "w-1 bg-red-500"
      percentage >= 25 and percentage <= 50 -> "w-1/4 bg-yellow-500"
      percentage >= 51 and percentage <= 75 -> "w-1/2 bg-blue-600"
      percentage >= 76 and percentage <= 99 -> "w-3/4 bg-green-500"
      true -> "w-full bg-green-500"
    end
  end

  def get_task_percentage(project) do
    if length(project.tasks) > 0,
      do: Enum.count(project.tasks, & &1.is_completed?) / Enum.count(project.tasks) * 100,
      else: 0
  end

  def get_resources_by_role(resource, %{id: id, role: role}, params \\ %{}) do
    apply(get_function_by_resource(resource, role), [id, params])
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

  def client_average_task_budget(client) do
    client = client |> Repo.preload(projects_as_client: [:tasks])

    all_task_budget =
      Enum.map(client.projects_as_client, & &1.tasks)
      |> List.flatten()
      |> Enum.map(&Decimal.to_float(&1.budget))

    Enum.sum(all_task_budget) / length(all_task_budget)
  end

  def file_name(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    "#{entry.uuid}.#{ext}"
  end

  def upload_files(socket, key) do
    LiveView.consume_uploaded_entries(socket, key, fn %{path: path}, _entry ->
      case Cloudex.upload(path) do
        {:ok, %Cloudex.UploadedImage{secure_url: secure_url}} ->
          {:ok, secure_url}

        {:error, error} ->
          {:postpone, {:error, error}}
      end
    end)
  end

  def average_progress_percentage(entries) do
    total_progress = Enum.reduce(entries, 0, fn entry, acc -> acc + entry.progress end)
    count = length(entries)

    if count > 0, do: total_progress / count, else: 0.00
  end

  def get_user_bid(user, bids) do
    Enum.find(bids, &(&1.freelancer_id == user.id))
  end

  def user_already_bidded?(user, bids) do
    Enum.any?(bids, &(&1.freelancer_id == user.id))
  end

  def is_user_already_in_project(bid) do
    case Tasks.get_freelancer_project_by_freelancer_id(bid) do
      nil ->
        Tasks.create_freelancer_project(build_freelancer_project_params(bid))

      _ ->
        {:ok, "already in project"}
    end
  end

  def build_freelancer_project_params(bid),
    do: %{"project_id" => bid.task.project.id, "freelancer_id" => bid.freelancer_id}

  def get_selected_values(map) when is_map(map) do
    map
    |> Enum.filter(fn {_key, value} -> value != "" and value == "true" end)
    |> Enum.map(fn {key, _value} -> key end)
  end

  def get_selected_values(nil), do: []

  def is_user_online?(target_user) do
    Presence.list("user_presence:lobby")
    |> Enum.any?(fn {_key, %{metas: metas}} ->
      Enum.any?(metas, fn %{user: %{id: user_id}} -> user_id == target_user.id end)
    end)
  end

  def list_channel_online_user(target_users) do
    Presence.list("user_presence:lobby")
    |> Enum.flat_map(fn {_key, %{metas: metas}} ->
      Enum.filter(metas, fn %{user: %{id: user_id}} -> user_id in target_users end)
    end)
    |> Enum.map(& &1.user)
  end

  def exts_for_profile, do: ~w(.jpg .jpeg .png .gif .bmp .tiff .webp)
  def exts_for_cover_letter, do: ~w(.pdf .doc .docx .odt .rtf .txt)

  def get_project_freelancers(project) do
    project.project_freelancers
    |> Enum.map(&%{id: &1.freelancer.id, label: full_name(&1.freelancer)})
  end

  def combine_classes(class_list) do
    class_list
    |> Enum.reject(&(&1 == false))
    |> Enum.join(" ")
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

  def get_preload(context, preload_schames) do
    Repo.preload(context, preload_schames)
  end

  def generate_random_float(min, max), do: Float.round(min + :rand.uniform() * (max - min), 2)

  def is_integer?(value) when is_binary(value) do
    case Integer.parse(value) do
      {int_value, ""} when is_integer(int_value) ->
        true

      _ ->
        false
    end
  end

  def is_uuid?(value) do
    case Ecto.UUID.cast(value) do
      {:ok, _uuid} -> true
      _ -> false
    end
  end

  def get_default_pm_of_user(user) do
    user.payment_methods
    |> Enum.sort_by(& &1.inserted_at, :desc)
    |> Enum.find(& &1.default)
  end

  def gravatar(user) do
    "https://ui-avatars.com/api/?name=#{get_initials(user)}&background=random&color=fff&rounded=true&bold=true"
  end

  defp get_initials(%{first_name: fname, last_name: lname}),
    do: String.at(fname, 0) <> String.at(lname, 0)

  defp get_initials(%{email: email}), do: String.at(email, 0)

  defp get_function_by_resource(Project, :client), do: &Tasks.list_client_projects/2
  defp get_function_by_resource(Project, :freelancer), do: &Tasks.list_project_freelancers/2

  defp get_function_by_resource(Bid, :client), do: &Tasks.list_client_bids/2
  defp get_function_by_resource(Bid, :freelancer), do: &Tasks.list_freelancer_bids/2

  defp get_function_by_resource(Task, :client), do: &Tasks.list_tasks_for_client/2
  defp get_function_by_resource(Task, :freelancer), do: &Tasks.list_tasks_for_freelancer/2

  defp get_function_by_resource(Payment, :client), do: &Tasks.list_payments_for_client/2
  defp get_function_by_resource(Payment, :freelancer), do: &Tasks.list_payments_for_freelancer/2

  defp get_function_by_resource(Channel, :client), do: &Chats.list_channels_for_client/2
  defp get_function_by_resource(Channel, :freelancer), do: &Chats.list_channels_for_freelancer/2
end
