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
  Sprint,
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
    bio: "<p>Dynamic entrepreneur with a passion for tech.</p>",
    username: "alice-doe"
  },
  %{
    first_name: "Jessica",
    last_name: "Rodriguez",
    email: "jessica.r@example.com",
    location: "Los Angeles, CA",
    bio: "<p>Creative designer with an eye for detail.</p>",
    username: "jessica-r"
  }
]

freelancers = [
  %{
    first_name: "Bob",
    last_name: "Smith",
    email: "bob.smith@example.com",
    location: "Chicago, IL",
    bio: "<p>Skilled developer with 5 years of experience.</p>",
    username: "bob-smith"
  },
  %{
    first_name: "Charlie",
    last_name: "Johnson",
    email: "charlie.j@example.com",
    location: "Houston, TX",
    bio: "<p>Full-stack engineer who loves coding.</p>",
    username: "charlie-j"
  },
  %{
    first_name: "Ian",
    last_name: "Martinez",
    email: "ian.martinez@example.com",
    location: "San Jose, CA",
    bio: "<p>Software engineer with a focus on efficiency.</p>",
    username: "ian-martinez"
  },
  %{
    first_name: "Tina",
    last_name: "Clark",
    email: "tina.clark@example.com",
    location: "Boston, MA",
    bio: "<p>Business analyst with a keen analytical mind.</p>",
    username: "tina-clark"
  }
]

notification_preferences = [
  %{email: false, sms: false, push: true},
  %{email: true, sms: false, push: true},
  %{email: false, sms: true, push: true},
  %{email: true, sms: true, push: true}
]

projects_list =
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

