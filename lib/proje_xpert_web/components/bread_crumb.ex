defmodule ProjeXpertWeb.BreadCrumb do
  use ProjeXpertWeb, :live_component

  def render(assigns) do
    ~H"""
    <nav aria-label="Breadcrumb">
      <ol class="flex items-center space-x-2 text-sm text-gray-600">
        <.link navigate={@home_link} class="hover:text-primary transition-colors duration-200">
          <li>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-5 w-5"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
              />
            </svg>
            <span class="sr-only">Home</span>
          </li>
        </.link>
        <%= for {label, link} <- @breadcrumbs do %>
          <li class="flex items-center">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-5 w-5 text-gray-400"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </li>
          <.link
            navigate={link}
            class={
              [
                "hover:text-primary transition-colors duration-200",
                get_active_breadcrumb(label, @breadcrumbs) && "text-primary font-semibold"
              ]
              |> Enum.join(" ")
            }
          >
            <li>
              <%= label %>
            </li>
          </.link>
        <% end %>
      </ol>
    </nav>
    """
  end

  def update(assigns, socket) do
    path = Map.get(assigns, :path, "/")
    current_path = URI.parse(path).path
    breadcrumbs = current_path |> get_segments() |> generate_breadcrumbs()

    {:ok,
     socket
     |> assign(breadcrumbs: breadcrumbs, home_link: "/", current_path: current_path)}
  end

  defp generate_breadcrumbs(segments) do
    segments
    |> Enum.with_index()
    |> Enum.reduce([], fn {segment, index}, acc ->
      previous_link =
        case acc |> Enum.reverse() |> List.first() do
          {_, link} -> link
          nil -> "/"
        end

      next_link =
        cond do
          segment == String.split(previous_link, "/") |> Enum.at(-1) ->
            previous_link

          is_integer?(segment) ->
            previous_link |> Path.join(segment) |> Path.join(Enum.at(segments, index + 1))

          true ->
            Path.join(previous_link, segment)
        end

      acc ++ [{String.capitalize(segment), next_link}]
    end)
  end

  defp get_segments(current_path), do: String.split(current_path, "/", trim: true)

  defp is_integer?(value) when is_binary(value) do
    case Integer.parse(value) do
      {int_value, ""} when is_integer(int_value) ->
        true

      _ ->
        false
    end
  end

  defp get_active_breadcrumb(label, breadcrumbs) do
    String.downcase(label) ==
      List.last(breadcrumbs) |> elem(1) |> String.split("/") |> Enum.at(-1) |> String.downcase()
  end
end
