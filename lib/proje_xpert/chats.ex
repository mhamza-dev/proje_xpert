defmodule ProjeXpert.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias ProjeXpert.Repo

  alias ProjeXpert.Chats.Channel

  @doc """
  Returns the list of channels.

  ## Examples

      iex> list_channels()
      [%Channel{}, ...]

  """
  def list_channels do
    Repo.all(Channel)
  end

  @doc """
  Gets a single channel.

  Raises `Ecto.NoResultsError` if the Channel does not exist.

  ## Examples

      iex> get_channel!(123)
      %Channel{}

      iex> get_channel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_channel!(id), do: Repo.get!(Channel, id)

  @doc """
  Creates a channel.

  ## Examples

      iex> create_channel(%{field: value})
      {:ok, %Channel{}}

      iex> create_channel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_channel(attrs \\ %{}) do
    %Channel{}
    |> Channel.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a channel.

  ## Examples

      iex> update_channel(channel, %{field: new_value})
      {:ok, %Channel{}}

      iex> update_channel(channel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_channel(%Channel{} = channel, attrs) do
    channel
    |> Channel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a channel.

  ## Examples

      iex> delete_channel(channel)
      {:ok, %Channel{}}

      iex> delete_channel(channel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_channel(%Channel{} = channel) do
    Repo.delete(channel)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking channel changes.

  ## Examples

      iex> change_channel(channel)
      %Ecto.Changeset{data: %Channel{}}

  """
  def change_channel(%Channel{} = channel, attrs \\ %{}) do
    Channel.changeset(channel, attrs)
  end

  alias ProjeXpert.Chats.ChannelUser

  @doc """
  Returns the list of channel_users.

  ## Examples

      iex> list_channel_users()
      [%ChannelUser{}, ...]

  """
  def list_channel_users do
    Repo.all(ChannelUser)
  end

  @doc """
  Gets a single channel_user.

  Raises `Ecto.NoResultsError` if the Channel user does not exist.

  ## Examples

      iex> get_channel_user!(123)
      %ChannelUser{}

      iex> get_channel_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_channel_user!(id), do: Repo.get!(ChannelUser, id)

  @doc """
  Creates a channel_user.

  ## Examples

      iex> create_channel_user(%{field: value})
      {:ok, %ChannelUser{}}

      iex> create_channel_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_channel_user(attrs \\ %{}) do
    %ChannelUser{}
    |> ChannelUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a channel_user.

  ## Examples

      iex> update_channel_user(channel_user, %{field: new_value})
      {:ok, %ChannelUser{}}

      iex> update_channel_user(channel_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_channel_user(%ChannelUser{} = channel_user, attrs) do
    channel_user
    |> ChannelUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a channel_user.

  ## Examples

      iex> delete_channel_user(channel_user)
      {:ok, %ChannelUser{}}

      iex> delete_channel_user(channel_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_channel_user(%ChannelUser{} = channel_user) do
    Repo.delete(channel_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking channel_user changes.

  ## Examples

      iex> change_channel_user(channel_user)
      %Ecto.Changeset{data: %ChannelUser{}}

  """
  def change_channel_user(%ChannelUser{} = channel_user, attrs \\ %{}) do
    ChannelUser.changeset(channel_user, attrs)
  end

  alias ProjeXpert.Chats.Message

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end
end
