defmodule ProjeXpertWeb.TableComponent do
  use ProjeXpertWeb, :live_component

  attr(:headers, :list, default: ["Id", "First Name", "Last Name", "Email", "Phone Number"])
  attr(:has_actions?, :boolean, default: true)

  slot(:table_cells, required: true)

  def render(assigns) do
    ~H"""
    <div class="flex flex-col mt-6">
      <div class="overflow-x-auto border border-gray-200 rounded-lg min-h-[620px]">
        <div class="inline-block min-w-full align-middle">
          <div class="max-h-[550px]">
            <table class="min-w-full">
              <thead class="bg-gray-50 sticky top-0 z-50 shadow-md">
                <tr>
                  <th
                    :for={header <- @headers}
                    scope="col"
                    class="py-3.5 px-4 text-sm font-normal text-left text-gray-500 w-auto"
                  >
                    <%= header %>
                  </th>
                  <th
                    :if={@has_actions?}
                    scope="col"
                    class="py-3.5 px-4 text-sm font-normal text-left text-gray-500 w-auto"
                  >
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white overflow-y-scroll w-full">
                <%= render_slot(@table_cells) %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
