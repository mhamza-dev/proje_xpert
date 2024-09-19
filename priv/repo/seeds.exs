# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ProjeXpert.Repo.insert!(%ProjeXpert.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# priv/repo/seeds.exs

alias ProjeXpert.Repo
alias ProjeXpert.Accounts.User
alias ProjeXpert.Tasks
alias ProjeXpert.Tasks.{Bid, Chat, Column, Project, Payment, Task}

# Create some users
user1 =
  Repo.insert!(
    User.registration_changeset(%User{}, %{
      first_name: "Alice",
      last_name: "Doe",
      email: "alice@example.com",
      password: "Pa$$w0rd!",
      role: :client
    })
  )

user2 =
  Repo.insert!(
    User.registration_changeset(%User{}, %{
      first_name: "Bob",
      last_name: "Smith",
      email: "bob@example.com",
      password: "Pa$$w0rd!",
      role: :worker
    })
  )

user3 =
  Repo.insert!(
    User.registration_changeset(%User{}, %{
      first_name: "Charlie",
      last_name: "Brown",
      email: "charlie@example.com",
      password: "Pa$$w0rd!",
      role: :worker
    })
  )

Enum.each(
  [user1, user2, user3],
  &Repo.update(User.confirm_changeset(&1))
)

# Create 30 projects

for i <- 1..30 do
  project =
    Repo.insert!(%Project{
      title: "Project #{i}",
      description: "This is the description for Project #{i}.",
      status: Enum.random([:pending, :in_progress, :completed, :on_hold, :cancelled]),
      budget: Decimal.new(Enum.random(1000..10000)),
      client_id: Enum.random([user1.id, user2.id, user3.id])
    })

  # For each project, create columns
  column1 =
    Repo.insert!(%Column{
      name: "Backlog",
      project_id: project.id
    })

  column2 =
    Repo.insert!(%Column{
      name: "In Progress",
      project_id: project.id
    })

  column3 =
    Repo.insert!(%Column{
      name: "Completed",
      project_id: project.id
    })

  # Add 3-5 tasks for each project, distributed across the columns
  for j <- 1..Enum.random(3..5) do
    Repo.insert!(%Task{
      title: "Task #{i}-#{j}",
      description: "This is the description for Task #{i}-#{j}.",
      status: Enum.random([:not_started, :in_progress, :completed, :on_hold, :cancelled]),
      budget: Decimal.new(Enum.random(1000..10000)),
      deadline: Date.utc_today(),
      column_id: if(j == 1, do: column1.id, else: if(j == 2, do: column2.id, else: column3.id)),
      project_id: project.id
    })
  end
end

# Create bids for some tasks
bid =
  Repo.insert!(%Bid{
    amount: Decimal.new("900.00"),
    status: :submitted,
    task_id: Enum.random(Tasks.list_tasks()).id,
    worker_id: user2.id
  })

# Create some chat messages
Repo.insert!(%Chat{
  message: "Hello! Can you update the project status?",
  sender_id: user2.id,
  receiver_id: user1.id,
  task_id: Enum.random(Tasks.list_tasks()).id
})

# Create payments for bids
Repo.insert!(%Payment{
  amount: Decimal.new("900.00"),
  status: :pending,
  payment_method: "Credit Card",
  bid_id: bid.id
})
