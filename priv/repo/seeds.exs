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
  %{
    first_name: "Alice",
    last_name: "Doe",
    email: "alice@example.com",
    location: "New York, NY",
    bio: "<p>Dynamic entrepreneur with a passion for tech.</p>"
  },
  %{
    first_name: "Jessica",
    last_name: "Rodriguez",
    email: "jessica.r@example.com",
    location: "Los Angeles, CA",
    bio: "<p>Creative designer with an eye for detail.</p>"
  }
]

workers = [
  %{
    first_name: "Bob",
    last_name: "Smith",
    email: "bob.smith@example.com",
    location: "Chicago, IL",
    bio: "<p>Skilled developer with 5 years of experience.</p>"
  },
  %{
    first_name: "Charlie",
    last_name: "Johnson",
    email: "charlie.j@example.com",
    location: "Houston, TX",
    bio: "<p>Full-stack engineer who loves coding.</p>"
  },
  %{
    first_name: "Diana",
    last_name: "Brown",
    email: "diana.brown@example.com",
    location: "Phoenix, AZ",
    bio: "<p>Passionate project manager with a knack for organization.</p>"
  },
  %{
    first_name: "Ethan",
    last_name: "Williams",
    email: "ethan.w@example.com",
    location: "Philadelphia, PA",
    bio: "<p>Data analyst with expertise in insights.</p>"
  },
  %{
    first_name: "Fiona",
    last_name: "Jones",
    email: "fiona.jones@example.com",
    location: "San Antonio, TX",
    bio: "<p>UX/UI designer focused on user experience.</p>"
  },
  %{
    first_name: "George",
    last_name: "Davis",
    email: "george.d@example.com",
    location: "San Diego, CA",
    bio: "<p>Web developer with a passion for innovation.</p>"
  },
  %{
    first_name: "Hannah",
    last_name: "Garcia",
    email: "hannah.g@example.com",
    location: "Dallas, TX",
    bio: "<p>Marketing strategist with a creative edge.</p>"
  },
  %{
    first_name: "Ian",
    last_name: "Martinez",
    email: "ian.martinez@example.com",
    location: "San Jose, CA",
    bio: "<p>Software engineer with a focus on efficiency.</p>"
  },
  %{
    first_name: "Kyle",
    last_name: "Lopez",
    email: "kyle.lopez@example.com",
    location: "Austin, TX",
    bio: "<p>Cybersecurity expert dedicated to protecting data.</p>"
  },
  %{
    first_name: "Lily",
    last_name: "Gonzalez",
    email: "lily.g@example.com",
    location: "Jacksonville, FL",
    bio: "<p>Content creator who loves storytelling.</p>"
  },
  %{
    first_name: "Mason",
    last_name: "Wilson",
    email: "mason.w@example.com",
    location: "San Francisco, CA",
    bio: "<p>Tech enthusiast and software developer.</p>"
  },
  %{
    first_name: "Nina",
    last_name: "Anderson",
    email: "nina.a@example.com",
    location: "Columbus, OH",
    bio: "<p>Graphic designer with a passion for visuals.</p>"
  },
  %{
    first_name: "Oliver",
    last_name: "Thomas",
    email: "oliver.thomas@example.com",
    location: "Fort Worth, TX",
    bio: "<p>Entrepreneur with a love for innovation.</p>"
  },
  %{
    first_name: "Paula",
    last_name: "Taylor",
    email: "paula.t@example.com",
    location: "Charlotte, NC",
    bio: "<p>SEO specialist with a data-driven mindset.</p>"
  },
  %{
    first_name: "Quentin",
    last_name: "Moore",
    email: "quentin.moore@example.com",
    location: "Seattle, WA",
    bio: "<p>Product manager with a focus on user feedback.</p>"
  },
  %{
    first_name: "Rachel",
    last_name: "White",
    email: "rachel.w@example.com",
    location: "Denver, CO",
    bio: "<p>Tech consultant with a passion for solutions.</p>"
  },
  %{
    first_name: "Samuel",
    last_name: "Harris",
    email: "samuel.h@example.com",
    location: "Washington, DC",
    bio: "<p>Database administrator with a focus on security.</p>"
  },
  %{
    first_name: "Tina",
    last_name: "Clark",
    email: "tina.clark@example.com",
    location: "Boston, MA",
    bio: "<p>Business analyst with a keen analytical mind.</p>"
  }
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
        rating: Float.round(:rand.uniform() * 5, 2),
        location: user.location,
        bio: user.bio
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
        role: :client,
        rating: Float.round(:rand.uniform() * 5, 2),
        location: user.location,
        bio: user.bio
      }

      %User{}
      |> User.seed_changeset(params)
      |> Repo.insert!()
    end
  )

