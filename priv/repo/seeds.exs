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
alias ProjeXpert.Tasks.{Bid, Chat, Column, Project, Payment, Task, WorkerProject, WorkerTask}

# Create some users
clients = [
  %{first_name: "Alice", last_name: "Doe", email: "alice@example.com"},
  %{first_name: "Jessica", last_name: "Rodriguez", email: "jessica.r@example.com"}
]

workers = [
  %{first_name: "Bob", last_name: "Smith", email: "bob.smith@example.com"},
  %{first_name: "Charlie", last_name: "Johnson", email: "charlie.j@example.com"},
  %{first_name: "Diana", last_name: "Brown", email: "diana.brown@example.com"},
  %{first_name: "Ethan", last_name: "Williams", email: "ethan.w@example.com"},
  %{first_name: "Fiona", last_name: "Jones", email: "fiona.jones@example.com"},
  %{first_name: "George", last_name: "Davis", email: "george.d@example.com"},
  %{first_name: "Hannah", last_name: "Garcia", email: "hannah.g@example.com"},
  %{first_name: "Ian", last_name: "Martinez", email: "ian.martinez@example.com"},
  %{first_name: "Kyle", last_name: "Lopez", email: "kyle.lopez@example.com"},
  %{first_name: "Lily", last_name: "Gonzalez", email: "lily.g@example.com"},
  %{first_name: "Mason", last_name: "Wilson", email: "mason.w@example.com"},
  %{first_name: "Nina", last_name: "Anderson", email: "nina.a@example.com"},
  %{first_name: "Oliver", last_name: "Thomas", email: "oliver.thomas@example.com"},
  %{first_name: "Paula", last_name: "Taylor", email: "paula.t@example.com"},
  %{first_name: "Quentin", last_name: "Moore", email: "quentin.moore@example.com"},
  %{first_name: "Rachel", last_name: "White", email: "rachel.w@example.com"},
  %{first_name: "Samuel", last_name: "Harris", email: "samuel.h@example.com"},
  %{first_name: "Tina", last_name: "Clark", email: "tina.clark@example.com"}
]

created_workers =
  Enum.map(
    workers,
    fn user ->
      params = %{
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        password: "Pa$$w0rd!",
        role: :worker
      }

      %User{}
      |> User.seed_changeset(params)
      |> Repo.insert!()
    end
  )

created_clients =
  Enum.map(
    clients,
    fn user ->
      params = %{
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        password: "Pa$$w0rd!",
        role: :client
      }

      %User{}
      |> User.seed_changeset(params)
      |> Repo.insert!()
    end
  )

# Create 30 projects with more realistic titles and descriptions

project_titles = [
  "E-commerce Website Development",
  "Mobile App for Fitness Tracking",
  "Marketing Campaign Management",
  "Online Learning Platform",
  "Custom CRM Development",
  "Social Media Management App",
  "Content Creation for Blog",
  "SEO Optimization for E-commerce",
  "Financial Dashboard Development",
  "Real Estate Listings Portal",
  "Food Delivery Mobile App",
  "Event Booking Platform",
  "Inventory Management System",
  "Custom API for Payment Gateway",
  "HR Management System",
  "Fleet Management Software",
  "Booking System for Doctors",
  "Task Management Tool",
  "Custom Reporting Dashboard",
  "Data Migration for Legacy Systems",
  "Mobile App Redesign",
  "Online Marketplace for Handmade Goods",
  "Business Process Automation",
  "AI-powered Chatbot for Customer Support",
  "Travel Planning App",
  "Restaurant Reservation System",
  "Freelancer Hiring Platform",
  "Cloud Storage Integration",
  "Home Automation App",
  "Web Application Security Enhancement"
]

for i <- 1..30 do
  project =
    Repo.insert!(%Project{
      title: Enum.at(project_titles, i - 1),
      description:
        "<p>This project involves building or enhancing #{Enum.at(project_titles, i - 1)}. The goal is to create a functional, user-friendly, and scalable solution that caters to the needs of the client. This includes implementing features such as user authentication, data management, responsive design, and integration with third-party services. The project will require collaboration with designers, developers, and testers to ensure the final product meets the required specifications.<p>",
      status: Enum.random(Project.all_statuses()),
      budget: Decimal.new(Enum.random(1000..10000)),
      client_id: Enum.random(created_clients).id
    })

  Repo.insert!(%WorkerProject{
    worker_id: Enum.random(created_workers).id,
    project_id: project.id
  })

  # Create columns for the project
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

  # Add tasks for each project, distributed across columns
  for j <- 1..Enum.random(3..5) do
    deadline = Date.new!(2024, Enum.random(1..12), Enum.random(1..28))

    task_title =
      case j do
        1 -> "Research and Requirement Gathering"
        2 -> "UI/UX Design"
        3 -> "Backend Development"
        4 -> "Frontend Development"
        5 -> "Testing and QA"
      end

    task_description =
      "<p>This task involves #{task_title} for the #{Enum.at(project_titles, i - 1)}. It includes activities such as meeting with stakeholders, designing wireframes, coding backend services, and performing rigorous testing to ensure a high-quality product.<p>"

    task =
      Repo.insert!(%Task{
        title: task_title,
        description: task_description,
        status: Enum.random(Task.all_statuses()),
        find_worker?: Enum.random([true, false]),
        budget: Decimal.new(Enum.random(1000..10000)),
        deadline: deadline,
        column_id: if(j == 1, do: column1.id, else: if(j == 2, do: column2.id, else: column3.id)),
        project_id: project.id
      })

    # Add bids for tasks
    Enum.each(Enum.take_random(created_workers, 5), fn worker ->
      if task.find_worker? do
        Repo.insert!(%Bid{
          amount: Decimal.new(Enum.random(100..1000)),
          status: :submitted,
          description:
            "<p>I have experience in similar tasks and can complete this efficiently.<p>",
          task_id: task.id,
          worker_id: worker.id
        })
      end
    end)

    # Assign worker to task based on accepted bid
    if task.find_worker? do
      task_with_bids = Repo.preload(task, :bids)

      {:ok, bid} =
        task_with_bids.bids
        |> Enum.random()
        |> Tasks.update_bid(%{"status" => :accepted})

      if bid.status == :accepted do
        Repo.insert!(%WorkerTask{
          worker_id: bid.worker_id,
          task_id: task.id
        })
      end
    end
  end
end

# Create some chat messages
task = Enum.random(Tasks.list_tasks()) |> Repo.preload(project: :client)

Repo.insert!(%Chat{
  message: "Hello! Can you update the project status?",
  sender_id: Enum.random(created_workers).id,
  receiver_id: task.project.client.id,
  task_id: task.id
})

# Create payments for bids
Repo.insert!(%Payment{
  amount: Decimal.new("900.00"),
  status: :pending,
  payment_method: "Credit Card",
  task_id: 1
})