task_list =
  [
    %{
      title: "Design Homepage Layout",
      description: """
        <p>The homepage layout design is essential for capturing user interest as it serves as the first impression of the website. This task involves creating a visually engaging and user-friendly layout that aligns with brand identity and enhances the user experience.</p>
        <p>Key elements to focus on include:</p>
        <ul>
          <li><strong>Header and Navigation:</strong> Design a simple, intuitive navigation that includes clear links to core sections of the site.</li>
          <li><strong>Hero Section:</strong> Create a compelling hero section with high-quality visuals and a strong call-to-action (CTA).</li>
          <li><strong>Content Sections:</strong> Organize content into digestible sections, using whitespace effectively for readability.</li>
          <li><strong>Footer:</strong> Include essential links, contact information, and social media icons.</li>
        </ul>
        <p>Ensuring a responsive design for various screen sizes is also vital. Use prototyping tools like Figma or Adobe XD to create interactive mockups and gather feedback from stakeholders before moving to development. This task requires collaboration with the content team to align text with design elements, enhancing user engagement and guiding visitors toward key actions.</p>
      """
    },
    %{
      title: "Develop User Authentication Module",
      description: """
        <p>User authentication is crucial for website security and user access management. This task includes building a secure and robust authentication module that verifies user identity and grants appropriate access levels.</p>
        <p>The module should cover the following components:</p>
        <ul>
          <li><strong>Registration:</strong> Create a form where new users can sign up, including fields for username, password, and email address.</li>
          <li><strong>Login:</strong> Implement a login interface that authenticates users based on provided credentials.</li>
          <li><strong>Password Recovery:</strong> Set up a password recovery flow with email verification to assist users in case they forget their credentials.</li>
          <li><strong>Session Management:</strong> Use secure session management practices to maintain user state across pages without compromising security.</li>
        </ul>
        <p>Additional security practices include encrypting passwords, validating input fields, and setting up rate-limiting to prevent brute-force attacks. Testing is essential to ensure reliability across different scenarios, such as incorrect password attempts and invalid registration entries.</p>
      """
    },
    %{
      title: "Optimize Website for Mobile",
      description: """
        <p>Mobile optimization is essential in today's mobile-first environment, ensuring the website provides an excellent user experience across all device sizes. This task involves testing, adjusting, and enhancing website elements for mobile responsiveness.</p>
        <p>Main areas to address include:</p>
        <ul>
          <li><strong>Responsive Layout:</strong> Use flexible grids and layouts to adjust the website’s structure to fit various screen sizes, including smartphones and tablets.</li>
          <li><strong>Font and Button Sizes:</strong> Increase font sizes and button areas to accommodate touch interactions, ensuring usability for all age groups.</li>
          <li><strong>Media Optimization:</strong> Serve appropriately-sized images and videos, reducing load times and optimizing bandwidth for mobile users.</li>
          <li><strong>Testing:</strong> Test the mobile experience across different operating systems and browsers to identify inconsistencies or issues.</li>
        </ul>
        <p>Consider implementing Progressive Web App (PWA) features to offer a seamless offline experience and native-like functionality on mobile devices. Performance monitoring tools like Google Lighthouse can help evaluate loading speed and user experience on mobile.</p>
      """
    },
    %{
      title: "Integrate Payment Gateway",
      description: """
        <p>Integrating a payment gateway allows users to make secure online payments, crucial for any e-commerce or subscription-based platform. This task involves setting up a reliable and secure payment system to handle transactions effectively.</p>
        <p>Key steps in this task include:</p>
        <ul>
          <li><strong>Choose a Payment Provider:</strong> Research providers like Stripe, PayPal, and Square, selecting one based on transaction fees, security features, and compatibility.</li>
          <li><strong>API Integration:</strong> Use the provider’s API to connect the website’s checkout process with the payment gateway.</li>
          <li><strong>Security Measures:</strong> Implement SSL certificates and follow PCI-DSS compliance to protect sensitive user data.</li>
          <li><strong>Testing Transactions:</strong> Test the payment flow, including successful transactions, failures, refunds, and chargebacks to ensure accuracy.</li>
        </ul>
        <p>This task may also involve setting up recurring payments for subscription models or configuring local payment methods for international transactions. Detailed documentation and error handling improve the user experience and trustworthiness of the payment process.</p>
      """
    },
    %{
      title: "Conduct UX Research",
      description: """
        <p>UX research is a critical step in understanding user needs and preferences, informing the design process to create a user-centric product. This task involves gathering insights through various research methods to inform decision-making.</p>
        <p>Important research methods to include:</p>
        <ul>
          <li><strong>User Interviews:</strong> Conduct interviews with target users to understand their goals, pain points, and preferences.</li>
          <li><strong>Surveys:</strong> Create surveys to gather quantitative data on user behaviors and needs.</li>
          <li><strong>Competitor Analysis:</strong> Study competitors to identify industry standards and user expectations.</li>
          <li><strong>User Testing:</strong> Observe users interacting with the prototype to identify usability issues and areas for improvement.</li>
        </ul>
        <p>Document findings in a research report, highlighting key takeaways and actionable insights. Collaboration with designers and stakeholders ensures that insights are effectively implemented into the final product.</p>
      """
    },
    %{
      title: "Implement Dark Mode Feature",
      description: """
        <p>The dark mode feature enhances user experience, especially in low-light conditions, reducing eye strain and improving aesthetics. This task focuses on implementing a theme switcher that enables users to toggle between light and dark modes.</p>
        <p>Main considerations for dark mode implementation:</p>
        <ul>
          <li><strong>Theme Toggle:</strong> Add a toggle switch to the user interface that lets users switch between modes.</li>
          <li><strong>Color Schemes:</strong> Define a dark color palette that maintains readability while avoiding overly bright or contrasting colors.</li>
          <li><strong>Persistence:</strong> Use local storage or cookies to save user preferences so they retain their selected theme.</li>
          <li><strong>Compatibility:</strong> Ensure the theme applies to all UI components, including buttons, forms, and background elements.</li>
        </ul>
        <p>Testing the dark mode across devices and user interfaces ensures consistency. Consider accessibility standards to ensure the feature is beneficial for all users.</p>
      """
    },
    %{
      title: "Create RESTful API",
      description: """
        <p>Developing a RESTful API is fundamental for enabling communication between frontend and backend services. This task involves creating a structured and efficient API to support various client applications.</p>
        <p>Core tasks for API development include:</p>
        <ul>
          <li><strong>Define Endpoints:</strong> Outline endpoints for essential operations, like create, read, update, and delete (CRUD) for different resources.</li>
          <li><strong>Data Validation:</strong> Implement validation mechanisms to ensure incoming data meets required formats and standards.</li>
          <li><strong>Authentication and Authorization:</strong> Add security layers to protect sensitive data and restrict access based on user roles.</li>
          <li><strong>Documentation:</strong> Document the API, providing details on endpoints, parameters, and error codes to assist developers.</li>
        </ul>
        <p>This task also includes testing API endpoints for performance and handling error responses gracefully. Use tools like Postman for manual testing and integrate automated tests for continuous monitoring.</p>
      """
    },
    %{
      title: "Migrate Database to Cloud",
      description: """
        <p>Migrating a database to the cloud provides scalability, security, and cost-efficiency. This task involves transferring on-premise or local databases to a cloud provider while ensuring data integrity and minimal downtime.</p>
        <p>Steps involved in database migration include:</p>
        <ul>
          <li><strong>Choose a Cloud Provider:</strong> Select a provider like AWS, Google Cloud, or Azure based on features, performance, and cost.</li>
          <li><strong>Data Backup:</strong> Take a full backup of the database before migration to prevent data loss in case of issues.</li>
          <li><strong>Data Transfer:</strong> Use data migration tools or database export/import features for seamless transfer.</li>
          <li><strong>Testing:</strong> Test the cloud database for performance, reliability, and data integrity post-migration.</li>
        </ul>
        <p>After migration, set up monitoring and security protocols to ensure ongoing performance and protect against unauthorized access. Regular backups in the cloud further enhance data safety.</p>
      """
    },
    %{
      title: "Build a Custom CMS",
      description: """
        <p>A Content Management System (CMS) allows users to easily create, edit, and manage content on a website without technical knowledge. Building a custom CMS for a project ensures flexibility and scalability, allowing it to grow and adapt to specific business needs.</p>
        <p>Key features to include in the CMS:</p>
        <ul>
          <li><strong>Admin Dashboard:</strong> Create an intuitive dashboard for administrators to manage content, view analytics, and configure site settings.</li>
          <li><strong>Content Editing:</strong> Build a rich text editor or integrate a WYSIWYG editor for creating and managing articles, blog posts, and other content types.</li>
          <li><strong>Media Management:</strong> Allow users to upload and organize media files, such as images, videos, and documents, within the CMS.</li>
          <li><strong>User Permissions:</strong> Implement role-based access control (RBAC) to manage which users can edit content, approve posts, or access sensitive data.</li>
        </ul>
        <p>Consider implementing version control for content to allow easy rollbacks in case of errors. Testing and ensuring scalability for handling large content volumes is also essential. A custom CMS provides complete control over features, security, and performance, allowing it to be tailored to the specific needs of the project.</p>
      """
    },
    %{
      title: "Create Social Media Integration",
      description: """
        <p>Social media integration allows users to share content directly to platforms like Facebook, Twitter, and Instagram. It also facilitates login through social accounts, making user engagement and experience smoother.</p>
        <p>Steps for social media integration include:</p>
        <ul>
          <li><strong>Login with Social Accounts:</strong> Integrate third-party authentication using OAuth to allow users to sign up or log in using their social media credentials.</li>
          <li><strong>Share Buttons:</strong> Add social media share buttons to content pages, enabling users to share articles, images, and videos.</li>
          <li><strong>API Integrations:</strong> Use the respective social media APIs to post content or retrieve user data, depending on the features required.</li>
          <li><strong>Analytics Tracking:</strong> Implement tracking for social media engagement, such as click-through rates, shares, and comments, to monitor the effectiveness of integration.</li>
        </ul>
        <p>Social media login increases user retention, while share features improve visibility and reach. Ensure that integration follows the platform's policies and respects user privacy. Testing cross-platform functionality is essential to guarantee seamless experience across devices.</p>
      """
    },
    %{
      title: "Develop Multi-Language Support",
      description: """
        <p>Multi-language support enables a website to cater to a global audience by displaying content in different languages based on user preferences or location. This task focuses on making the website accessible to non-English speakers.</p>
        <p>Key considerations for implementing multi-language support:</p>
        <ul>
          <li><strong>Language Selection:</strong> Add a dropdown or toggle for users to select their preferred language from the available options.</li>
          <li><strong>Translation Management:</strong> Use a translation management system (TMS) to store and manage translated content, such as text, images, and buttons.</li>
          <li><strong>Locale Settings:</strong> Implement locale-based settings for date formats, currency, and other region-specific elements.</li>
          <li><strong>RTL Support:</strong> Ensure that right-to-left languages, such as Arabic or Hebrew, are properly displayed by adjusting the layout accordingly.</li>
        </ul>
        <p>Automate translations where possible, but also provide manual overrides for important content to maintain accuracy. Test translations for accuracy, readability, and consistency, and consider cultural nuances in language usage. Multi-language support increases accessibility and can significantly broaden your audience reach.</p>
      """
    },
    %{
      title: "Setup CDN for Static Assets",
      description: """
        <p>A Content Delivery Network (CDN) speeds up the delivery of static assets (e.g., images, CSS, JavaScript) by caching them on servers located around the world. This task involves configuring a CDN to reduce load times and improve the user experience.</p>
        <p>Steps for CDN setup:</p>
        <ul>
          <li><strong>Choose a CDN Provider:</strong> Select a CDN provider, such as Cloudflare, AWS CloudFront, or Akamai, based on your needs and budget.</li>
          <li><strong>Upload Static Assets:</strong> Upload images, videos, CSS, and JavaScript files to the CDN, ensuring that they are cached on edge servers.</li>
          <li><strong>Configure Cache Settings:</strong> Set cache expiration times and policies to ensure that users receive the most up-to-date content when needed.</li>
          <li><strong>Integrate CDN with Website:</strong> Update the website’s asset URLs to point to the CDN, ensuring all static content is delivered via the CDN rather than directly from the server.</li>
        </ul>
        <p>By reducing server load and providing faster content delivery, a CDN improves website performance, especially for users in different geographical locations. Regular monitoring of cache hit ratios and performance metrics ensures the CDN is delivering as expected. Test asset delivery across different regions to verify global reach and speed.</p>
      """
    },
    %{
      title: "Create Data Backup System",
      description: """
        <p>Data backup systems are essential to prevent data loss in case of system failure or accidental deletion. This task involves setting up a reliable and automated data backup solution to ensure that important files, databases, and configurations are backed up regularly.</p>
        <p>Key steps in creating a data backup system:</p>
        <ul>
          <li><strong>Determine Backup Scope:</strong> Identify which data needs to be backed up, including databases, media files, and configurations.</li>
          <li><strong>Choose Backup Method:</strong> Decide whether to use full, incremental, or differential backups based on your requirements.</li>
          <li><strong>Automate Backups:</strong> Set up automated backup schedules to ensure that backups occur regularly without manual intervention.</li>
          <li><strong>Test Recovery Process:</strong> Regularly test the recovery process to ensure that backups are functional and data can be restored when needed.</li>
        </ul>
        <p>Data backups should be stored securely in off-site locations, such as cloud storage or external drives. Encrypted backups protect sensitive information, while monitoring and logging systems ensure that any issues with backup processes are detected early. A solid backup system provides peace of mind and minimizes the impact of data loss.</p>
      """
    },
    %{
      title: "Configure Email Notification System",
      description: """
        <p>Email notifications are vital for keeping users informed about important events or actions related to their accounts, such as registration, password changes, and order updates. This task involves setting up an email notification system to send automated emails to users based on predefined triggers.</p>
        <p>Steps for configuring the email system:</p>
        <ul>
          <li><strong>Choose an Email Service Provider:</strong> Select an email service provider, such as SendGrid, Amazon SES, or Mailgun, to handle email delivery.</li>
          <li><strong>Set Up Templates:</strong> Create email templates for various notifications, including registration confirmations, password resets, and transaction updates.</li>
          <li><strong>Trigger Notifications:</strong> Implement logic to trigger email notifications based on user actions, such as account creation or order completion.</li>
          <li><strong>Monitor Deliverability:</strong> Track email open rates, bounce rates, and other metrics to ensure high deliverability and effectiveness.</li>
        </ul>
        <p>Personalize email content to improve engagement and reduce unsubscribe rates. Include clear calls to action and branding to make emails informative and visually appealing. Ensure that emails are optimized for mobile devices to reach users wherever they are.</p>
      """
    },
    %{
      title: "Setup Real-Time Notifications",
      description: """
        <p>Real-time notifications allow users to receive immediate updates about activities such as new messages, status changes, or system alerts. This task involves setting up a notification system that delivers updates as they occur, ensuring users are kept informed in real-time.</p>
        <p>Key aspects of real-time notification setup:</p>
        <ul>
          <li><strong>Choose Notification Service:</strong> Use services like Firebase Cloud Messaging (FCM) or WebSockets to deliver notifications instantly.</li>
          <li><strong>Implement Event Triggers:</strong> Set up event triggers that notify users when certain actions occur, such as receiving a new message or task status update.</li>
          <li><strong>Push Notifications:</strong> Enable push notifications for web or mobile applications to inform users even when they are not actively using the app.</li>
          <li><strong>Customize Alerts:</strong> Allow users to customize the types of notifications they wish to receive, such as alerts for comments, new bids, or project status changes.</li>
        </ul>
        <p>Real-time notifications enhance user engagement by ensuring they never miss important updates. Ensuring scalability and handling large volumes of notifications without compromising performance is key to the system’s success.</p>
      """
    },
    %{
      title: "Design Mobile-First UI",
      description: """
        <p>With the increasing use of mobile devices, designing a mobile-first user interface (UI) ensures that your website or app is optimized for small screen sizes and touch interactions. A mobile-first design focuses on delivering a seamless experience for mobile users while ensuring the desktop version is also fully responsive.</p>
        <p>Steps for implementing a mobile-first UI:</p>
        <ul>
          <li><strong>Plan Layouts for Mobile:</strong> Start by designing the mobile layout first, then gradually scale up to accommodate larger screens. Prioritize important content for mobile users.</li>
          <li><strong>Use Fluid Grids:</strong> Utilize flexible grids to adapt to various screen sizes. Media queries are essential for ensuring that the layout adjusts according to the viewport.</li>
          <li><strong>Optimize Touch Interactions:</strong> Ensure that buttons, links, and forms are touch-friendly, with ample spacing between interactive elements for ease of use on smaller screens.</li>
          <li><strong>Test on Multiple Devices:</strong> Thoroughly test the UI on a variety of mobile devices to ensure compatibility, smooth performance, and usability.</li>
        </ul>
        <p>Mobile-first UI design enhances user experience by focusing on performance, accessibility, and responsiveness from the start. The goal is to create a seamless and engaging experience, regardless of the device used.</p>
      """
    },
    %{
      title: "Implement User Role Management",
      description: """
        <p>User role management is crucial for controlling access and permissions in any application. This task involves defining different roles (e.g., admin, user, guest) and managing the permissions associated with each role to ensure users can access only the resources they are authorized to.</p>
        <p>Steps to implement role-based access control (RBAC):</p>
        <ul>
          <li><strong>Define User Roles:</strong> Identify the various user roles in your system and the permissions required for each role. For example, admins may have full access, while regular users have limited access.</li>
          <li><strong>Assign Permissions:</strong> Assign specific permissions to each role, such as read, write, edit, delete, etc. Ensure permissions are granular enough to control access at different levels (e.g., file-level, resource-level).</li>
          <li><strong>Role Assignment:</strong> Allow users to be assigned one or more roles during registration or via the admin panel. Ensure that users can only perform actions permitted by their roles.</li>
          <li><strong>Enforce Role Checks:</strong> Implement access control checks throughout the application to ensure that users can only access content and perform actions based on their assigned role.</li>
        </ul>
        <p>Role management increases security and makes it easier to manage permissions for large groups of users. It is important to periodically review and adjust roles and permissions as your application evolves.</p>
      """
    },
    %{
      title: "Integrate Payment Gateway",
      description: """
        <p>Integrating a payment gateway into your website or application allows users to make secure online payments for products or services. This task involves selecting a payment gateway, implementing it in your app, and ensuring secure transactions for all users.</p>
        <p>Steps to integrate a payment gateway:</p>
        <ul>
          <li><strong>Choose a Payment Gateway:</strong> Popular options include Stripe, PayPal, and Square. Consider factors such as transaction fees, supported currencies, and geographic availability when making your choice.</li>
          <li><strong>Set Up API Integration:</strong> Obtain API keys from your payment provider and integrate their payment API into your website. Implement necessary endpoints to handle payment processing.</li>
          <li><strong>Design Payment Flow:</strong> Create a user-friendly flow for payments, including cart review, payment method selection, and payment confirmation screens.</li>
          <li><strong>Secure Transactions:</strong> Implement SSL encryption, use tokenization for payment details, and comply with PCI-DSS regulations to ensure secure transactions.</li>
        </ul>
        <p>Testing is crucial to ensure the payment gateway integrates smoothly with your system. After successful integration, thoroughly test payment processing for different scenarios, such as successful payments, failed transactions, and refunds.</p>
      """
    },
    %{
      title: "Develop RESTful API",
      description: """
        <p>A RESTful API allows applications to communicate with each other over HTTP. This task involves designing and developing a set of RESTful endpoints to handle client-server communication and data exchange, providing an efficient and scalable solution for web and mobile applications.</p>
        <p>Steps for developing a RESTful API:</p>
        <ul>
          <li><strong>Design API Endpoints:</strong> Determine the necessary API endpoints based on the resources your application needs to expose. For example, endpoints for user authentication, fetching project data, and submitting tasks.</li>
          <li><strong>Implement HTTP Methods:</strong> Ensure that each endpoint supports the appropriate HTTP methods (GET, POST, PUT, DELETE) for performing the necessary actions.</li>
          <li><strong>Set Up Data Serialization:</strong> Use a data serialization format like JSON to structure the data returned by the API. Ensure that responses are easy to parse and contain relevant information.</li>
          <li><strong>Implement Authentication:</strong> Use OAuth or API keys for secure access to the API. Implement role-based authentication to control access to certain endpoints based on user roles.</li>
        </ul>
        <p>A well-designed RESTful API is crucial for enabling seamless communication between the front-end and back-end of web applications. Consider optimizing performance, implementing proper error handling, and ensuring scalability as the application grows.</p>
      """
    },
    %{
      title: "Build User Feedback System",
      description: """
        <p>Building a user feedback system allows you to collect valuable insights from users, helping improve the overall experience and functionality of your application. This task involves creating an interface for users to provide feedback and mechanisms for storing and analyzing that feedback.</p>
        <p>Steps to build a feedback system:</p>
        <ul>
          <li><strong>Design Feedback Form:</strong> Create an easy-to-use form that allows users to submit their feedback, suggestions, and bug reports. Include fields for rating the app, describing issues, and offering suggestions for improvement.</li>
          <li><strong>Enable Feedback Categories:</strong> Allow users to categorize their feedback (e.g., bugs, features, usability) to streamline the analysis process.</li>
          <li><strong>Store Feedback:</strong> Implement a database system to store feedback and ensure it can be easily queried for analysis. Include a mechanism to tag and filter feedback based on urgency or type.</li>
          <li><strong>Respond to Users:</strong> Set up automated or manual responses to thank users for their feedback and inform them of any actions being taken based on their input.</li>
        </ul>
        <p>Having a feedback system in place improves user engagement and helps prioritize features or fixes based on user needs. Regularly review feedback and continuously improve the app based on user suggestions.</p>
      """
    },
    %{
      title: "Create Custom Analytics Dashboard",
      description: """
        <p>An analytics dashboard provides key metrics and insights to help businesses track performance, identify trends, and make data-driven decisions. This task involves creating a custom dashboard that displays important data visualizations for the end-user.</p>
        <p>Steps for creating a custom analytics dashboard:</p>
        <ul>
          <li><strong>Identify Key Metrics:</strong> Determine the most important metrics to display on the dashboard, such as user sign-ups, engagement rates, conversion rates, or revenue.</li>
          <li><strong>Data Collection:</strong> Set up data pipelines to gather and aggregate data from different sources (e.g., web analytics, user activity logs, transaction data).</li>
          <li><strong>Create Visualizations:</strong> Use charts, graphs, and tables to represent the data visually. Implement filtering and sorting options for users to analyze the data more effectively.</li>
          <li><strong>Optimize Performance:</strong> Ensure that the dashboard loads quickly and can handle large datasets by implementing pagination, lazy loading, or caching.</li>
        </ul>
        <p>A well-designed analytics dashboard empowers users to understand their data better, track progress, and make informed decisions. Custom dashboards are particularly useful for businesses that need to track specific KPIs or performance indicators relevant to their operations.</p>
      """
    },
    %{
      title: "Implement Two-Factor Authentication (2FA)",
      description: """
        <p>Two-factor authentication (2FA) adds an extra layer of security to user accounts by requiring two forms of identification: something the user knows (password) and something the user has (a mobile device, security token, or authenticator app).</p>
        <p>Steps for implementing 2FA:</p>
        <ul>
          <li><strong>Choose 2FA Method:</strong> Implement a commonly used 2FA method, such as SMS-based codes, email codes, or app-based authentication (e.g., Google Authenticator, Authy).</li>
          <li><strong>Integrate 2FA with Login Process:</strong> Modify the login flow to include a second step after the user enters their password. Ask for the second factor (e.g., a code sent to their phone).</li>
          <li><strong>Allow Backup Codes:</strong> Provide users with one-time backup codes in case they lose access to their second factor.</li>
          <li><strong>Ensure Security:</strong> Implement secure transmission for sensitive data and ensure that 2FA tokens are only valid for a limited time.</li>
        </ul>
        <p>2FA significantly improves security by making it harder for attackers to gain unauthorized access to accounts. It’s especially important for applications that handle sensitive user data or financial transactions.</p>
      """
    },
    %{
      title: "Set Up Email Notification System",
      description: """
        <p>Email notifications are an essential part of many applications, providing users with timely updates and reminders. This task involves setting up an email notification system that triggers specific events to inform users about important activities, such as task updates, project changes, or system alerts.</p>
        <p>Steps to implement an email notification system:</p>
        <ul>
          <li><strong>Choose an Email Service:</strong> Select an email service provider such as SendGrid, Amazon SES, or SMTP for sending emails. Ensure the provider supports your volume needs.</li>
          <li><strong>Configure SMTP or API Integration:</strong> Set up SMTP configuration or use the provider’s API to send emails. This includes configuring the email sending server, API keys, and sender email addresses.</li>
          <li><strong>Create Email Templates:</strong> Design email templates for various notification types, such as user registration confirmation, password reset requests, or project updates. Ensure the templates are mobile-friendly and personalized.</li>
          <li><strong>Trigger Emails Based on Events:</strong> Set up event listeners in your app to trigger the appropriate email notifications. For example, an email can be sent when a task is marked as complete or when a new project is posted.</li>
        </ul>
        <p>Implementing a reliable email notification system improves user engagement by keeping them informed and involved in important app activities.</p>
      """
    },
    %{
      title: "Build a Multi-Page Application (SPA)",
      description: """
        <p>A Single-Page Application (SPA) allows for a seamless user experience by loading content dynamically without refreshing the entire page. This task involves building a multi-page SPA where different sections of the website are loaded without reloading the entire page, making the application feel faster and more interactive.</p>
        <p>Steps for building an SPA:</p>
        <ul>
          <li><strong>Set Up a Front-End Framework:</strong> Choose a front-end framework such as React, Vue.js, or Angular for building the SPA. These frameworks provide the tools to create components, handle routing, and manage state.</li>
          <li><strong>Implement Routing:</strong> Use a routing library (e.g., React Router for React) to define different routes in your application and ensure that the user is directed to the appropriate page without refreshing the entire page.</li>
          <li><strong>Load Data Dynamically:</strong> Fetch data from your back-end server using AJAX or Fetch API. Implement methods to load content dynamically when the user navigates between different sections of the app.</li>
          <li><strong>Optimize for Performance:</strong> Ensure the app loads quickly by minimizing the number of HTTP requests, using lazy loading for components, and optimizing assets.</li>
        </ul>
        <p>SPAs offer a modern, fast, and responsive user experience. They allow for smooth transitions between pages, eliminating the need for full page reloads, which results in improved user retention and satisfaction.</p>
      """
    },
    %{
      title: "Create Data Import/Export System",
      description: """
        <p>Many applications require the ability to import and export data in various formats, such as CSV, Excel, or JSON. This task involves developing a system that allows users to upload and download data files, enabling easier data management and integration with other systems.</p>
        <p>Steps for creating a data import/export system:</p>
        <ul>
          <li><strong>Design Import/Export UI:</strong> Build an intuitive user interface for uploading and downloading files. Include options to select file formats and map columns to application fields during import.</li>
          <li><strong>Handle File Parsing:</strong> Implement logic to parse different file formats, such as CSV or Excel, into structured data that can be processed by the application. Libraries like Papaparse (for CSV) or xlsx (for Excel) can be useful.</li>
          <li><strong>Implement Data Validation:</strong> Ensure that the imported data is valid by performing checks such as verifying field formats, missing data, or incorrect values.</li>
          <li><strong>Export Data in Multiple Formats:</strong> Allow users to export data in common formats like CSV, Excel, or JSON. Provide options to filter and select the data they want to export.</li>
        </ul>
        <p>Implementing an import/export system streamlines data migration, backup processes, and integration with external systems, improving the overall user experience.</p>
      """
    },
    %{
      title: "Build a Search Functionality",
      description: """
        <p>Search functionality is a critical feature in many applications, allowing users to quickly find the information they need. This task involves building an efficient search system that can handle large datasets and return relevant results in a user-friendly manner.</p>
        <p>Steps to build a search functionality:</p>
        <ul>
          <li><strong>Design Search Interface:</strong> Create a search bar or search page where users can input their queries. Add advanced filtering options, such as date ranges, categories, or tags, to refine search results.</li>
          <li><strong>Optimize for Speed:</strong> Use indexing and search algorithms like Elasticsearch or full-text search to ensure fast search results. Consider caching search results for commonly searched queries.</li>
          <li><strong>Implement Autocomplete:</strong> Enhance the search experience by implementing autocomplete suggestions as users type, helping them refine their queries and discover results more quickly.</li>
          <li><strong>Display Search Results:</strong> Show results in an organized manner, with clear labels and pagination for large result sets. Highlight the search term within the results to help users identify relevant information.</li>
        </ul>
        <p>Effective search functionality enhances user experience by making it easy to locate content, saving users time and effort in navigating the application.</p>
      """
    },
    %{
      title: "Set Up User Profile System",
      description: """
        <p>A user profile system allows users to create, update, and view their personal information. This task involves setting up the structure for user profiles, enabling them to manage their settings, preferences, and privacy options.</p>
        <p>Steps to set up a user profile system:</p>
        <ul>
          <li><strong>Design Profile Interface:</strong> Build an intuitive and user-friendly profile page where users can view and edit their information, such as their name, email, profile picture, and preferences.</li>
          <li><strong>Handle Profile Data:</strong> Implement logic to store user profile data in the database securely. Ensure that personal information such as email addresses and passwords are encrypted and protected.</li>
          <li><strong>Implement Profile Privacy Settings:</strong> Allow users to control the visibility of their profiles and decide which information is public or private. Implement options to make certain fields (e.g., email) visible only to admins or the user themselves.</li>
          <li><strong>Enable Profile Updates:</strong> Allow users to update their profiles with new information or images. Implement validation for input fields (e.g., check for valid email formats).</li>
        </ul>
        <p>A user profile system empowers users to manage their personal data while providing an essential layer of customization and security within the application.</p>
      """
    },
    %{
      title: "Integrate Social Media Sharing",
      description: """
        <p>Social media sharing allows users to share content from your website or app directly to their social media profiles. This task involves integrating social media sharing buttons or widgets into your application to improve engagement and help your content reach a wider audience.</p>
        <p>Steps to integrate social media sharing:</p>
        <ul>
          <li><strong>Choose Social Media Platforms:</strong> Decide which platforms you want to support, such as Facebook, Twitter, LinkedIn, or Instagram. Each platform will have its own API or sharing mechanism.</li>
          <li><strong>Embed Share Buttons:</strong> Use ready-made widgets or develop custom share buttons that allow users to share content with a single click. Ensure that the buttons are mobile-friendly and easy to find.</li>
          <li><strong>Enable Open Graph Tags:</strong> Implement Open Graph meta tags to control how content appears when shared on social media platforms, including titles, images, and descriptions.</li>
          <li><strong>Track Shares:</strong> Implement analytics to track social media sharing activity. Use this data to measure the success of your content and understand user engagement.</li>
        </ul>
        <p>Integrating social media sharing increases brand visibility, encourages user interaction, and drives traffic to your website, helping grow your app's reach.</p>
      """
    },
    %{
      title: "Develop API for User Authentication",
      description: """
        <p>User authentication is a crucial part of many web applications, allowing users to securely log in and access their data. This task involves developing an API to handle user registration, login, and authentication processes, ensuring that only authorized users can access specific parts of the application.</p>
        <p>Steps to develop the authentication API:</p>
        <ul>
          <li><strong>Set Up User Registration:</strong> Implement a registration API endpoint where users can sign up by providing their basic details, such as username, email, and password. Ensure that the passwords are hashed before storing them in the database.</li>
          <li><strong>Implement User Login:</strong> Create a login endpoint that accepts the user's credentials (username/email and password) and validates them against the stored data. Upon successful authentication, generate a secure session or JWT (JSON Web Token) for the user.</li>
          <li><strong>Enable Password Reset:</strong> Implement functionality to allow users to reset their passwords. This typically involves sending an email with a secure link to reset their password.</li>
          <li><strong>Secure API Endpoints:</strong> Protect sensitive data by ensuring that API routes requiring authentication are secured with proper validation checks using tokens or sessions.</li>
        </ul>
        <p>Building a robust API for user authentication will ensure that your application is secure and that only authorized users can access protected data or services.</p>
      """
    },
    %{
      title: "Create a Real-Time Chat Feature",
      description: """
        <p>Real-time chat features enable users to communicate instantly within your application. This task involves building a chat system that supports real-time messaging, allowing users to send and receive messages instantly.</p>
        <p>Steps to create a real-time chat feature:</p>
        <ul>
          <li><strong>Set Up WebSocket Connection:</strong> Use WebSockets or a real-time service like Firebase or Socket.io to create a persistent connection between the client and server. This allows messages to be delivered instantly without needing to refresh the page.</li>
          <li><strong>Build Chat Interface:</strong> Create a user-friendly interface where users can type messages and see them appear in real-time. Implement features like message bubbles, timestamps, and read receipts.</li>
          <li><strong>Implement Message Storage:</strong> Store the messages in a database so that users can view their chat history. Ensure that messages are properly indexed for fast retrieval.</li>
          <li><strong>Handle User Notifications:</strong> Add a feature to notify users when they receive a new message, especially if they are not currently viewing the chat window.</li>
        </ul>
        <p>Adding real-time chat functionality enhances communication within the application, allowing users to interact with each other in a dynamic and responsive manner.</p>
      """
    },
    %{
      title: "Implement Data Validation for User Inputs",
      description: """
        <p>Data validation is critical to ensure that user inputs are correct and secure. This task involves implementing validation rules for user-submitted data across your application, ensuring that the inputs meet the required criteria before being processed or stored.</p>
        <p>Steps to implement data validation:</p>
        <ul>
          <li><strong>Set Up Front-End Validation:</strong> Implement client-side validation for input fields such as email addresses, phone numbers, and passwords. Use regular expressions (regex) to validate the format and provide real-time feedback to users.</li>
          <li><strong>Backend Validation:</strong> Perform server-side validation as a backup to the front-end validation. Ensure that data is properly sanitized and verified before storing it in the database to prevent malicious attacks like SQL injection or cross-site scripting (XSS).</li>
          <li><strong>Display Clear Error Messages:</strong> Provide helpful and informative error messages when validation fails. Highlight the fields that need correction and provide guidelines for users to fix their input.</li>
          <li><strong>Prevent Invalid Submissions:</strong> Disable form submission until all fields are validated, ensuring that users cannot submit incomplete or invalid data.</li>
        </ul>
        <p>Data validation improves the quality and security of the data collected through your application and enhances the user experience by preventing errors and mistakes during form submissions.</p>
      """
    },
    %{
      title: "Create a Multi-Language Support System",
      description: """
        <p>In a globalized world, supporting multiple languages in your application is essential to reach a wider audience. This task involves creating a multi-language support system that enables users to select their preferred language for interacting with the application.</p>
        <p>Steps to create multi-language support:</p>
        <ul>
          <li><strong>Choose a Localization Framework:</strong> Select a localization library or framework that supports multiple languages, such as i18next (for JavaScript) or gettext (for Elixir). This will help manage translations and language-specific formatting.</li>
          <li><strong>Translate Text:</strong> Translate all the static text in your application, including buttons, labels, messages, and error text, into the supported languages. Use a file-based structure to store translations for each language.</li>
          <li><strong>Detect User Language:</strong> Implement automatic language detection based on the user's browser settings or allow users to manually select their preferred language from a language dropdown menu.</li>
          <li><strong>Format Data for Different Languages:</strong> Consider formatting dates, numbers, and currencies according to the user's locale. This ensures that the application feels natural and culturally relevant to users in different regions.</li>
        </ul>
        <p>Multi-language support enhances accessibility and expands the user base of your application, allowing it to serve diverse audiences across different countries and languages.</p>
      """
    },
    %{
      title: "Optimize Website for Performance",
      description: """
        <p>Performance optimization is key to providing a smooth and fast user experience. This task involves identifying bottlenecks in your application and implementing strategies to enhance the performance, ensuring that pages load quickly and that the application runs efficiently even under heavy load.</p>
        <p>Steps to optimize website performance:</p>
        <ul>
          <li><strong>Minify and Compress Assets:</strong> Minify your CSS, JavaScript, and HTML files to reduce their size. Also, compress images and videos to ensure they load quickly without sacrificing quality.</li>
          <li><strong>Leverage Caching:</strong> Use browser caching to store static assets (like images, stylesheets, and JavaScript files) on the user's device. This allows for faster page loads on subsequent visits.</li>
          <li><strong>Use Content Delivery Networks (CDNs):</strong> Use CDNs to distribute your static assets across multiple global servers, reducing load times and improving access speed for users worldwide.</li>
          <li><strong>Optimize Database Queries:</strong> Review your database queries to ensure they are optimized. Implement indexing and reduce the number of database calls to minimize server load and improve response times.</li>
        </ul>
        <p>Website performance optimization improves the user experience by providing fast load times, reduced bounce rates, and better engagement, ultimately leading to higher conversion rates.</p>
      """
    },
    %{
      title: "Design Mobile-Friendly User Interface",
      description: """
        <p>Designing a mobile-friendly user interface (UI) ensures that users on mobile devices can easily interact with your application. This task involves making your existing web application responsive by ensuring it adjusts seamlessly to different screen sizes and resolutions.</p>
        <p>Steps to design a mobile-friendly UI:</p>
        <ul>
          <li><strong>Use Responsive Design Principles:</strong> Implement flexible layouts that automatically adjust to various screen sizes. Use relative units like percentages and ems instead of fixed pixels to ensure scalability on different devices.</li>
          <li><strong>Ensure Touch-Friendly UI Elements:</strong> Make buttons, forms, and other interactive elements large enough to be easily tapped on a touchscreen device. Consider the mobile user experience when designing navigation menus and links.</li>
          <li><strong>Test Across Devices:</strong> Use tools like Chrome DevTools or real-device testing to ensure your application looks good on a variety of screen sizes. Emulate mobile devices and check the layout, fonts, images, and buttons for usability.</li>
          <li><strong>Optimize Performance for Mobile:</strong> Minimize image sizes, reduce unnecessary animations, and optimize code to enhance the speed and performance of the mobile version of your application.</li>
        </ul>
        <p>Designing a mobile-friendly UI is essential for providing a positive user experience, especially as more users access websites and applications through mobile devices.</p>
      """
    },
    %{
      title: "Implement Role-Based Access Control (RBAC)",
      description: """
        <p>Role-Based Access Control (RBAC) is a security model that restricts access to resources based on the user's role within an organization. This task involves implementing an RBAC system in your application to ensure that users only have access to the resources and actions they are authorized to use.</p>
        <p>Steps to implement RBAC:</p>
        <ul>
          <li><strong>Define Roles and Permissions:</strong> Identify different roles within your application (e.g., admin, user, manager) and the permissions associated with each role. For example, an admin might have full access, while a regular user might only have access to their profile.</li>
          <li><strong>Implement Role Assignment:</strong> Ensure that each user is assigned a role during registration or account creation. This can be done manually by an admin or automatically during sign-up.</li>
          <li><strong>Secure Routes and Resources:</strong> Add middleware or access control logic to secure routes and resources based on the user's role. Only users with the appropriate role should be able to access certain pages or perform specific actions.</li>
          <li><strong>Audit and Review Access Levels:</strong> Regularly audit and review user roles and permissions to ensure that they are appropriate. Make sure that users don’t retain access to sensitive resources if their role or job function changes.</li>
        </ul>
        <p>Implementing RBAC helps maintain a secure system by ensuring that users have access only to the data and actions that they are permitted to perform, reducing the risk of unauthorized access.</p>
      """
    },
    %{
      title: "Integrate Payment Gateway for Online Transactions",
      description: """
        <p>Integrating a payment gateway allows your application to process online transactions securely. This task involves integrating a third-party payment provider (e.g., Stripe, PayPal) into your platform so that users can make payments for services or products.</p>
        <p>Steps to integrate a payment gateway:</p>
        <ul>
          <li><strong>Select a Payment Provider:</strong> Choose a reliable payment gateway that suits your needs. Popular options include Stripe, PayPal, and Square. Consider factors like transaction fees, ease of use, and supported countries.</li>
          <li><strong>Set Up API Keys:</strong> After creating an account with your selected payment provider, retrieve the API keys necessary to authenticate your application with their service. Keep these keys secure and avoid exposing them in public code.</li>
          <li><strong>Implement Payment Flow:</strong> Create an endpoint where users can submit their payment information. Securely collect and process payment details, such as credit card numbers, billing addresses, and payment amounts.</li>
          <li><strong>Handle Payment Confirmation:</strong> After a successful payment, confirm the transaction and update the user's order or subscription status. Send email confirmations and receipts to both the user and your system for record-keeping.</li>
        </ul>
        <p>Integrating a payment gateway provides your users with a seamless and secure method to make online transactions, increasing the convenience and trust in your platform.</p>
      """
    },
    %{
      title: "Build a Search Functionality for Users",
      description: """
        <p>A search functionality allows users to quickly find specific content or items within your application. This task involves implementing an efficient search feature that can quickly retrieve relevant results based on the user's query.</p>
        <p>Steps to build a search functionality:</p>
        <ul>
          <li><strong>Design the Search Interface:</strong> Create a simple and intuitive search bar where users can enter their queries. Optionally, you can add filters or categories to refine the search results.</li>
          <li><strong>Index Data for Faster Retrieval:</strong> Implement indexing techniques, such as full-text search or inverted indexes, to ensure that search queries are processed quickly. Using search libraries like Elasticsearch or database features like PostgreSQL's full-text search can speed up the search process.</li>
          <li><strong>Implement Search Algorithms:</strong> Implement search algorithms that rank and display results based on relevance. Consider using fuzzy matching or partial string matching for more flexible results.</li>
          <li><strong>Display Search Results:</strong> Display search results clearly with relevant information and pagination to handle large result sets. Allow users to easily click through to the detailed view of the results.</li>
        </ul>
        <p>Search functionality is an important feature that enhances usability and user experience, allowing users to find information quickly and easily within your platform.</p>
      """
    },
    %{
      title: "Create User Profile and Settings Page",
      description: """
        <p>A user profile and settings page allows users to view and update their personal information, preferences, and account settings. This task involves creating a page where users can manage their account details, change settings, and personalize their experience on the platform.</p>
        <p>Steps to create a user profile and settings page:</p>
        <ul>
          <li><strong>Design the Profile Layout:</strong> Design an intuitive profile page layout that displays the user's information, such as name, email, profile picture, and any other relevant details.</li>
          <li><strong>Allow Profile Updates:</strong> Provide editable fields where users can update their profile details, such as their name, email, password, and contact information. Ensure that changes are validated and securely saved to the database.</li>
          <li><strong>Enable Account Settings:</strong> Allow users to configure account settings, such as email notifications, privacy preferences, and language settings. Provide a simple interface to make these updates.</li>
          <li><strong>Display Activity History:</strong> Include a section to show recent activity, such as login history, changes made to the profile, or recent orders/purchases. This helps users track their account usage.</li>
        </ul>
        <p>Having a user profile and settings page gives users control over their account, allowing them to customize their experience and keep their information up to date.</p>
      """
    },
    %{
      title: "Implement Email Notifications for User Activities",
      description: """
        <p>Email notifications play a critical role in keeping users informed about their activities and updates on the platform. This task involves setting up email notifications to alert users about important events, such as password changes, new messages, or order updates.</p>
        <p>Steps to implement email notifications:</p>
        <ul>
          <li><strong>Identify Key Events:</strong> Determine which user activities should trigger an email notification. Common events include account registration, password resets, new messages, order status changes, or subscription renewals.</li>
          <li><strong>Integrate an Email Service:</strong> Choose an email service provider like SendGrid, Mailgun, or Amazon SES for sending emails. Set up the provider’s API integration to send emails directly from your application.</li>
          <li><strong>Design Email Templates:</strong> Create clear and professional email templates for each type of notification. Include relevant details in the subject line and body, ensuring the message is actionable and concise.</li>
          <li><strong>Trigger Emails Based on Events:</strong> Set up event listeners or hooks within your application to trigger emails when specific actions occur. For example, when a user resets their password or receives a message, the appropriate email template should be triggered.</li>
          <li><strong>Monitor Email Delivery:</strong> Regularly check email delivery reports to ensure that notifications are successfully sent and received. Implement retry mechanisms or error handling in case of delivery failures.</li>
        </ul>
        <p>Email notifications keep users engaged and informed, ensuring they don’t miss important events within the platform. They also improve the overall user experience by providing timely updates.</p>
      """
    },
    %{
      title: "Build a Multi-Step Form for Data Collection",
      description: """
        <p>A multi-step form is a user-friendly interface that breaks down a lengthy form into smaller, manageable sections. This task involves creating a multi-step form that guides users through different stages of the form-filling process while maintaining a seamless user experience.</p>
        <p>Steps to build a multi-step form:</p>
        <ul>
          <li><strong>Break Down the Form into Steps:</strong> Identify the different sections of the form and divide them into logical steps. For example, a user registration form could have steps for personal information, contact details, and account preferences.</li>
          <li><strong>Design the Navigation:</strong> Add buttons to allow users to navigate between steps, such as "Next," "Back," and "Submit." Ensure the navigation is intuitive and clearly indicates the user’s progress (e.g., using a progress bar or step indicators).</li>
          <li><strong>Validate Each Step:</strong> Implement client-side validation for each step of the form to ensure that the information entered is correct before proceeding. Display error messages for invalid inputs and prevent users from moving to the next step until the form is complete.</li>
          <li><strong>Persist Form Data:</strong> Store the data entered by users at each step to ensure that it isn’t lost if they navigate backward or leave the page. Consider using local storage, session storage, or a backend database to save the form state.</li>
          <li><strong>Review and Submit:</strong> Include a final review step where users can review their entries before submitting the form. Allow users to make corrections if necessary, then submit the data to the server.</li>
        </ul>
        <p>Multi-step forms improve user experience by breaking down complex tasks into simpler steps. They help reduce form abandonment and improve the likelihood of successful data collection.</p>
      """
    }
  ]

