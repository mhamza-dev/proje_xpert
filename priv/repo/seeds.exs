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

alias ProjeXpert.Accounts
alias ProjeXpert.Accounts.{Notification, NotificationPreference, User}
alias ProjeXpert.Chats.{Channel, Message}
alias ProjeXpert.Repo
alias ProjeXpert.Tasks

alias ProjeXpert.Tasks.{
  Bid,
  Comment,
  Column,
  Project,
  # Payment,
  Task,
  Reply
}

import ProjeXpertWeb.LiveHelpers

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

freelancers = [
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

notification_preferences = [
  %{email: false, sms: false, push: true},
  %{email: true, sms: false, push: true},
  %{email: false, sms: true, push: true},
  %{email: true, sms: true, push: true}
]

created_freelancers =
  Enum.map(
    freelancers,
    fn user ->
      params = %{
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        password: "Pa$$w0rd!",
        role: :freelancer,
        rating: Float.round(:rand.uniform() * 5, 2),
        location: user.location,
        bio: user.bio
      }

      user =
        %User{}
        |> User.seed_changeset(params)
        |> Repo.insert!()

      np_params = Map.put(Enum.random(notification_preferences), :user_id, user.id)

      %NotificationPreference{}
      |> NotificationPreference.changeset(np_params)
      |> Repo.insert!()

      user
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

      user =
        %User{}
        |> User.seed_changeset(params)
        |> Repo.insert!()

      np_params = Map.put(Enum.random(notification_preferences), :user_id, user.id)

      %NotificationPreference{}
      |> NotificationPreference.changeset(np_params)
      |> Repo.insert!()

      user
    end
  )

# Create projects with realistic titles and descriptions
projects =
  [
    %{
      title: "E-commerce Website Development",
      description:
        "<p>Develop a comprehensive e-commerce website that caters to businesses aiming to establish a robust online presence. This project will include essential e-commerce features for a seamless user experience and optimized sales flow.</p>
      <ul>
        <li><strong>Product Listing:</strong> Display products with detailed descriptions, high-quality images, prices, and reviews.</li>
        <li><strong>User-friendly Navigation:</strong> Design intuitive menus and category filters to help customers find products effortlessly.</li>
        <li><strong>Secure Payment Gateway Integration:</strong> Enable safe transactions through major payment methods, ensuring data security and reliability.</li>
        <li><strong>User Authentication:</strong> Create accounts for customers to securely track orders, save favorite items, and manage profiles.</li>
        <li><strong>Order Tracking:</strong> Provide real-time tracking information for orders to keep customers informed throughout the delivery process.</li>
      </ul>
      <p>This e-commerce solution will not only boost customer engagement but also drive revenue growth through a streamlined and highly functional platform.</p>"
    },
    %{
      title: "Mobile App for Fitness Tracking",
      description:
        "<p>Develop a dynamic mobile application tailored for fitness enthusiasts looking to monitor their progress and achieve fitness goals. This app will motivate users to stay consistent by providing a variety of tracking and personalization features.</p>
      <ul>
        <li><strong>Goal Tracking:</strong> Allow users to set fitness goals, such as weight loss, muscle gain, or endurance improvement.</li>
        <li><strong>Workout Plans:</strong> Offer customizable workout routines for all fitness levels, complete with video demonstrations.</li>
        <li><strong>Diet Tracking:</strong> Provide meal logging and calorie counting to support users’ nutritional goals.</li>
        <li><strong>Progress Analytics:</strong> Include visual representations of users' progress over time, helping them stay motivated.</li>
        <li><strong>Motivational Features:</strong> Integrate reminders, challenges, and achievement badges to keep users engaged.</li>
      </ul>
      <p>This fitness app will serve as a comprehensive tool for users to manage their health and fitness journey effectively, with personalized guidance every step of the way.</p>"
    },
    %{
      title: "Marketing Campaign Management",
      description:
        "<p>Build a robust marketing campaign management platform to streamline the planning, execution, and analysis of marketing efforts across multiple channels. This tool will empower businesses to enhance their marketing strategies with data-driven insights.</p>
      <ul>
        <li><strong>Campaign Creation:</strong> Enable users to design campaigns tailored for email, social media, or advertising platforms.</li>
        <li><strong>Channel Management:</strong> Support multi-channel management for a unified approach to brand promotion.</li>
        <li><strong>Real-time Performance Metrics:</strong> Provide up-to-date data on impressions, clicks, conversions, and ROI.</li>
        <li><strong>Targeted Analytics:</strong> Offer insights into audience engagement, helping refine strategies to meet specific objectives.</li>
        <li><strong>Automated Reporting:</strong> Generate periodic reports for easy sharing with stakeholders and team members.</li>
      </ul>
      <p>This platform will be an invaluable resource for businesses, enabling them to maximize their reach, optimize campaigns, and make data-informed marketing decisions.</p>"
    },
    %{
      title: "Online Learning Platform",
      description:
        "<p>Create a versatile online learning platform designed to deliver a wide array of courses and training programs for students, professionals, and lifelong learners. This platform will focus on providing an engaging and interactive learning experience.</p>
      <ul>
        <li><strong>Video Tutorials:</strong> Host high-quality, pre-recorded lessons covering various topics and skill levels.</li>
        <li><strong>Quizzes and Assignments:</strong> Enable knowledge checks with quizzes and assignments that reinforce learning.</li>
        <li><strong>Certification Options:</strong> Offer certificates for course completion, providing students with credentials.</li>
        <li><strong>User Progress Tracking:</strong> Allow users to monitor their progress through detailed analytics and completion percentages.</li>
        <li><strong>Interactive Features:</strong> Integrate discussion boards, peer interactions, and instructor Q&A to facilitate a community-driven learning experience.</li>
      </ul>
      <p>This platform will empower users to expand their knowledge and skills, catering to diverse learning preferences and making education accessible to all.</p>"
    },
    %{
      title: "Custom CRM Development",
      description:
        "<p>Develop a tailored Customer Relationship Management (CRM) system that aligns with business objectives for efficient customer engagement and streamlined processes. This CRM solution will improve team productivity and customer satisfaction.</p>
      <ul>
        <li><strong>Contact Management:</strong> Store and manage customer information, including past interactions and preferences.</li>
        <li><strong>Lead Tracking:</strong> Track leads throughout the sales funnel for improved conversion rates.</li>
        <li><strong>Sales Process Automation:</strong> Automate repetitive sales tasks, such as follow-up emails and reminders.</li>
        <li><strong>Customer Support Tickets:</strong> Manage and resolve customer issues efficiently with a dedicated support module.</li>
        <li><strong>Analytics & Reporting:</strong> Provide insights into customer behavior, enabling data-driven strategies.</li>
      </ul>
      <p>With this CRM, businesses will foster stronger relationships, leading to increased customer loyalty and higher retention rates.</p>"
    },
    %{
      title: "Real Estate Listing Platform",
      description:
        "<p>Develop a feature-rich real estate listing platform that connects buyers, sellers, and agents. This platform will simplify property browsing, increase visibility, and streamline transactions in the real estate market.</p>
      <ul>
        <li><strong>Property Listings:</strong> Allow sellers to list properties with detailed descriptions, photos, and videos.</li>
        <li><strong>Search and Filter:</strong> Enable users to filter listings by location, price, property type, and more.</li>
        <li><strong>Interactive Map View:</strong> Integrate map functionality to help users locate properties visually.</li>
        <li><strong>Agent Profiles:</strong> Provide profiles for agents, including contact information and property listings.</li>
        <li><strong>Virtual Tours:</strong> Offer immersive virtual tours for remote viewing of properties.</li>
      </ul>
      <p>This platform will help property seekers find their ideal homes and increase engagement with the real estate market.</p>"
    },
    %{
      title: "Online Food Delivery System",
      description:
        "<p>Develop an online food delivery system that connects customers with local restaurants for convenient meal ordering. This system will streamline the ordering process for both users and restaurants.</p>
      <ul>
        <li><strong>Restaurant Listings:</strong> List participating restaurants with menus, ratings, and customer reviews.</li>
        <li><strong>Ordering and Checkout:</strong> Enable easy food ordering with secure checkout options.</li>
        <li><strong>Real-Time Delivery Tracking:</strong> Allow customers to track their orders in real time until delivery.</li>
        <li><strong>Discounts and Promotions:</strong> Provide options for restaurants to offer discounts and promotions.</li>
        <li><strong>Rating and Reviews:</strong> Enable customers to provide feedback on their experience and meals.</li>
      </ul>
      <p>This food delivery system will enhance customer convenience while helping restaurants expand their reach.</p>"
    },
    %{
      title: "Virtual Event Platform",
      description:
        "<p>Build a virtual event platform to host online conferences, webinars, and networking events. This platform will provide a virtual space for organizations to engage audiences regardless of location.</p>
      <ul>
        <li><strong>Live Streaming:</strong> Stream presentations and discussions in real time to attendees.</li>
        <li><strong>Virtual Networking:</strong> Facilitate attendee interactions through chat and video calls.</li>
        <li><strong>Session Scheduling:</strong> Organize sessions and enable attendees to customize their schedules.</li>
        <li><strong>Interactive Polling and Q&A:</strong> Engage the audience with polls and Q&A sessions.</li>
        <li><strong>Analytics Dashboard:</strong> Provide insights into attendee engagement and session popularity.</li>
      </ul>
      <p>This virtual event platform will make online events interactive and accessible, bridging the gap between attendees and speakers.</p>"
    },
    %{
      title: "Inventory Management System",
      description:
        "<p>Create an inventory management system to help businesses track their stock levels, manage orders, and optimize supply chain processes. This tool will streamline inventory management, reducing wastage and stockouts.</p>
      <ul>
        <li><strong>Real-Time Stock Tracking:</strong> Monitor stock levels and movements in real time.</li>
        <li><strong>Order Management:</strong> Process incoming and outgoing orders efficiently.</li>
        <li><strong>Supplier Integration:</strong> Track supplier orders and deliveries for a cohesive supply chain.</li>
        <li><strong>Inventory Reports:</strong> Generate reports to analyze stock trends and turnover rates.</li>
        <li><strong>Alerts and Notifications:</strong> Set alerts for low stock levels and incoming orders.</li>
      </ul>
      <p>This system will help businesses streamline inventory processes, ensuring timely replenishment and cost savings.</p>"
    },
    %{
      title: "Project Management App for Remote Teams",
      description:
        "<p>Develop a project management application tailored for remote teams, offering collaboration and task management features. This app will ensure productivity and clarity for remote teams working on various projects.</p>
      <ul>
        <li><strong>Task Assignment:</strong> Assign and track individual tasks and deadlines within projects.</li>
        <li><strong>Real-Time Collaboration:</strong> Allow team members to communicate through chat and video calls.</li>
        <li><strong>Time Tracking:</strong> Monitor time spent on tasks for accountability and productivity.</li>
        <li><strong>File Sharing:</strong> Share documents and files relevant to projects and tasks.</li>
        <li><strong>Progress Analytics:</strong> Provide visual insights into project timelines and team performance.</li>
      </ul>
      <p>This application will streamline remote work by enhancing transparency, accountability, and team communication.</p>"
    },
    %{
      title: "Online Job Portal",
      description:
        "<p>Build an online job portal to connect employers and job seekers, offering a platform for job listings, applications, and recruitment management. This project will enhance hiring efficiency and provide career opportunities.</p>
      <ul>
        <li><strong>Job Listings:</strong> Employers can post job openings with detailed descriptions and requirements.</li>
        <li><strong>Application Tracking:</strong> Track applicants and manage the recruitment process from start to finish.</li>
        <li><strong>User Profiles:</strong> Allow job seekers to create profiles, upload resumes, and showcase skills.</li>
        <li><strong>Search and Filters:</strong> Enable job seekers to search and filter jobs based on location, role, and salary.</li>
        <li><strong>Notifications:</strong> Send real-time alerts for new job postings and application updates.</li>
      </ul>
      <p>This job portal will streamline the hiring process and provide valuable opportunities for job seekers to find their ideal roles.</p>"
    },
    %{
      title: "Personal Finance Manager",
      description:
        "<p>Create a personal finance management app to help users track expenses, set budgets, and achieve financial goals. This app will make financial planning more accessible and organized.</p>
      <ul>
        <li><strong>Expense Tracking:</strong> Categorize and track daily expenses for better budgeting.</li>
        <li><strong>Budget Planning:</strong> Allow users to set monthly or annual budgets by category.</li>
        <li><strong>Savings Goals:</strong> Help users define and achieve specific savings goals.</li>
        <li><strong>Financial Reports:</strong> Provide detailed reports and charts for financial insights.</li>
        <li><strong>Alerts:</strong> Set alerts for overspending or upcoming bill payments.</li>
      </ul>
      <p>This finance manager app will empower users to take control of their financial well-being and reach their monetary goals.</p>"
    },
    %{
      title: "Language Learning Platform",
      description:
        "<p>Develop a language learning platform to help users learn new languages through interactive lessons and practice exercises. This platform will make language acquisition more engaging and effective.</p>
      <ul>
        <li><strong>Interactive Lessons:</strong> Offer lessons in vocabulary, grammar, and pronunciation.</li>
        <li><strong>Practice Exercises:</strong> Include exercises for reading, writing, listening, and speaking.</li>
        <li><strong>Progress Tracking:</strong> Track user progress and reward accomplishments with badges.</li>
        <li><strong>Audio and Video Content:</strong> Provide native speaker recordings for improved pronunciation.</li>
        <li><strong>Community Forum:</strong> Facilitate peer interactions for practice and motivation.</li>
      </ul>
      <p>This platform will be a valuable tool for language learners looking to achieve fluency through structured learning.</p>"
    },
    %{
      title: "Smart Home Control App",
      description:
        "<p>Create a smart home control app to manage and automate connected devices within the home. This app will bring convenience and security to modern households.</p>
      <ul>
        <li><strong>Device Management:</strong> Allow users to control lights, thermostats, and appliances remotely.</li>
        <li><strong>Automation Rules:</strong> Set up automated routines, such as turning lights on at sunset.</li>
        <li><strong>Security Monitoring:</strong> Integrate cameras and sensors for home security control.</li>
        <li><strong>Energy Usage Tracking:</strong> Monitor energy consumption to optimize efficiency.</li>
        <li><strong>Voice Control:</strong> Enable hands-free control through integration with voice assistants.</li>
      </ul>
      <p>This app will make smart home management simple and efficient, enhancing user comfort and safety.</p>"
    },
    %{
      title: "Virtual Personal Stylist",
      description:
        "<p>Develop a virtual personal stylist app that provides fashion advice, outfit recommendations, and shopping suggestions based on user preferences. This app will make styling accessible and fun.</p>
      <ul>
        <li><strong>Style Quiz:</strong> Assess user preferences to personalize recommendations.</li>
        <li><strong>Outfit Suggestions:</strong> Provide outfit ideas for various occasions.</li>
        <li><strong>Closet Organizer:</strong> Help users manage and digitize their wardrobe.</li>
        <li><strong>Shopping Recommendations:</strong> Suggest products based on current fashion trends.</li>
        <li><strong>Seasonal Updates:</strong> Offer seasonal style updates and trend insights.</li>
      </ul>
      <p>This personal stylist app will empower users to improve their fashion sense and enjoy dressing up with confidence.</p>"
    },
    %{
      title: "Real-Time Weather Dashboard",
      description:
        "<p>Create a real-time weather dashboard that provides weather updates, forecasts, and severe weather alerts for specific locations. This dashboard will be valuable for users needing timely weather information.</p>
      <ul>
        <li><strong>Current Conditions:</strong> Display temperature, humidity, wind speed, and precipitation levels.</li>
        <li><strong>Hourly and Daily Forecasts:</strong> Provide weather predictions for up to a week ahead.</li>
        <li><strong>Weather Maps:</strong> Include radar and satellite maps for visual updates.</li>
        <li><strong>Severe Weather Alerts:</strong> Send notifications for extreme weather warnings.</li>
        <li><strong>Location Tracking:</strong> Allow users to monitor weather for multiple locations.</li>
      </ul>
      <p>This dashboard will keep users informed and prepared for changing weather conditions.</p>"
    },
    %{
      title: "Employee Training Platform",
      description:
        "<p>Develop a training platform for businesses to deliver learning content, track employee progress, and enhance workforce skills. This platform will facilitate ongoing professional development.</p>
      <ul>
        <li><strong>Course Library:</strong> Provide access to a variety of training modules and resources.</li>
        <li><strong>Progress Tracking:</strong> Monitor employee completion and performance in courses.</li>
        <li><strong>Certification:</strong> Offer certifications upon successful course completion.</li>
        <li><strong>Interactive Assessments:</strong> Include quizzes and tests to reinforce learning.</li>
        <li><strong>Discussion Boards:</strong> Enable peer interaction and collaboration on topics.</li>
      </ul>
      <p>This platform will empower companies to support employee growth and upskill their workforce.</p>"
    },
    %{
      title: "Freelancer Portfolio Website Builder",
      description:
        "<p>Create a website builder specifically for freelancers, allowing them to showcase their portfolios, skills, and testimonials. This tool will enable freelancers to create a professional online presence.</p>
      <ul>
        <li><strong>Template Selection:</strong> Offer templates optimized for showcasing freelance work.</li>
        <li><strong>Portfolio Showcase:</strong> Enable freelancers to display work samples with descriptions.</li>
        <li><strong>Client Testimonials:</strong> Provide a section for client reviews and endorsements.</li>
        <li><strong>Contact Form:</strong> Allow potential clients to reach out directly via the website.</li>
        <li><strong>SEO Optimization:</strong> Help freelancers rank higher on search engines.</li>
      </ul>
      <p>This website builder will allow freelancers to present their work effectively and attract new clients.</p>"
    },
    %{
      title: "Online Quiz and Trivia Platform",
      description:
        "<p>Develop an online quiz and trivia platform where users can test their knowledge across various categories. This platform will be engaging and educational for users of all ages.</p>
      <ul>
        <li><strong>Category Selection:</strong> Offer quizzes on diverse topics, such as history, science, and entertainment.</li>
        <li><strong>Leaderboards:</strong> Track high scores and reward top performers with badges.</li>
        <li><strong>Timed Questions:</strong> Include a time limit for each question to add excitement.</li>
        <li><strong>Social Sharing:</strong> Allow users to share scores on social media.</li>
        <li><strong>Custom Quiz Creation:</strong> Enable users to create and share their own quizzes.</li>
      </ul>
      <p>This trivia platform will provide an entertaining experience for users while enhancing their knowledge.</p>"
    },
    %{
      title: "Virtual Plant Care Assistant",
      description:
        "<p>Create a virtual plant care assistant app that helps users maintain healthy plants by providing personalized care instructions. This app will support plant enthusiasts with expert guidance.</p>
      <ul>
        <li><strong>Plant Identification:</strong> Recognize plants through photo uploads and provide details.</li>
        <li><strong>Care Reminders:</strong> Send watering, fertilizing, and pruning reminders based on plant type.</li>
        <li><strong>Environmental Monitoring:</strong> Suggest optimal light, temperature, and humidity levels.</li>
        <li><strong>Pest Diagnosis:</strong> Help users identify and manage common plant pests.</li>
        <li><strong>Plant Community:</strong> Connect users with other plant enthusiasts for tips and advice.</li>
      </ul>
      <p>This plant care assistant will make plant care easy, allowing users to grow healthier plants at home.</p>"
    },
    %{
      title: "Pet Care and Adoption Platform",
      description:
        "<p>Create a platform that connects potential pet adopters with animal shelters and provides resources for pet care. This project will promote pet adoption and responsible pet ownership.</p>
      <ul>
        <li><strong>Adoption Listings:</strong> Animal shelters can post adoptable pets with details and images.</li>
        <li><strong>Search Filters:</strong> Users can search by pet type, age, size, and location.</li>
        <li><strong>Pet Care Resources:</strong> Provide articles and tips for pet care, nutrition, and training.</li>
        <li><strong>Adoption Process Support:</strong> Guide users through the steps of adopting a pet.</li>
        <li><strong>Community Forum:</strong> Allow adopters to share stories, advice, and support.</li>
      </ul>
      <p>This platform will encourage pet adoption and provide valuable resources for new pet owners.</p>"
    },
    %{
      title: "Sustainable Shopping App",
      description:
        "<p>Develop an app that encourages sustainable shopping by offering eco-friendly product suggestions, tips, and certifications. This app will promote conscious consumer choices.</p>
      <ul>
        <li><strong>Eco-Friendly Products:</strong> List products with sustainable certifications, materials, and packaging.</li>
        <li><strong>Shopping Tips:</strong> Provide tips on reducing waste and making environmentally friendly choices.</li>
        <li><strong>Carbon Footprint Calculator:</strong> Help users understand the impact of their purchases.</li>
        <li><strong>Recycling Guide:</strong> Offer information on recycling and disposing of items responsibly.</li>
        <li><strong>User Reviews:</strong> Encourage users to share feedback on sustainable products.</li>
      </ul>
      <p>This app will empower users to make eco-conscious decisions, supporting a greener planet.</p>"
    },
    %{
      title: "Virtual Interior Design Consultant",
      description:
        "<p>Build an app that offers virtual interior design consultations, helping users redesign spaces and choose decor that fits their style and budget. This app will bring professional design advice to users.</p>
      <ul>
        <li><strong>Room Design Inspiration:</strong> Provide curated design ideas and mood boards.</li>
        <li><strong>Virtual Room Visualization:</strong> Allow users to see how furniture and decor will look in their space.</li>
        <li><strong>Budget Planner:</strong> Help users plan their designs within budget constraints.</li>
        <li><strong>Shopping Suggestions:</strong> Suggest furniture and decor items from various retailers.</li>
        <li><strong>Designer Feedback:</strong> Offer feedback from professional designers on user choices.</li>
      </ul>
      <p>This app will allow users to create beautiful, well-planned spaces tailored to their tastes.</p>"
    },
    %{
      title: "Remote Team Collaboration Platform",
      description:
        "<p>Create a platform for remote teams to collaborate effectively through chat, video calls, file sharing, and project tracking. This platform will enhance communication and productivity for distributed teams.</p>
      <ul>
        <li><strong>Real-Time Chat:</strong> Enable team members to communicate through instant messaging.</li>
        <li><strong>Video Conferencing:</strong> Integrate video calls for face-to-face communication.</li>
        <li><strong>Task Management:</strong> Allow teams to assign and track tasks with deadlines.</li>
        <li><strong>Document Sharing:</strong> Facilitate the sharing of files and project documents securely.</li>
        <li><strong>Activity Feeds:</strong> Keep everyone updated with real-time activity notifications.</li>
      </ul>
      <p>This platform will bring remote teams together, enabling seamless collaboration and organization.</p>"
    },
    %{
      title: "Event Management and RSVP App",
      description:
        "<p>Develop an app for event planning and RSVP management, allowing hosts to organize events and guests to RSVP online. This app will simplify event coordination and attendance tracking.</p>
      <ul>
        <li><strong>Event Creation:</strong> Let users create events with details like time, location, and theme.</li>
        <li><strong>Guest Invitations:</strong> Send digital invites and allow guests to RSVP online.</li>
        <li><strong>Guest List Management:</strong> Track attendees and update event details as needed.</li>
        <li><strong>Reminders:</strong> Send reminders to guests before the event date.</li>
        <li><strong>Event Photos:</strong> Allow guests to share photos and comments post-event.</li>
      </ul>
      <p>This app will streamline event management, making it easier for hosts and guests to stay organized.</p>"
    },
    %{
      title: "Recipe Sharing and Meal Planning App",
      description:
        "<p>Build a recipe-sharing and meal-planning app where users can discover new recipes, save favorites, and plan meals. This app will make cooking and meal preparation more convenient.</p>
      <ul>
        <li><strong>Recipe Library:</strong> Offer a collection of recipes categorized by cuisine, diet, and ingredients.</li>
        <li><strong>Meal Planner:</strong> Allow users to plan meals for the week with recipe suggestions.</li>
        <li><strong>Shopping List:</strong> Generate a shopping list based on planned meals and selected recipes.</li>
        <li><strong>Recipe Sharing:</strong> Let users upload and share their recipes with the community.</li>
        <li><strong>Nutritional Information:</strong> Provide nutritional details for each recipe.</li>
      </ul>
      <p>This app will inspire users to explore new dishes and organize their cooking routines.</p>"
    },
    %{
      title: "Digital Health Record System",
      description:
        "<p>Create a digital health record system for patients to store and manage their medical history securely. This system will provide easy access to health data for both patients and healthcare providers.</p>
      <ul>
        <li><strong>Health Record Management:</strong> Allow users to upload and organize medical documents.</li>
        <li><strong>Appointment Scheduling:</strong> Facilitate scheduling with healthcare providers.</li>
        <li><strong>Prescription Management:</strong> Track prescriptions and medication history.</li>
        <li><strong>Secure Access:</strong> Ensure data privacy with encrypted access and sharing.</li>
        <li><strong>Health Tracking:</strong> Enable users to log health metrics, like weight and blood pressure.</li>
      </ul>
      <p>This system will enhance patient data accessibility, making healthcare more efficient.</p>"
    },
    %{
      title: "Local Community Marketplace",
      description:
        "<p>Develop a marketplace app for local communities to buy, sell, or exchange goods and services. This platform will foster connections and support local economies.</p>
      <ul>
        <li><strong>Listings by Category:</strong> Allow users to browse items by categories like electronics, furniture, and services.</li>
        <li><strong>Location-Based Search:</strong> Connect users within specific geographical areas.</li>
        <li><strong>In-App Messaging:</strong> Facilitate communication between buyers and sellers.</li>
        <li><strong>Secure Payments:</strong> Integrate payment options for safe transactions.</li>
        <li><strong>User Ratings:</strong> Include ratings and reviews to build trust within the community.</li>
      </ul>
      <p>This marketplace app will create a platform for local trade and foster neighborly interactions.</p>"
    },
    %{
      title: "Mental Wellness App",
      description:
        "<p>Create a mental wellness app that provides resources and tools for managing stress, improving mindfulness, and enhancing mental health. This app will support users' mental well-being.</p>
      <ul>
        <li><strong>Guided Meditations:</strong> Offer meditation sessions for relaxation and focus.</li>
        <li><strong>Journaling Tool:</strong> Allow users to log thoughts and emotions privately.</li>
        <li><strong>Mood Tracking:</strong> Track daily mood to identify patterns over time.</li>
        <li><strong>Self-Care Tips:</strong> Provide personalized self-care suggestions.</li>
        <li><strong>Community Support:</strong> Connect users with a supportive mental wellness community.</li>
      </ul>
      <p>This mental wellness app will promote healthy habits and emotional resilience for users.</p>"
    },
    %{
      title: "AI-Powered Resume Builder",
      description:
        "<p>Develop an AI-powered resume builder that helps users create professional resumes with customized content and design suggestions. This tool will simplify resume writing and improve job seekers' chances.</p>
      <ul>
        <li><strong>Template Selection:</strong> Offer a variety of resume templates tailored to different industries.</li>
        <li><strong>Content Suggestions:</strong> Use AI to suggest job-specific phrases and skills.</li>
        <li><strong>Formatting Options:</strong> Allow users to customize layout, colors, and fonts.</li>
        <li><strong>Job Matching Insights:</strong> Provide insights on how the resume matches specific job descriptions.</li>
        <li><strong>Download and Share:</strong> Enable users to download or share resumes as PDF files.</li>
      </ul>
      <p>This resume builder will make creating a polished resume easy, helping job seekers stand out.</p>"
    }
  ]

for proj <- projects do
  client = Enum.random(created_clients) |> get_preload([:notification_preference])
  project_status = Project.all_statuses() |> Enum.reject(&(&1 == :completed)) |> Enum.random()

  project =
    Repo.insert!(%Project{
      title: proj.title,
      description: proj.description,
      status: project_status,
      budget: Decimal.new(Enum.random(1000..10000)),
      client_id: client.id
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

    find_freelancer? = Enum.random([true, false])

    task =
      Repo.insert!(%Task{
        title: task_title,
        description: task_description,
        is_completed?: if(find_freelancer?, do: Enum.random([true, false]), else: false),
        find_freelancer?: find_freelancer?,
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
    Enum.each(Enum.take_random(created_freelancers, 5), fn freelancer ->
      attached_files =
        Enum.map(1..4, fn _ ->
          "https://asset.cloudinary.com/dmkkivjv3/cb13850a32552725cc83943f00496892"
        end)

      if task.find_freelancer? do
        applied_bid =
          Repo.insert!(%Bid{
            amount: Decimal.new(Enum.random(100..1000)),
            status: :submitted,
            description: """
              <p>
                <p>Dear #{full_name(client)},</p>
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
                <strong>#{full_name(freelancer)}</strong>
                </p>
              </p>
            """,
            task_id: task.id,
            freelancer_id: freelancer.id,
            attached_files: attached_files
          })

        if client.notification_preference.push do
          n_params = %{
            user_id: client.id,
            message: """
            <p><strong>#{full_name(freelancer)}</strong> applied for the task #{task.title} associated with the project #{project.title} </p>
            """,
            type: "push",
            link: "bids/#{applied_bid.id}/show",
            is_read?: Enum.random([true, false])
          }

          %Notification{}
          |> Notification.changeset(n_params)
          |> Repo.insert!()
        end
      end
    end)

    # Assign freelancer to task based on accepted bid
    if task.find_freelancer? do
      task_with_bids = get_preload(task, :bids)

      {:ok, bid} =
        task_with_bids.bids
        |> Enum.random()
        |> Tasks.update_bid(%{"status" => :accepted})

      if bid.status == :accepted do
        freelancer =
          Accounts.get_user!(bid.freelancer_id) |> get_preload([:notification_preference])

        if freelancer.notification_preference.push do
          n_params = %{
            user_id: freelancer.id,
            message: """
            <p><strong>#{full_name(client)}</strong> has been accepted your bid against the task #{task.title}. and added you in the project #{project.title} </p>
            """,
            type: "push",
            link: "tasks/#{task.id}/show",
            is_read?: Enum.random([true, false])
          }

          %Notification{}
          |> Notification.changeset(n_params)
          |> Repo.insert!()
        end

        if j == Enum.random(3..5) do
          Tasks.update_task(task, %{
            "column_id" => column3.id,
            "is_completed?" => true,
            "freelancer_id" => freelancer.id
          })
        else
          Tasks.update_task(task, %{
            "column_id" => column2.id,
            "freelancer_id" => freelancer.id
          })
        end

        is_user_already_in_project(Repo.preload(bid, task: :project))

        # Add comments and replies
        Enum.each(1..3, fn _ ->
          comment =
            Repo.insert!(%Comment{
              message: "This is a comment on task: #{task.title}.",
              task_id: task.id,
              user_id: client.id
            })

          Enum.each(1..3, fn index ->
            user = if rem(index, 2) == 0, do: client, else: Accounts.get_user!(bid.freelancer_id)

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
  end

  joiners =
    project
    |> Repo.preload(project_freelancers: :freelancer)
    |> get_project_freelancers()
    |> Enum.map(& &1.id)

  if length(joiners) >= 2 do
    channel =
      Repo.insert!(%Channel{
        name: "Channel for #{project.title}",
        joiners: joiners,
        project_id: project.id,
        created_by_id: client.id
      })

    senders = joiners ++ [client.id]

    for _ <- 1..Enum.random(3..10) do
      Repo.insert!(%Message{
        body: """
          <p><strong>New message for #{project.title}:</strong></p>
          <p>
          #{Enum.random(["Looking forward to working on this project.", "Let’s discuss the project requirements in detail.", "Here are some ideas on how we could proceed.", "Please review the updates and let me know your feedback.", "Is there a specific deadline for this project?", "I'll send the initial draft by the end of the day."])}
          </p>
        """,
        sender_id: Enum.random(senders),
        channel_id: channel.id
      })
    end
  end
end
