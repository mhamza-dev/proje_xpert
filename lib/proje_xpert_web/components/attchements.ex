defmodule ProjeXpertWeb.Attchements do
  use ProjeXpertWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="bg-white flex flex-col items-center justify-center">
      <div class="flex flex-col lg:px-10 py-8 rounded-3xl w-full">
        <div class="font-medium self-center text-xl sm:text-3xl text-gray-900 mb-12">
          Attachment: <%= @title %>
        </div>
        <div class="max-h-[500px] min-w-[900px] overflow-y-scroll"><iframe src={@source} width="900" height="700"></iframe></div>
        <div class="flex justify-center mr-3">
          <.link navigate={@redirect_to} type="button" class="text-gray-900 rounded-lg hover:bg-gray-100 py-2 px-3">
            Cancel
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
