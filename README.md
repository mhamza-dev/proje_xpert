# ProjeXpert

ProjeXpert is a task marketplace platform where clients can post projects with multiple tasks, and freelancers can bid to work on them. It combines features of freelance marketplaces like Upwork and project management tools, providing real-time collaboration and task management using Elixir, Phoenix, and LiveView.

## To start your Phoenix server:

  * Run `mix setup` to install dependencies, create, and migrate the database
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Features

  * Post and manage projects with multiple tasks
  * Freelancers can bid on tasks with descriptions
  * Real-time task updates and collaboration using LiveView
  * Role-based user access (Client/Freelancer)
  * OAuth2 authentication via Google

## Database Setup

  * Run `mix ecto.create` to create the database
  * Run `mix ecto.migrate` to migrate the database schema
  * Run `mix run priv/repo/seeds.exs` to seed the database with sample data

## Ready to run in production?

Please [check the deployment guides](https://hexdocs.pm/phoenix/deployment.html) for deploying Phoenix applications to platforms like Fly.io or Gigalixir.

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Contributing

We welcome contributions! Feel free to fork the repository, submit issues, and create pull requests.