# Create projects with realistic titles and descriptions
projects = [
  %{
    title: "E-commerce Website Development",
    description:
      "<p>Develop a fully functional e-commerce website with features like product listing, payment gateway integration, user authentication, and order tracking.</p>"
  },
  %{
    title: "Mobile App for Fitness Tracking",
    description:
      "<p>Create a mobile application that helps users track their fitness goals, workouts, and diet plans, while offering progress analytics and motivational features.</p>"
  },
  %{
    title: "Marketing Campaign Management",
    description:
      "<p>Build a platform to manage and track marketing campaigns across email, social media, and ad platforms with comprehensive performance metrics.</p>"
  },
  %{
    title: "Online Learning Platform",
    description:
      "<p>Develop an online learning system offering video tutorials, quizzes, certification, and user progress tracking for a variety of courses.</p>"
  },
  %{
    title: "Custom CRM Development",
    description:
      "<p>Create a custom CRM system for businesses to manage customer relationships, leads, sales processes, and customer support tickets efficiently.</p>"
  },
  %{
    title: "Social Media Management App",
    description:
      "<p>Develop an app that allows users to schedule, publish, and monitor posts on various social media platforms from a single dashboard.</p>"
  },
  %{
    title: "Content Creation for Blog",
    description:
      "<p>Create engaging, SEO-optimized blog content focused on improving website visibility and driving traffic.</p>"
  },
  %{
    title: "SEO Optimization for E-commerce",
    description:
      "<p>Optimize an e-commerce website for search engines by improving page speed, keywords, meta tags, and structured data implementation.</p>"
  },
  %{
    title: "Financial Dashboard Development",
    description:
      "<p>Build an interactive financial dashboard that provides real-time data visualization of financial metrics such as cash flow, expenses, and revenue.</p>"
  },
  %{
    title: "Real Estate Listings Portal",
    description:
      "<p>Develop a real estate platform where users can browse, filter, and view property listings with detailed descriptions and map integration.</p>"
  },
  %{
    title: "Food Delivery Mobile App",
    description:
      "<p>Create a mobile app that allows users to browse local restaurants, order food, and track delivery with integrated payment options.</p>"
  },
  %{
    title: "Event Booking Platform",
    description:
      "<p>Build an online system for booking events, venues, and managing tickets, featuring real-time availability updates and secure payments.</p>"
  },
  %{
    title: "Inventory Management System",
    description:
      "<p>Develop a system for businesses to track inventory levels, manage suppliers, and automate stock replenishment for efficient operations.</p>"
  },
  %{
    title: "Custom API for Payment Gateway",
    description:
      "<p>Create a custom API that integrates with multiple payment gateways, enabling seamless payment processing for online transactions.</p>"
  },
  %{
    title: "HR Management System",
    description:
      "<p>Develop an HR management system to handle employee data, payroll, attendance tracking, and performance reviews in one central platform.</p>"
  },
  %{
    title: "Fleet Management Software",
    description:
      "<p>Create a system for managing a fleet of vehicles, providing real-time tracking, maintenance schedules, and driver performance reports.</p>"
  },
  %{
    title: "Booking System for Doctors",
    description:
      "<p>Develop a booking platform where patients can schedule appointments with doctors, view availability, and receive reminders for their visits.</p>"
  },
  %{
    title: "Task Management Tool",
    description:
      "<p>Build a task management application that allows users to create, assign, and track tasks within teams, with project timelines and reporting features.</p>"
  },
  %{
    title: "Custom Reporting Dashboard",
    description:
      "<p>Create a customizable reporting dashboard for businesses to visualize key metrics and generate reports based on real-time data analytics.</p>"
  },
  %{
    title: "Data Migration for Legacy Systems",
    description:
      "<p>Develop a solution to migrate data from outdated systems to modern infrastructure, ensuring minimal disruption and data integrity during the process.</p>"
  },
  %{
    title: "Subscription-Based Video Streaming Platform",
    description:
      "<p>Create a platform for hosting video content, offering subscription services, content recommendations, and user analytics for growth tracking.</p>"
  },
  %{
    title: "Restaurant Reservation System",
    description:
      "<p>Build an online reservation system for restaurants, allowing users to view table availability, book tables, and receive confirmation notifications.</p>"
  },
  %{
    title: "Personal Finance App",
    description:
      "<p>Create a personal finance mobile app that helps users track their income, expenses, set budgets, and visualize financial goals.</p>"
  },
  %{
    title: "Ride-Hailing Service Platform",
    description:
      "<p>Develop a mobile app and backend system for a ride-hailing service, including driver management, trip tracking, and secure payment integration.</p>"
  },
  %{
    title: "Online Grocery Delivery Service",
    description:
      "<p>Create a platform for users to order groceries online with scheduled deliveries, product availability tracking, and payment integration.</p>"
  },
  %{
    title: "Property Management Software",
    description:
      "<p>Build a software solution for property managers to track tenants, leases, maintenance requests, and rental payments efficiently.</p>"
  },
  %{
    title: "Telemedicine App Development",
    description:
      "<p>Develop a telemedicine platform where patients can consult with doctors remotely through video calls, chat, and access digital prescriptions.</p>"
  },
  %{
    title: "Custom ERP System Development",
    description:
      "<p>Create a custom ERP system for businesses to manage their operations, including finance, inventory, procurement, and human resources.</p>"
  },
  %{
    title: "Logistics and Warehouse Management System",
    description:
      "<p>Develop a system to streamline logistics and warehouse operations, offering real-time tracking, order fulfillment, and inventory management.</p>"
  },
  %{
    title: "Blockchain-Based Voting System",
    description:
      "<p>Build a secure blockchain-based voting platform that ensures transparency and tamper-proof voting processes for organizations or elections.</p>"
  }
]

