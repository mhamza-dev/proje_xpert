defmodule ProjeXpert.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @roles [
    :client,
    # Permissions: Post/manage projects and tasks, review/select bids, handle payments.
    # Features: Project dashboard, task management, bid review, payment processing.
    :worker,
    # Permissions: Bid on tasks, complete work, receive payments.
    # Features: Task bidding, communication with clients, task status updates.
    :admin
    # Permissions: Oversee platform operations, manage users, handle disputes.
    # Features: User management, content moderation, analytics.
  ]
  @register_cast [:first_name, :last_name, :email, :password, :role, :rating, :location, :bio]
  @oauth_cast [:email, :first_name, :last_name, :role, :provider]
  @profile_cast [:first_name, :last_name, :profile_image, :location, :bio]
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :role, Ecto.Enum, values: @roles
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :provider, Ecto.Enum, values: [:google, :creds]
    field :current_password, :string, virtual: true, redact: true
    field :confirmed_at, :utc_datetime
    field :rating, :float, default: 0.00
    field :profile_image, :string
    field :location, :string
    field :bio, :string

    # Associations
    has_many :bids, ProjeXpert.Tasks.Bid, foreign_key: :worker_id
    has_many :projects_as_client, ProjeXpert.Tasks.Project, foreign_key: :client_id
    has_many :worker_projects, ProjeXpert.Tasks.WorkerProject, foreign_key: :worker_id
    has_many :worker_tasks, ProjeXpert.Tasks.WorkerTask, foreign_key: :worker_id
    has_many :created_channels, ProjeXpert.Chats.Channel, foreign_key: :created_by_id
    has_many :channel_users, ProjeXpert.Chats.ChannelUser, foreign_key: :user_id
    has_many :messages, ProjeXpert.Chats.Message, foreign_key: :sender_id

    many_to_many :projects_as_worker, ProjeXpert.Tasks.Project,
      join_through: ProjeXpert.Tasks.WorkerProject,
      join_keys: [worker_id: :id, project_id: :id]

    many_to_many :taks_as_worker, ProjeXpert.Tasks.Task,
      join_through: ProjeXpert.Tasks.WorkerTask,
      join_keys: [worker_id: :id, task_id: :id]

    many_to_many :channels, ProjeXpert.Chats.Channel,
      join_through: ProjeXpert.Chats.ChannelUser,
      join_keys: [user_id: :id, channel_id: :id]

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, @register_cast)
    |> validate_email(opts)
    |> validate_password(opts)
  end

  def oauth_registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, @oauth_cast)
    |> validate_required(@oauth_cast)
    |> validate_email(opts)
  end

  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, @profile_cast)
    |> validate_required(@profile_cast)
  end

  def seed_changeset(user, attrs) do
    user
    |> registration_changeset(attrs)
    |> confirm_changeset()
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_password(opts)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/,
      message: "at least one digit or punctuation character"
    )
    |> validate_confirmation(:password, message: "does not match password")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, ProjeXpert.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%ProjeXpert.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    changeset = cast(changeset, %{current_password: password}, [:current_password])

    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
