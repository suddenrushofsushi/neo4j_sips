defmodule Neo4j.Sips.Response do
  @moduledoc ~S"""
  Defines the structure for a raw REST response received from a Neo4j server.
  """

  defstruct [:results, :transaction, :commit, :errors]
  use ExConstructor
  import Indifferent.Sigils

  def to_rows(sip) do
    get_results(sip, "row")
  end

  def to_graph(sip) do
    get_results(sip, "graph")
  end

  def to_options(sip, options) do
    errors = ~i(sip.errors)
    if (length(errors) > 0) do
      {:error, errors}
    else
      # 1. IO.inspect(options |> Enum.map &({String.to_atom(&1), format_response(~i(sip.results), &1)}))
      # 2. IO.inspect(Enum.map(options, fn opt -> {String.to_atom(opt), format_response(~i(sip.results), opt)} end))
      {:ok, options |> Enum.map(&{String.to_atom(&1), get_row_or_graph(sip, &1)})}
    end
  end

  defp get_results(sip, row_or_graph) do
    errors = ~i(sip.errors)
    if (length(errors) > 0) do
      {:error, errors}
    else
      {:ok, ~i(sip.results) |> Enum.map(&format_response(&1, row_or_graph)) |> List.first}
    end
  end

  # todo: refactor me, see (1) and (2) above
  defp get_row_or_graph(sip, row_or_graph) do
    errors = ~i(sip.errors)

    if (length(errors) > 0) do
      {:error, errors}
    else
      ~i(sip.results)
      |> Enum.map(&format_response(&1, row_or_graph))
      |> List.first

    end
  end


  defp format_response(response, row_or_graph) do
    columns = response["columns"]

    case row_or_graph do
      "row" ->
        response["data"]
        |> Enum.map(fn data -> Map.get(data, row_or_graph) end)
        |> Enum.map(fn data -> Enum.zip(columns, data) end)
        |> Enum.map(fn data -> Enum.into(data, %{}) end)

      "graph" ->
        response["data"]
        |> Enum.map(fn data -> Map.get(data, row_or_graph) end)

    end
  end

end