tags_lists = [
  ["email-notifications", "user-activities", "event-triggers"],
  ["password-reset", "security", "user-authentication", "email-service"],
  ["user-messages", "chat-integration", "user-engagement", "real-time"],
  ["order-updates", "transactional-emails", "subscription-renewals", "API-integration"],
  ["email-service", "template-design", "sendgrid", "mailgun"],
  ["API-integration", "email-notifications", "retry-mechanisms", "monitoring"],
  ["user-engagement", "UX-improvement", "email-delivery", "A/B-testing"],
  ["multi-step-form", "form-validation", "user-experience", "progress-bar"],
  ["input-validation", "form-data", "client-side-validation", "error-handling"],
  ["user-registration", "account-preferences", "password-reset", "form-submission"],
  ["email-service", "subscription-renewals", "sendgrid", "mailgun"],
  ["data-collection", "user-feedback", "multi-step-form", "form-abandonment"],
  ["session-storage", "form-persistence", "local-storage", "progress-bar"],
  ["contact-details", "user-authentication", "user-profile", "form-validation"],
  ["user-login", "password-reset", "authentication", "form-error-messages"],
  ["UX-improvement", "multi-step-process", "form-error-messages", "client-side-validation"],
  ["form-validation", "multi-step-process", "user-experience", "real-time"],
  ["task-status", "project-management", "real-time-updates", "notifications"],
  ["input-fields", "form-error-messages", "field-validation", "UX-improvement"],
  ["multi-step-form", "progress-bar", "form-validation", "submit-button"],
  ["form-submission", "progress-bar", "form-data", "input-fields"],
  ["form-validation", "user-registration", "field-validation", "client-side-validation"],
  ["data-collection", "user-activity", "progress-bar", "form-submission"],
  ["session-storage", "input-validation", "user-profile", "multi-step-form"],
  ["retry-mechanisms", "API-integration", "user-authentication", "password-reset"],
  ["real-time-updates", "user-engagement", "email-notifications", "user-feedback"],
  ["contact-details", "user-profile", "email-notifications", "real-time"],
  ["multi-step-process", "UX-improvement", "progress-bar", "submit-button"],
  ["password-reset", "API-integration", "user-engagement", "form-error-messages"],
  ["form-abandonment", "error-handling", "form-persistence", "UX-improvement"],
  ["transactional-emails", "order-updates", "email-service", "subscription-renewals"],
  ["monitoring", "retry-mechanisms", "email-notifications", "email-template"],
  ["input-fields", "form-validation", "data-collection", "field-validation"],
  ["task-status", "user-activity", "form-submission", "form-validation"],
  ["user-profile", "password-reset", "contact-details", "form-persistence"],
  ["user-registration", "real-time", "multi-step-form", "submit-button"],
  ["user-feedback", "user-engagement", "multi-step-process", "form-validation"],
  ["transactional-emails", "email-template", "form-validation", "real-time-updates"],
  ["progress-bar", "data-collection", "user-authentication", "UX-improvement"],
  ["monitoring", "retry-mechanisms", "API-integration", "real-time"]
]

