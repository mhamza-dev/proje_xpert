defmodule ProjeXpert.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ProjeXpert.Chats` context.
  """

  @doc """
  Generate a channel.
  """
  def channel_fixture(attrs \\ %{}) do
    {:ok, channel} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> ProjeXpert.Chats.create_channel()

    channel
  end

  @doc """
  Generate a channel_user.
  """
  def channel_user_fixture(attrs \\ %{}) do
    {:ok, channel_user} =
      attrs
      |> Enum.into(%{

      })
      |> ProjeXpert.Chats.create_channel_user()

    channel_user
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> ProjeXpert.Chats.create_message()

    message
  end
end
