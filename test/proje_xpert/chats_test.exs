defmodule ProjeXpert.ChatsTest do
  use ProjeXpert.DataCase

  alias ProjeXpert.Chats

  describe "channels" do
    alias ProjeXpert.Chats.Channel

    import ProjeXpert.ChatsFixtures

    @invalid_attrs %{name: nil}

    test "list_channels/0 returns all channels" do
      channel = channel_fixture()
      assert Chats.list_channels() == [channel]
    end

    test "get_channel!/1 returns the channel with given id" do
      channel = channel_fixture()
      assert Chats.get_channel!(channel.id) == channel
    end

    test "create_channel/1 with valid data creates a channel" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Channel{} = channel} = Chats.create_channel(valid_attrs)
      assert channel.name == "some name"
    end

    test "create_channel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_channel(@invalid_attrs)
    end

    test "update_channel/2 with valid data updates the channel" do
      channel = channel_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Channel{} = channel} = Chats.update_channel(channel, update_attrs)
      assert channel.name == "some updated name"
    end

    test "update_channel/2 with invalid data returns error changeset" do
      channel = channel_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_channel(channel, @invalid_attrs)
      assert channel == Chats.get_channel!(channel.id)
    end

    test "delete_channel/1 deletes the channel" do
      channel = channel_fixture()
      assert {:ok, %Channel{}} = Chats.delete_channel(channel)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_channel!(channel.id) end
    end

    test "change_channel/1 returns a channel changeset" do
      channel = channel_fixture()
      assert %Ecto.Changeset{} = Chats.change_channel(channel)
    end
  end

  describe "messages" do
    alias ProjeXpert.Chats.Message

    import ProjeXpert.ChatsFixtures

    @invalid_attrs %{body: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chats.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chats.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{body: "some body"}

      assert {:ok, %Message{} = message} = Chats.create_message(valid_attrs)
      assert message.body == "some body"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{body: "some updated body"}

      assert {:ok, %Message{} = message} = Chats.update_message(message, update_attrs)
      assert message.body == "some updated body"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_message(message, @invalid_attrs)
      assert message == Chats.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chats.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chats.change_message(message)
    end
  end
end