random_date = fn ->
  start_date = ~U[2024-01-01 00:00:00Z]
  end_date = DateTime.utc_now()
  random_seconds = :rand.uniform(DateTime.diff(end_date, start_date, :second))
  DateTime.add(start_date, random_seconds, :second)
end

random_date_with_initail_state = fn starting_date ->
  end_date = DateTime.utc_now()
  random_seconds = :rand.uniform(DateTime.diff(end_date, starting_date, :second))
  DateTime.add(starting_date, random_seconds, :second)
end

create_users = fn users, role ->
  Enum.map(users, fn user ->
    date = random_date.()

    user =
      Repo.insert!(%User{
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        hashed_password: Bcrypt.hash_pwd_salt("Pa$$w0rd!"),
        role: role,
        rating: Float.round(:rand.uniform() * 5, 2),
        location: user.location,
        bio: user.bio,
        gender: if(user.first_name in ["Jessica", "Tina"], do: :female, else: :male),
        terms: true,
        birthdate: Date.utc_today(),
        username: user.username,
        confirmed_at: date,
        inserted_at: date,
        updated_at: date
      })

    np_params = Map.put(Enum.random(notification_preferences), :user_id, user.id)
    %NotificationPreference{} |> NotificationPreference.changeset(np_params) |> Repo.insert!()
    user |> get_preload([:notification_preference])
  end)
