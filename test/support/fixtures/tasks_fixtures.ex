defmodule ProjeXpert.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ProjeXpert.Tasks` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        budget: "120.5",
        description: "some description",
        status: "some status",
        title: "some title"
      })
      |> ProjeXpert.Tasks.create_project()

    project
  end

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        budget: "120.5",
        deadline: ~N[2024-09-13 19:16:00],
        description: "some description",
        status: "some status",
        title: "some title"
      })
      |> ProjeXpert.Tasks.create_task()

    task
  end

  @doc """
  Generate a bid.
  """
  def bid_fixture(attrs \\ %{}) do
    {:ok, bid} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        status: "some status"
      })
      |> ProjeXpert.Tasks.create_bid()

    bid
  end

  @doc """
  Generate a payment.
  """
  def payment_fixture(attrs \\ %{}) do
    {:ok, payment} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        payment_method: "some payment_method",
        status: "some status"
      })
      |> ProjeXpert.Tasks.create_payment()

    payment
  end

  @doc """
  Generate a comment.
  """
  def chat_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        message: "some message"
      })
      |> ProjeXpert.Tasks.create_comment()

    comment
  end

  @doc """
  Generate a column.
  """
  def column_fixture(attrs \\ %{}) do
    {:ok, column} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> ProjeXpert.Tasks.create_column()

    column
  end

  @doc """
  Generate a freelancer_project.
  """
  def freelancer_project_fixture(attrs \\ %{}) do
    {:ok, freelancer_project} =
      attrs
      |> Enum.into(%{})
      |> ProjeXpert.Tasks.create_freelancer_project()

    freelancer_project
  end

  @doc """
  Generate a reply.
  """
  def reply_fixture(attrs \\ %{}) do
    {:ok, reply} =
      attrs
      |> Enum.into(%{})
      |> ProjeXpert.Tasks.create_reply()

    reply
  end

  @doc """
  Generate a sprint.
  """
  def sprint_fixture(attrs \\ %{}) do
    {:ok, sprint} =
      attrs
      |> Enum.into(%{
        end_date: ~D[2024-11-18],
        start_date: ~D[2024-11-18],
        title: "some title"
      })
      |> ProjeXpert.Tasks.create_sprint()

    sprint
  end
end
