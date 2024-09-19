defmodule ProjeXpertWeb.LiveHelpers do

  def camel_case_string(value) when is_atom(value) do
    value |> to_string() |> camel_case_string()
  end

  def camel_case_string(value) when is_binary(value) do
    value |> String.split("_") |> Enum.join(" ") |> String.capitalize()
  end
end