end

# Create clients and freelancers
created_clients = create_users.(clients, :client)
created_freelancers = create_users.(freelancers, :freelancer)
# Create projects with realistic titles and descriptions

send_payment_notif_to_client = fn client, freelancer, task, project ->
  if client.notification_preference.push do
    notif_date = random_date_with_initail_state.(task.updated_at)

    Repo.insert!(%Notification{
      type: :push,
      user_id: project.client_id,
      link: "/projects/#{project.id}/tasks/#{task.id}/show",
      message: """
        <p><strong>#{full_name(freelancer)}</strong> asked to release payment for the task #{task.title} associated with the project #{project.title} </p>
      """,
      is_read?: Enum.random([true, false]),
      inserted_at: notif_date,
      updated_at: notif_date
    })
  end
end

update_task_column = fn bid, task, columns, freelancer, client, project ->
  selected_column = columns |> Enum.at(Enum.random(1..2))

  task_params =
    if selected_column.name == "Completed" do
      send_payment_notif_to_client.(client, freelancer, task, project)

      %{
        "column_id" => selected_column.id,
        "is_completed?" => true,
        "freelancer_id" => freelancer.id,
        "ask_for_payment" => true
      }
    else
      %{
        "column_id" => selected_column.id,
        "freelancer_id" => freelancer.id
      }
    end

  Tasks.update_task(task, task_params)
