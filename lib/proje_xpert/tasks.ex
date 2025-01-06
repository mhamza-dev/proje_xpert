defmodule ProjeXpert.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  import ProjeXpertWeb.LiveHelpers
  alias ProjeXpert.Stripe.PaymentIntent
  alias ProjeXpert.Repo
  alias ProjeXpert.Tasks.{Bid, Comment, Column, Project, Payment, Task, Projectfreelancer}

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """

  def list_client_projects(id, filters) do
    from(p in Project, where: p.client_id == ^id)
    |> filter_projects_query(filters)
    |> filter_projects_by_tab(filters)
    |> preload([:client, :project_freelancers, tasks: [:column, :freelancer, bids: :freelancer]])
    |> Repo.all()
  end

  def list_project_freelancers(id, filters) do
    from(p in Project,
      inner_join: wp in assoc(p, :project_freelancers),
      inner_join: t in assoc(p, :tasks),
      where: t.freelancer_id == ^id
    )
    |> filter_projects_query(filters)
    |> filter_projects_by_tab(filters)
    |> distinct([p, _wp, _t, _wt], p.id)
    |> preload([:client, :project_freelancers, tasks: [:column, :freelancer, bids: :freelancer]])
    |> Repo.all()
  end

  defp filter_projects_query(query, %{"search_term" => search_term}) do
    from(q in query, where: ilike(q.title, ^"%#{String.trim(search_term)}%"))
  end

  defp filter_projects_query(query, _filter), do: query

  defp filter_projects_by_tab(query, %{"tab" => tab}) do
    from(q in query, where: q.status == ^tab)
  end

  defp filter_projects_by_tab(query, _filter), do: query

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id),
    do:
      Repo.get!(Project, id)
      |> Repo.preload([
        :client,
        :tasks,
        :channel,
        project_freelancers: [:freelancer],
        sprints: [columns: [tasks: [:freelancer, bids: :freelancer]]]
      ])

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task) |> Repo.preload([:freelancer, :comments, project: :client])
  end

  def list_tasks_for_freelancer(freelancer, filters) do
    from(t in Task,
      where: t.find_freelancer? == true,
      where: t.freelancer_id != ^freelancer.id
    )
    |> task_query_for_fragment(filters)
    |> Repo.all()
    |> Repo.preload([:freelancer, :comments, project: :client])
  end

  def list_tasks_for_client(client, filters) do
    from(t in Task,
      join: p in assoc(t, :project),
      where: p.client_id == ^client.id
    )
    |> task_query_for_fragment(filters)
    |> Repo.all()
    |> Repo.preload([:freelancer, :comments, project: :client])
  end

  defp task_query_for_fragment(query, %{"tab" => current_tab}) do
    current_date = NaiveDateTime.utc_now()

    query_date = get_date_range(current_date, current_tab)

    from(q in query,
      where: q.inserted_at <= ^query_date,
      order_by: [asc: q.inserted_at]
    )
  end

  defp task_query_for_fragment(query, _), do: query

  defp get_date_range(current_date, current_tab) do
    case current_tab do
      "latest" ->
        # Last 24 hours
        current_date

      "last_week" ->
        # Last 7 days
        NaiveDateTime.add(current_date, -7 * 86400, :second)

      "last_month" ->
        # Last 30 days
        NaiveDateTime.add(current_date, -30 * 86400, :second)
    end
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id),
    do:
      Repo.get!(Task, id)
      |> Repo.preload([
        :bids,
        :freelancer,
        [project: [:client], comments: [:user, replies: :user]]
      ])

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  @doc """
  Returns the list of bids.

  ## Examples

      iex> list_bids()
      [%Bid{}, ...]

  """
  def list_bids do
    Repo.all(Bid)
  end

  def list_client_bids(id, filters) do
    from(b in Bid,
      inner_join: t in assoc(b, :task),
      inner_join: p in assoc(t, :project),
      where: p.client_id == ^id
    )
    |> filter_bids_query(filters)
    |> filter_bids_by_tab(filters)
    |> preload([:freelancer, task: :project])
    |> Repo.all()
  end

  def list_freelancer_bids(id, filters) do
    from(b in Bid,
      inner_join: t in assoc(b, :task),
      inner_join: wt in assoc(t, :freelancer),
      where: wt.freelancer_id == ^id
    )
    |> filter_bids_query(filters)
    |> filter_bids_by_tab(filters)
    |> preload([:freelancer, task: :project])
    |> Repo.all()
  end

  defp filter_bids_query(query, %{"search_term" => search_term}) do
    from(q in query,
      inner_join: w in assoc(q, :freelancer),
      where: ilike(w.first_name, ^"%#{String.trim(search_term)}%"),
      or_where: ilike(w.last_name, ^"%#{String.trim(search_term)}%")
    )
  end

  defp filter_bids_query(query, _filter), do: query

  defp filter_bids_by_tab(query, %{"tab" => tab}) do
    from(q in query, where: q.status == ^tab)
  end

  defp filter_bids_by_tab(query, _filter), do: query

  @doc """
  Gets a single bid.

  Raises `Ecto.NoResultsError` if the Bid does not exist.

  ## Examples

      iex> get_bid!(123)
      %Bid{}

      iex> get_bid!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bid!(id), do: Repo.get!(Bid, id) |> Repo.preload([:freelancer, task: :project])

  @doc """
  Creates a bid.

  ## Examples

      iex> create_bid(%{field: value})
      {:ok, %Bid{}}

      iex> create_bid(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bid(attrs \\ %{}) do
    %Bid{}
    |> Bid.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bid.

  ## Examples

      iex> update_bid(bid, %{field: new_value})
      {:ok, %Bid{}}

      iex> update_bid(bid, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bid(%Bid{} = bid, attrs) do
    bid
    |> Bid.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bid.

  ## Examples

      iex> delete_bid(bid)
      {:ok, %Bid{}}

      iex> delete_bid(bid)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bid(%Bid{} = bid) do
    Repo.delete(bid)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bid changes.

  ## Examples

      iex> change_bid(bid)
      %Ecto.Changeset{data: %Bid{}}

  """
  def change_bid(%Bid{} = bid, attrs \\ %{}) do
    Bid.changeset(bid, attrs)
  end

  @doc """
  Returns the list of payments.

  ## Examples

      iex> list_payments()
      [%Payment{}, ...]

  """
  def list_payments do
    Repo.all(Payment)
  end

  def list_payments_for_freelancer(freelancer_id, filters) do
    from(p in Payment, where: p.receiver_id == ^freelancer_id)
    |> filter_payments_by_tab(filters)
    |> preload([:receiver, :payer, :task])
    |> Repo.all()
  end

  def list_payments_for_client(client_id, filters) do
    from(p in Payment, where: p.payer_id == ^client_id)
    |> filter_payments_by_tab(filters)
    |> preload([:receiver, :payer, :task])
    |> Repo.all()
  end

  defp filter_payments_by_tab(query, %{"tab" => tab}) do
    from(q in query, where: q.status == ^tab)
  end

  defp filter_payments_by_tab(query, _filter), do: query

  @doc """
  Gets a single payment.

  Raises `Ecto.NoResultsError` if the Payment does not exist.

  ## Examples

      iex> get_payment!(123)
      %Payment{}

      iex> get_payment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_payment!(id), do: Repo.get!(Payment, id)

  @doc """
  Creates a payment.

  ## Examples

      iex> create_payment(%{field: value})
      {:ok, %Payment{}}

      iex> create_payment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment(attrs \\ %{}) do
    %Payment{}
    |> Payment.changeset(attrs)
    |> Repo.insert()
  end

  def create_payment_with_stripe(user, attrs) do
    with {:ok, payment} <- create_payment(attrs),
         {:ok, _} <- PaymentIntent.create(payment_intent_params(user, payment) |> dbg()) |> dbg() do
      {:ok, payment}
    else
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, "Unknown error occurred"}
    end
  end

  defp payment_intent_params(user, payment) do
    total_amount = dollars_to_cents(payment.amount)
    %{
      metadata: %{"payment_id" => payment.id, "task_id" => payment.task_id},
      amount: total_amount * 0.8,
      currency: "USD",
      customer: user.stripe_customer_id,
      payment_method: get_default_pm_of_user(user).card_id,
      confirm: true,
      receipt_email: user.email,
      automatic_payment_methods: %{
        enabled: true,
        allow_redirects: "never"
      },
      application_fee_amount: total_amount * 0.2
    }
  end

  @doc """
  Updates a payment.

  ## Examples

      iex> update_payment(payment, %{field: new_value})
      {:ok, %Payment{}}

      iex> update_payment(payment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_payment(%Payment{} = payment, attrs) do
    payment
    |> Payment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a payment.

  ## Examples

      iex> delete_payment(payment)
      {:ok, %Payment{}}

      iex> delete_payment(payment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_payment(%Payment{} = payment) do
    Repo.delete(payment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking payment changes.

  ## Examples

      iex> change_payment(payment)
      %Ecto.Changeset{data: %Payment{}}

  """
  def change_payment(%Payment{} = payment, attrs \\ %{}) do
    Payment.changeset(payment, attrs)
  end

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, comment} ->
        {:ok, Repo.preload(comment, [:user, replies: :user])}

      e ->
        e
    end
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  @doc """
  Returns the list of columns.

  ## Examples

      iex> list_columns()
      [%Column{}, ...]

  """
  def list_columns do
    Repo.all(Column)
  end

  def sprint_columns(id) do
    Column
    |> where([c], c.sprint_id == ^id)
    |> Repo.all()
  end

  @doc """
  Gets a single column.

  Raises `Ecto.NoResultsError` if the Column does not exist.

  ## Examples

      iex> get_column!(123)
      %Column{}

      iex> get_column!(456)
      ** (Ecto.NoResultsError)

  """
  def get_column!(id), do: Repo.get!(Column, id)

  @doc """
  Creates a column.

  ## Examples

      iex> create_column(%{field: value})
      {:ok, %Column{}}

      iex> create_column(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_column(attrs \\ %{}) do
    %Column{}
    |> Column.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a column.

  ## Examples

      iex> update_column(column, %{field: new_value})
      {:ok, %Column{}}

      iex> update_column(column, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_column(%Column{} = column, attrs) do
    column
    |> Column.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a column.

  ## Examples

      iex> delete_column(column)
      {:ok, %Column{}}

      iex> delete_column(column)
      {:error, %Ecto.Changeset{}}

  """
  def delete_column(%Column{} = column) do
    Repo.delete(column)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking column changes.

  ## Examples

      iex> change_column(column)
      %Ecto.Changeset{data: %Column{}}

  """
  def change_column(%Column{} = column, attrs \\ %{}) do
    Column.changeset(column, attrs)
  end

  @doc """
  Returns the list of project_freelancers.

  ## Examples

      iex> list_project_freelancers()
      [%Projectfreelancer{}, ...]

  """
  def list_project_freelancers do
    Repo.all(Projectfreelancer)
  end

  def get_freelancer_project_by_freelancer_id(bid) do
    from(wp in Projectfreelancer,
      where: wp.freelancer_id == ^bid.freelancer_id,
      where: wp.project_id == ^bid.task.project.id
    )
    |> Repo.one()
  end

  @doc """
  Gets a single freelancer_project.

  Raises `Ecto.NoResultsError` if the freelancer project does not exist.

  ## Examples

      iex> get_freelancer_project!(123)
      %Projectfreelancer{}

      iex> get_freelancer_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_freelancer_project!(id), do: Repo.get!(Projectfreelancer, id)

  def get_freelancer_project_by_task!(id),
    do: Projectfreelancer |> where([wp], wp.project_id == ^id) |> Repo.one!()

  @doc """
  Creates a freelancer_project.

  ## Examples

      iex> create_freelancer_project(%{field: value})
      {:ok, %Projectfreelancer{}}

      iex> create_freelancer_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_freelancer_project(attrs \\ %{}) do
    %Projectfreelancer{}
    |> Projectfreelancer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a freelancer_project.

  ## Examples

      iex> update_freelancer_project(freelancer_project, %{field: new_value})
      {:ok, %Projectfreelancer{}}

      iex> update_freelancer_project(freelancer_project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_freelancer_project(%Projectfreelancer{} = freelancer_project, attrs) do
    freelancer_project
    |> Projectfreelancer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a freelancer_project.

  ## Examples

      iex> delete_freelancer_project(freelancer_project)
      {:ok, %Projectfreelancer{}}

      iex> delete_freelancer_project(freelancer_project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_freelancer_project(%Projectfreelancer{} = freelancer_project) do
    Repo.delete(freelancer_project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking freelancer_project changes.

  ## Examples

      iex> change_freelancer_project(freelancer_project)
      %Ecto.Changeset{data: %Projectfreelancer{}}

  """
  def change_freelancer_project(%Projectfreelancer{} = freelancer_project, attrs \\ %{}) do
    Projectfreelancer.changeset(freelancer_project, attrs)
  end

  alias ProjeXpert.Tasks.Reply

  @doc """
  Returns the list of replies.

  ## Examples

      iex> list_replies()
      [%Reply{}, ...]

  """
  def list_replies do
    Repo.all(Reply)
  end

  @doc """
  Gets a single reply.

  Raises `Ecto.NoResultsError` if the Reply does not exist.

  ## Examples

      iex> get_reply!(123)
      %Reply{}

      iex> get_reply!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reply!(id), do: Repo.get!(Reply, id)

  @doc """
  Creates a reply.

  ## Examples

      iex> create_reply(%{field: value})
      {:ok, %Reply{}}

      iex> create_reply(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reply(attrs \\ %{}) do
    %Reply{}
    |> Reply.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, reply} ->
        {:ok, Repo.preload(reply, [:user])}

      e ->
        e
    end
  end

  @doc """
  Updates a reply.

  ## Examples

      iex> update_reply(reply, %{field: new_value})
      {:ok, %Reply{}}

      iex> update_reply(reply, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reply(%Reply{} = reply, attrs) do
    reply
    |> Reply.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a reply.

  ## Examples

      iex> delete_reply(reply)
      {:ok, %Reply{}}

      iex> delete_reply(reply)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reply(%Reply{} = reply) do
    Repo.delete(reply)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reply changes.

  ## Examples

      iex> change_reply(reply)
      %Ecto.Changeset{data: %Reply{}}

  """
  def change_reply(%Reply{} = reply, attrs \\ %{}) do
    Reply.changeset(reply, attrs)
  end

  def dollars_to_cents(dollars) when is_binary(dollars),
    do: dollars_to_cents(String.to_float(dollars))

  def dollars_to_cents(dollars) when is_float(dollars), do: round(dollars * 100)

  alias ProjeXpert.Tasks.Sprint

  @doc """
  Returns the list of sprints.

  ## Examples

      iex> list_sprints()
      [%Sprint{}, ...]

  """
  def list_sprints do
    Repo.all(Sprint)
  end

  @doc """
  Gets a single sprint.

  Raises `Ecto.NoResultsError` if the Sprint does not exist.

  ## Examples

      iex> get_sprint!(123)
      %Sprint{}

      iex> get_sprint!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sprint!(id),
    do:
      Repo.get!(Sprint, id)
      |> Repo.preload([
        :project,
        tasks: [:freelancer, bids: :freelancer],
        columns: [tasks: [:freelancer, bids: :freelancer]]
      ])

  def get_sprint(id) do
    from(s in Sprint,
      join: c in assoc(s, :columns),
      where: s.id == ^id,
      order_by: [asc: c.id],
      preload: [:project, columns: [tasks: [:freelancer, bids: :freelancer]]]
    )
    |> Repo.one()
  end

  @doc """
  Creates a sprint.

  ## Examples

      iex> create_sprint(%{field: value})
      {:ok, %Sprint{}}

      iex> create_sprint(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sprint(attrs \\ %{}) do
    %Sprint{}
    |> Sprint.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sprint.

  ## Examples

      iex> update_sprint(sprint, %{field: new_value})
      {:ok, %Sprint{}}

      iex> update_sprint(sprint, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sprint(%Sprint{} = sprint, attrs) do
    sprint
    |> Sprint.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sprint.

  ## Examples

      iex> delete_sprint(sprint)
      {:ok, %Sprint{}}

      iex> delete_sprint(sprint)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sprint(%Sprint{} = sprint) do
    Repo.delete(sprint)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sprint changes.

  ## Examples

      iex> change_sprint(sprint)
      %Ecto.Changeset{data: %Sprint{}}

  """
  def change_sprint(%Sprint{} = sprint, attrs \\ %{}) do
    Sprint.changeset(sprint, attrs)
  end
end
