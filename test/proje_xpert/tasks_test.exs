defmodule ProjeXpert.TasksTest do
  use ProjeXpert.DataCase

  alias ProjeXpert.Tasks

  describe "projects" do
    alias ProjeXpert.Tasks.Project

    import ProjeXpert.TasksFixtures

    @invalid_attrs %{status: nil, description: nil, title: nil, budget: nil}

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert Tasks.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Tasks.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{
        status: "some status",
        description: "some description",
        title: "some title",
        budget: "120.5"
      }

      assert {:ok, %Project{} = project} = Tasks.create_project(valid_attrs)
      assert project.status == "some status"
      assert project.description == "some description"
      assert project.title == "some title"
      assert project.budget == Decimal.new("120.5")
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()

      update_attrs = %{
        status: "some updated status",
        description: "some updated description",
        title: "some updated title",
        budget: "456.7"
      }

      assert {:ok, %Project{} = project} = Tasks.update_project(project, update_attrs)
      assert project.status == "some updated status"
      assert project.description == "some updated description"
      assert project.title == "some updated title"
      assert project.budget == Decimal.new("456.7")
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_project(project, @invalid_attrs)
      assert project == Tasks.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Tasks.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Tasks.change_project(project)
    end
  end

  describe "tasks" do
    alias ProjeXpert.Tasks.Task

    import ProjeXpert.TasksFixtures

    @invalid_attrs %{status: nil, description: nil, title: nil, deadline: nil, budget: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{
        status: "some status",
        description: "some description",
        title: "some title",
        deadline: ~N[2024-09-13 19:16:00],
        budget: "120.5"
      }

      assert {:ok, %Task{} = task} = Tasks.create_task(valid_attrs)
      assert task.status == "some status"
      assert task.description == "some description"
      assert task.title == "some title"
      assert task.deadline == ~N[2024-09-13 19:16:00]
      assert task.budget == Decimal.new("120.5")
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()

      update_attrs = %{
        status: "some updated status",
        description: "some updated description",
        title: "some updated title",
        deadline: ~N[2024-09-14 19:16:00],
        budget: "456.7"
      }

      assert {:ok, %Task{} = task} = Tasks.update_task(task, update_attrs)
      assert task.status == "some updated status"
      assert task.description == "some updated description"
      assert task.title == "some updated title"
      assert task.deadline == ~N[2024-09-14 19:16:00]
      assert task.budget == Decimal.new("456.7")
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end

  describe "bids" do
    alias ProjeXpert.Tasks.Bid

    import ProjeXpert.TasksFixtures

    @invalid_attrs %{status: nil, amount: nil}

    test "list_bids/0 returns all bids" do
      bid = bid_fixture()
      assert Tasks.list_bids() == [bid]
    end

    test "get_bid!/1 returns the bid with given id" do
      bid = bid_fixture()
      assert Tasks.get_bid!(bid.id) == bid
    end

    test "create_bid/1 with valid data creates a bid" do
      valid_attrs = %{status: "some status", amount: "120.5"}

      assert {:ok, %Bid{} = bid} = Tasks.create_bid(valid_attrs)
      assert bid.status == "some status"
      assert bid.amount == Decimal.new("120.5")
    end

    test "create_bid/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_bid(@invalid_attrs)
    end

    test "update_bid/2 with valid data updates the bid" do
      bid = bid_fixture()
      update_attrs = %{status: "some updated status", amount: "456.7"}

      assert {:ok, %Bid{} = bid} = Tasks.update_bid(bid, update_attrs)
      assert bid.status == "some updated status"
      assert bid.amount == Decimal.new("456.7")
    end

    test "update_bid/2 with invalid data returns error changeset" do
      bid = bid_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_bid(bid, @invalid_attrs)
      assert bid == Tasks.get_bid!(bid.id)
    end

    test "delete_bid/1 deletes the bid" do
      bid = bid_fixture()
      assert {:ok, %Bid{}} = Tasks.delete_bid(bid)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_bid!(bid.id) end
    end

    test "change_bid/1 returns a bid changeset" do
      bid = bid_fixture()
      assert %Ecto.Changeset{} = Tasks.change_bid(bid)
    end
  end

  describe "payments" do
    alias ProjeXpert.Tasks.Payment

    import ProjeXpert.TasksFixtures

    @invalid_attrs %{status: nil, amount: nil, payment_method: nil}

    test "list_payments/0 returns all payments" do
      payment = payment_fixture()
      assert Tasks.list_payments() == [payment]
    end

    test "get_payment!/1 returns the payment with given id" do
      payment = payment_fixture()
      assert Tasks.get_payment!(payment.id) == payment
    end

    test "create_payment/1 with valid data creates a payment" do
      valid_attrs = %{
        status: "some status",
        amount: "120.5",
        payment_method: "some payment_method"
      }

      assert {:ok, %Payment{} = payment} = Tasks.create_payment(valid_attrs)
      assert payment.status == "some status"
      assert payment.amount == Decimal.new("120.5")
      assert payment.payment_method == "some payment_method"
    end

    test "create_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_payment(@invalid_attrs)
    end

    test "update_payment/2 with valid data updates the payment" do
      payment = payment_fixture()

      update_attrs = %{
        status: "some updated status",
        amount: "456.7",
        payment_method: "some updated payment_method"
      }

      assert {:ok, %Payment{} = payment} = Tasks.update_payment(payment, update_attrs)
      assert payment.status == "some updated status"
      assert payment.amount == Decimal.new("456.7")
      assert payment.payment_method == "some updated payment_method"
    end

    test "update_payment/2 with invalid data returns error changeset" do
      payment = payment_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_payment(payment, @invalid_attrs)
      assert payment == Tasks.get_payment!(payment.id)
    end

    test "delete_payment/1 deletes the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{}} = Tasks.delete_payment(payment)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_payment!(payment.id) end
    end

    test "change_payment/1 returns a payment changeset" do
      payment = payment_fixture()
      assert %Ecto.Changeset{} = Tasks.change_payment(payment)
    end
  end

  describe "chats" do
    alias ProjeXpert.Tasks.Chat

    import ProjeXpert.TasksFixtures

    @invalid_attrs %{message: nil}

    test "list_chats/0 returns all chats" do
      chat = chat_fixture()
      assert Tasks.list_chats() == [chat]
    end

    test "get_chat!/1 returns the chat with given id" do
      chat = chat_fixture()
      assert Tasks.get_chat!(chat.id) == chat
    end

    test "create_chat/1 with valid data creates a chat" do
      valid_attrs = %{message: "some message"}

      assert {:ok, %Chat{} = chat} = Tasks.create_chat(valid_attrs)
      assert chat.message == "some message"
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_chat(@invalid_attrs)
    end

    test "update_chat/2 with valid data updates the chat" do
      chat = chat_fixture()
      update_attrs = %{message: "some updated message"}

      assert {:ok, %Chat{} = chat} = Tasks.update_chat(chat, update_attrs)
      assert chat.message == "some updated message"
    end

    test "update_chat/2 with invalid data returns error changeset" do
      chat = chat_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_chat(chat, @invalid_attrs)
      assert chat == Tasks.get_chat!(chat.id)
    end

    test "delete_chat/1 deletes the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{}} = Tasks.delete_chat(chat)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_chat!(chat.id) end
    end

    test "change_chat/1 returns a chat changeset" do
      chat = chat_fixture()
      assert %Ecto.Changeset{} = Tasks.change_chat(chat)
    end
  end

  describe "columns" do
    alias ProjeXpert.Tasks.Column

    import ProjeXpert.TasksFixtures

    @invalid_attrs %{name: nil}

    test "list_columns/0 returns all columns" do
      column = column_fixture()
      assert Tasks.list_columns() == [column]
    end

    test "get_column!/1 returns the column with given id" do
      column = column_fixture()
      assert Tasks.get_column!(column.id) == column
    end

    test "create_column/1 with valid data creates a column" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Column{} = column} = Tasks.create_column(valid_attrs)
      assert column.name == "some name"
    end

    test "create_column/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_column(@invalid_attrs)
    end

    test "update_column/2 with valid data updates the column" do
      column = column_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Column{} = column} = Tasks.update_column(column, update_attrs)
      assert column.name == "some updated name"
    end

    test "update_column/2 with invalid data returns error changeset" do
      column = column_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_column(column, @invalid_attrs)
      assert column == Tasks.get_column!(column.id)
    end

    test "delete_column/1 deletes the column" do
      column = column_fixture()
      assert {:ok, %Column{}} = Tasks.delete_column(column)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_column!(column.id) end
    end

    test "change_column/1 returns a column changeset" do
      column = column_fixture()
      assert %Ecto.Changeset{} = Tasks.change_column(column)
    end
  end

  describe "worker_projects" do
    alias ProjeXpert.Tasks.WorkerProject

    import ProjeXpert.TasksFixtures

    @invalid_attrs %{}

    test "list_worker_projects/0 returns all worker_projects" do
      worker_project = worker_project_fixture()
      assert Tasks.list_worker_projects() == [worker_project]
    end

    test "get_worker_project!/1 returns the worker_project with given id" do
      worker_project = worker_project_fixture()
      assert Tasks.get_worker_project!(worker_project.id) == worker_project
    end

    test "create_worker_project/1 with valid data creates a worker_project" do
      valid_attrs = %{}

      assert {:ok, %WorkerProject{} = worker_project} = Tasks.create_worker_project(valid_attrs)
    end

    test "create_worker_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_worker_project(@invalid_attrs)
    end

    test "update_worker_project/2 with valid data updates the worker_project" do
      worker_project = worker_project_fixture()
      update_attrs = %{}

      assert {:ok, %WorkerProject{} = worker_project} =
               Tasks.update_worker_project(worker_project, update_attrs)
    end

    test "update_worker_project/2 with invalid data returns error changeset" do
      worker_project = worker_project_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Tasks.update_worker_project(worker_project, @invalid_attrs)

      assert worker_project == Tasks.get_worker_project!(worker_project.id)
    end

    test "delete_worker_project/1 deletes the worker_project" do
      worker_project = worker_project_fixture()
      assert {:ok, %WorkerProject{}} = Tasks.delete_worker_project(worker_project)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_worker_project!(worker_project.id) end
    end

    test "change_worker_project/1 returns a worker_project changeset" do
      worker_project = worker_project_fixture()
      assert %Ecto.Changeset{} = Tasks.change_worker_project(worker_project)
    end
  end

  describe "worker_tasks" do
    alias ProjeXpert.Tasks.WorkerTask

    import ProjeXpert.TasksFixtures

    @invalid_attrs %{}

    test "list_worker_tasks/0 returns all worker_tasks" do
      worker_task = worker_task_fixture()
      assert Tasks.list_worker_tasks() == [worker_task]
    end

    test "get_worker_task!/1 returns the worker_task with given id" do
      worker_task = worker_task_fixture()
      assert Tasks.get_worker_task!(worker_task.id) == worker_task
    end

    test "create_worker_task/1 with valid data creates a worker_task" do
      valid_attrs = %{}

      assert {:ok, %WorkerTask{} = worker_task} = Tasks.create_worker_task(valid_attrs)
    end

    test "create_worker_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_worker_task(@invalid_attrs)
    end

    test "update_worker_task/2 with valid data updates the worker_task" do
      worker_task = worker_task_fixture()
      update_attrs = %{}

      assert {:ok, %WorkerTask{} = worker_task} = Tasks.update_worker_task(worker_task, update_attrs)
    end

    test "update_worker_task/2 with invalid data returns error changeset" do
      worker_task = worker_task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_worker_task(worker_task, @invalid_attrs)
      assert worker_task == Tasks.get_worker_task!(worker_task.id)
    end

    test "delete_worker_task/1 deletes the worker_task" do
      worker_task = worker_task_fixture()
      assert {:ok, %WorkerTask{}} = Tasks.delete_worker_task(worker_task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_worker_task!(worker_task.id) end
    end

    test "change_worker_task/1 returns a worker_task changeset" do
      worker_task = worker_task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_worker_task(worker_task)
    end
  end
end