end

send_notif_to_freelancer = fn client, freelancer, task, project ->
  if client.notification_preference.push do
    notif_date = random_date_with_initail_state.(task.updated_at)

    Repo.insert!(%Notification{
      user_id: freelancer.id,
      message: """
      <p><strong>#{full_name(client)}</strong> has been accepted your bid against the task #{task.title}. and added you in the project #{project.title} </p>
      """,
      type: :push,
      link: "tasks/#{task.id}/show",
      is_read?: Enum.random([true, false]),
      inserted_at: notif_date,
      updated_at: notif_date
    })
  end
end

send_notif_to_client = fn bid, client, freelancer, task, project ->
  if client.notification_preference.push do
    notif_date = random_date_with_initail_state.(bid.inserted_at)

    Repo.insert!(%Notification{
      user_id: client.id,
      message: """
      <p><strong>#{full_name(freelancer)}</strong> applied for the task #{task.title} associated with the project #{project.title} </p>
      """,
      type: :push,
      link: "bids/#{bid.id}/show",
      is_read?: Enum.random([true, false]),
      inserted_at: notif_date,
      updated_at: notif_date
    })
  end
end

accept_bids = fn task, client, project, freelancer, columns ->
  if task.find_freelancer? do
    task_with_bids = get_preload(task, :bids)

    {:ok, bid} =
      task_with_bids.bids
      |> Enum.random()
      |> Tasks.update_bid(%{"status" => :accepted})

    send_notif_to_freelancer.(client, freelancer, task, project)
    update_task_column.(bid, task, columns, freelancer, client, project)
    is_user_already_in_project(Repo.preload(bid, task: :project))

    # Add comments and replies
    Enum.each(1..3, fn _ ->
      comment_date = random_date_with_initail_state.(task.updated_at)

      comment =
        Repo.insert!(%Comment{
          message: "This is a comment on task: #{task.title}.",
          task_id: task.id,
          user_id: client.id,
          inserted_at: comment_date,
          updated_at: comment_date
        })

      Enum.each(1..3, fn index ->
        user = if rem(index, 2) == 0, do: client, else: Accounts.get_user!(bid.freelancer_id)

        reply_date = random_date_with_initail_state.(comment.inserted_at)

        Repo.insert!(%Reply{
          message:
            "This is a reply to comment: #{comment.id} by #{user.first_name} #{user.last_name}.",
          comment_id: comment.id,
          user_id: user.id,
          inserted_at: reply_date,
          updated_at: reply_date
        })
      end)
    end)
  end
