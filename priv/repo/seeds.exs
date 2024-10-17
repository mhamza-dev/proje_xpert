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

alias ProjeXpert.Tasks.{
  Bid,
  Comment,
  Column,
  Project,
  # Payment,
  Task,
  WorkerProject,
  WorkerTask,
  Reply
}

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
        role: :worker,
        # Random rating between 0.00 to 5.00
        rating: Float.round(:rand.uniform() * 5, 2)
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

# Create projects with realistic titles and descriptions
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
  "Data Migration for Legacy Systems"
]

project_descriptions = [
  "Develop a fully functional e-commerce website that allows users to buy and sell products. The site should include features such as user authentication, product listings, payment integration, and a responsive design.",
  "Create a mobile application for fitness tracking that enables users to log their workouts, track their progress, and share achievements with friends. The app should have a user-friendly interface and real-time notifications.",
  "Manage a marketing campaign across multiple platforms. The project involves developing creative content, setting up advertisements, and analyzing performance metrics to ensure a successful campaign.",
  "Build an online learning platform that offers courses, quizzes, and student progress tracking. Features should include video integration, user dashboards, and a secure payment gateway.",
  "Develop a custom CRM that helps businesses manage customer interactions, sales, and feedback. The project should focus on creating an intuitive interface and robust reporting capabilities.",
  "Design and implement a social media management application that allows users to schedule posts, track engagement metrics, and analyze performance across different social media platforms.",
  "Create engaging content for a blog that attracts readers and boosts SEO. Tasks will include researching topics, writing articles, and optimizing content for search engines.",
  "Optimize an existing e-commerce website for search engines, focusing on improving page load speeds, keyword targeting, and overall user experience.",
  "Build a financial dashboard that consolidates various data sources into one interface. Users should be able to visualize their financial data through graphs and charts.",
  "Develop a real estate listings portal that allows users to browse and filter properties. The project should include user reviews, a map feature, and a contact form for inquiries."
]

for i <- 1..30 do
  project =
    Repo.insert!(%Project{
      title: Enum.at(project_titles, rem(i - 1, length(project_titles))),
      description: Enum.at(project_descriptions, rem(i - 1, length(project_descriptions))),
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
      "<p>This task involves #{task_title} for the #{Enum.at(project_titles, rem(i - 1, length(project_titles)))}. " <>
        "Key requirements include defining user personas, designing mockups, developing APIs, or executing rigorous testing protocols to ensure quality.</p>"

    tags = ["#{task_title}", "Development", "Project Management", "Team Collaboration"]

    attachments = [
      "https://example.com/image1.jpg",
      "https://example.com/image2.jpg",
      "https://example.com/image3.jpg"
    ]

    find_worker? = Enum.random([true, false])

    task =
      Repo.insert!(%Task{
        title: task_title,
        description: task_description,
        is_completed?: if(find_worker?, do: Enum.random([true, false]), else: false),
        find_worker?: Enum.random([true, false]),
        budget: Decimal.new(Enum.random(1000..10000)),
        deadline: deadline,
        column_id: column1.id,
        project_id: project.id,
        attachments: attachments,
        tags: tags,
        # Random experience level
        experience_required: Enum.random([:beginner, :intermediate, :expert])
      })

    # Add bids for tasks
    Enum.each(Enum.take_random(created_workers, 5), fn worker ->
      if task.find_worker? do
        Repo.insert!(%Bid{
          amount: Decimal.new(Enum.random(100..1000)),
          status: :submitted,
          description:
            "<p>I have experience in similar tasks and can complete this efficiently.</p>",
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
        if j == Enum.random(3..5) do
          Tasks.update_task(task, %{"column_id" => column3.id, "is_completed?" => true})
        else
          Tasks.update_task(task, %{"column_id" => column2.id})
        end

        Repo.insert!(%WorkerTask{
          worker_id: bid.worker_id,
          task_id: task.id
        })
      end
    end

    # Add comments and replies
    Enum.each(1..3, fn _ ->
      client = Enum.random(created_clients)

      comment =
        Repo.insert!(%Comment{
          message: "This is a comment on task: #{task.title}.",
          task_id: task.id,
          user_id: client.id
        })

      Enum.each(1..3, fn index ->
        worker = Enum.random(created_workers)
        user = if rem(index, 2) == 0, do: client, else: worker

        Repo.insert!(%Reply{
          message:
            "This is a reply to comment: #{comment.id} by #{user.first_name} #{user.last_name}.",
          comment_id: comment.id,
          user_id: user.id
        })
      end)
    end)
  end
end