for proj <- projects do
  project =
    Repo.insert!(%Project{
      title: proj.title,
      description: proj.description,
      status: Enum.random(Project.all_statuses()),
      budget: Decimal.new(Enum.random(1000..10000)),
      client_id: Enum.random(created_clients).id
    })

  Repo.insert!(%WorkerProject{
    worker_id: Enum.random(created_workers).id,
    project_id: project.id
  })

  # Create columns for the project

  [column1, column2, column3] =
    Enum.map(
      Column.get_default_columns(),
      &Repo.insert!(%Column{
        name: &1,
        project_id: project.id
      })
    )

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
      "<p>This task involves #{task_title} for the #{project.title}. " <>
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
      attached_files =
        Enum.map(1..4, fn _ ->
          "https://asset.cloudinary.com/dmkkivjv3/cb13850a32552725cc83943f00496892"
        end)

      if task.find_worker? do
        Repo.insert!(%Bid{
          amount: Decimal.new(Enum.random(100..1000)),
          status: :submitted,
          description: """
            <p>
              <p>Dear [Hiring Manager],</p>
              <p>
                  I am writing to express my interest in the Frontend Developer position for your E-commerce Website Development project. With a strong background in web development and hands-on experience in building scalable, user-friendly interfaces, I am confident in my ability to contribute to the success of your project.
              </p>
              <p>
                  I understand that this task involves key responsibilities such as defining user personas, designing mockups, developing APIs, and executing rigorous testing protocols to ensure a high-quality product. My experience in designing intuitive UIs and developing dynamic frontends with React, Vue.js, or Angular has equipped me to meet these challenges. I also have a strong grasp of API integration and best practices for frontend testing to deliver seamless user experiences.
              </p>
              <p>
                  My technical expertise, combined with a passion for delivering quality, aligns well with the requirements of this project. I am excited about the opportunity to contribute to an innovative e-commerce platform that delivers both functionality and a great user experience.
              </p>
              <p>
                  Thank you for considering my application. I look forward to the opportunity to discuss how my skills can align with your team’s needs.
              </p>
              <p>Best regards,<br>
              <strong>[Your Name]</strong>
              </p>
            </p>
          """,
          task_id: task.id,
          worker_id: worker.id,
          attached_files: attached_files
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