end

create_channels = fn project, client ->
  joiners =
    project
    |> Repo.preload(project_freelancers: :freelancer)
    |> get_project_freelancers()
    |> Enum.map(& &1.id)

  channel_date = random_date_with_initail_state.(project.inserted_at)

  channel =
    Repo.insert!(%Channel{
      name: "Channel for #{project.title}",
      joiners: joiners,
      project_id: project.id,
      created_by_id: client.id,
      inserted_at: channel_date,
      updated_at: channel_date
    })

  senders = joiners ++ [client.id]

  for _ <- 1..Enum.random(3..10) do
    message_date = random_date_with_initail_state.(channel.inserted_at)

    Repo.insert!(%Message{
      body: """
        <p><strong>New message for #{project.title}:</strong></p>
        <p>
        #{Enum.random(["Looking forward to working on this project.", "Let’s discuss the project requirements in detail.", "Here are some ideas on how we could proceed.", "Please review the updates and let me know your feedback.", "Is there a specific deadline for this project?", "I'll send the initial draft by the end of the day."])}
        </p>
      """,
      sender_id: Enum.random(senders),
      channel_id: channel.id,
      inserted_at: message_date,
      updated_at: message_date
    })
  end
end

create_bids = fn task, project, client, columns ->
  for freelancer <- Enum.take_random(created_freelancers, Enum.random(6..18)) do
    attached_files =
      Enum.map(1..4, fn _ ->
        "https://asset.cloudinary.com/dmkkivjv3/cb13850a32552725cc83943f00496892"
      end)

    if task.find_freelancer? do
      bid_date = random_date_with_initail_state.(task.inserted_at)

      applied_bid =
        Repo.insert!(%Bid{
          amount: generate_random_float(100, 1000),
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
          attached_files: attached_files,
          inserted_at: bid_date,
          updated_at: bid_date
        })

      send_notif_to_client.(applied_bid, client, freelancer, task, project)
    end

    accept_bids.(task, client, project, freelancer, columns)
  end
