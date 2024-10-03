defmodule ProjeXpert.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias ProjeXpert.Repo
  alias ProjeXpert.Tasks.{Bid, Chat, Column, Project, Payment, Task, WorkerProject, WorkerTask}

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
  def list_client_projects(id) do
    Project
    |> where([p], p.client_id == ^id)
    |> preload([:client, tasks: [:column, :worker_tasks, bids: :worker]])
    |> Repo.all()
  end

  def list_worker_projects(id) do
    Project
    # |> join(:inner, [p], wp in assoc(p, :worker_projects))
    |> join(:inner, [p], t in assoc(p, :tasks))
    |> join(:inner, [_p, t], wt in assoc(t, :worker_tasks))
    |> where([_p, _t, wt], wt.worker_id == ^id)
    |> distinct([p, _t, _wt], p.id)
    |> preload([:client, tasks: [:column, :worker_tasks, bids: :worker]])
    |> Repo.all()
  end

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
      |> Repo.preload([:client, columns: [tasks: [:worker_tasks, bids: :worker]]])

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
    |> Project.changeset(attrs)
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
    Repo.all(Task) |> Repo.preload([:worker_tasks, project: :client])
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
  def get_task!(id), do: Repo.get!(Task, id) |> Repo.preload(:bids)

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

  def list_client_bids(id) do
    from(b in Bid,
      inner_join: t in assoc(b, :task),
      inner_join: p in assoc(t, :project),
      where: p.client_id == ^id
    )
    |> preload([:worker, task: :project])
    |> Repo.all()
  end

  def list_worker_bids(id) do
    from(b in Bid,
      inner_join: t in assoc(b, :task),
      inner_join: wt in assoc(t, :worker_tasks),
      where: wt.worker_id == ^id
    )
    |> preload([:worker, task: :project])
    |> Repo.all()
  end

  @doc """
  Gets a single bid.

  Raises `Ecto.NoResultsError` if the Bid does not exist.

  ## Examples

      iex> get_bid!(123)
      %Bid{}

      iex> get_bid!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bid!(id), do: Repo.get!(Bid, id) |> Repo.preload([:worker, task: :project])

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
  Returns the list of chats.

  ## Examples

      iex> list_chats()
      [%Chat{}, ...]

  """
  def list_chats do
    Repo.all(Chat)
  end

  @doc """
  Gets a single chat.

  Raises `Ecto.NoResultsError` if the Chat does not exist.

  ## Examples

      iex> get_chat!(123)
      %Chat{}

      iex> get_chat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat!(id), do: Repo.get!(Chat, id)

  @doc """
  Creates a chat.

  ## Examples

      iex> create_chat(%{field: value})
      {:ok, %Chat{}}

      iex> create_chat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat.

  ## Examples

      iex> update_chat(chat, %{field: new_value})
      {:ok, %Chat{}}

      iex> update_chat(chat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chat.

  ## Examples

      iex> delete_chat(chat)
      {:ok, %Chat{}}

      iex> delete_chat(chat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat changes.

  ## Examples

      iex> change_chat(chat)
      %Ecto.Changeset{data: %Chat{}}

  """
  def change_chat(%Chat{} = chat, attrs \\ %{}) do
    Chat.changeset(chat, attrs)
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

  def project_columns(id) do
    Column
    |> where([c], c.project_id == ^id)
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
  Returns the list of worker_projects.

  ## Examples

      iex> list_worker_projects()
      [%WorkerProject{}, ...]

  """
  def list_worker_projects do
    Repo.all(WorkerProject)
  end

  @doc """
  Gets a single worker_project.

  Raises `Ecto.NoResultsError` if the Worker project does not exist.

  ## Examples

      iex> get_worker_project!(123)
      %WorkerProject{}

      iex> get_worker_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_worker_project!(id), do: Repo.get!(WorkerProject, id)

  @doc """
  Creates a worker_project.

  ## Examples

      iex> create_worker_project(%{field: value})
      {:ok, %WorkerProject{}}

      iex> create_worker_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_worker_project(attrs \\ %{}) do
    %WorkerProject{}
    |> WorkerProject.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a worker_project.

  ## Examples

      iex> update_worker_project(worker_project, %{field: new_value})
      {:ok, %WorkerProject{}}

      iex> update_worker_project(worker_project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_worker_project(%WorkerProject{} = worker_project, attrs) do
    worker_project
    |> WorkerProject.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a worker_project.

  ## Examples

      iex> delete_worker_project(worker_project)
      {:ok, %WorkerProject{}}

      iex> delete_worker_project(worker_project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_worker_project(%WorkerProject{} = worker_project) do
    Repo.delete(worker_project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking worker_project changes.

  ## Examples

      iex> change_worker_project(worker_project)
      %Ecto.Changeset{data: %WorkerProject{}}

  """
  def change_worker_project(%WorkerProject{} = worker_project, attrs \\ %{}) do
    WorkerProject.changeset(worker_project, attrs)
  end

  @doc """
  Returns the list of worker_tasks.

  ## Examples

      iex> list_worker_tasks()
      [%WorkerTask{}, ...]

  """
  def list_worker_tasks do
    Repo.all(WorkerTask)
  end

  @doc """
  Gets a single worker_task.

  Raises `Ecto.NoResultsError` if the Worker task does not exist.

  ## Examples

      iex> get_worker_task!(123)
      %WorkerTask{}

      iex> get_worker_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_worker_task!(id), do: Repo.get!(WorkerTask, id)

  @doc """
  Creates a worker_task.

  ## Examples

      iex> create_worker_task(%{field: value})
      {:ok, %WorkerTask{}}

      iex> create_worker_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_worker_task(attrs \\ %{}) do
    %WorkerTask{}
    |> WorkerTask.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a worker_task.

  ## Examples

      iex> update_worker_task(worker_task, %{field: new_value})
      {:ok, %WorkerTask{}}

      iex> update_worker_task(worker_task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_worker_task(%WorkerTask{} = worker_task, attrs) do
    worker_task
    |> WorkerTask.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a worker_task.

  ## Examples

      iex> delete_worker_task(worker_task)
      {:ok, %WorkerTask{}}

      iex> delete_worker_task(worker_task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_worker_task(%WorkerTask{} = worker_task) do
    Repo.delete(worker_task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking worker_task changes.

  ## Examples

      iex> change_worker_task(worker_task)
      %Ecto.Changeset{data: %WorkerTask{}}

  """
  def change_worker_task(%WorkerTask{} = worker_task, attrs \\ %{}) do
    WorkerTask.changeset(worker_task, attrs)
  end
end