end

create_tasks = fn project, columns, client, sprint ->
  budget_for_each_task = project.budget / length(task_list)

  for {task, index} <- Enum.with_index(Enum.take_random(task_list, 8)) do
    deadline = Date.new!(2025, Enum.random(1..12), Enum.random(1..28))
    find_freelancer? = Enum.random([true, false])

    attachments =
      Enum.map(1..4, fn _ ->
        "https://asset.cloudinary.com/dmkkivjv3/cb13850a32552725cc83943f00496892"
      end)

    task_date = random_date_with_initail_state.(project.inserted_at)

    generated_task =
      Repo.insert!(%Task{
        title: task.title,
        description: task.description,
        is_completed?: if(find_freelancer?, do: Enum.random([true, false]), else: false),
        find_freelancer?: find_freelancer?,
        budget: budget_for_each_task,
        deadline: deadline,
        sprint_id: sprint.id,
        column_id: hd(columns).id,
        project_id: project.id,
        attachments: attachments,
        tags: Enum.at(tags_lists, index),
        experience_required: Enum.random([:beginner, :intermediate, :expert]),
        inserted_at: task_date,
        updated_at: task_date
      })

    create_bids.(generated_task, project, client, columns)
  end
end

created_projects = fn ->
  for proj <- projects_list do
    client = Enum.random(created_clients)
    project_status = Project.all_statuses() |> Enum.reject(&(&1 == :completed)) |> Enum.random()
    proj_date = random_date_with_initail_state.(client.inserted_at)

    project =
      Repo.insert!(%Project{
        title: proj.title,
        description: proj.description,
        status: project_status,
        budget: generate_random_float(10000, 100_000),
        client_id: client.id,
        inserted_at: proj_date,
        updated_at: proj_date
      })

    Sprint.get_default_sprints()
    |> Enum.with_index()
    |> Enum.map(fn {title, index} ->
      ss_date = project.inserted_at |> DateTime.add((index + 1) * 7, :day) |> DateTime.to_date()
      se_date = Date.add(ss_date, 6)
      sprint_date = random_date_with_initail_state.(project.inserted_at)

      sprint =
        Repo.insert!(%Sprint{
          title: title,
          project_id: project.id,
          start_date: ss_date,
          end_date: se_date,
          inserted_at: sprint_date,
          updated_at: sprint_date
        })

      columns =
        Enum.map(
          Column.get_default_columns(),
          fn name ->
            col_date = random_date_with_initail_state.(sprint.inserted_at)

            Repo.insert!(%Column{
              name: "#{name} - #{sprint.id}",
              sprint_id: sprint.id,
              inserted_at: col_date,
              updated_at: col_date
            })
          end
        )

      create_tasks.(project, columns, client, sprint)
    end)

    create_channels.(project, client)
  end
end

created_projects.()
