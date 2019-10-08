defmodule Neo4j.Sips.Response.Test do
  use ExUnit.Case, async: true
  import Indifferent.Sigils

  alias Neo4j.Sips.Response
  alias Neo4j.Sips.TestHelper

  test "loading a supported error response structure" do
    path = "./test/fixtures/error_response.json"
    sip = path |> TestHelper.read_whole_file() |> Jason.decode!() |> Response.new()
    {:error, reason} = Response.to_rows(sip)
    assert length(reason) > 0 and List.first(reason)["code"] == "Neo.ClientError.Statement.InvalidSyntax"
  end

  test "loading a transaction response structure" do
    path = "./test/fixtures/tx_response.json"
    sip = path |> TestHelper.read_whole_file() |> Jason.decode!() |> Response.new()
    {:ok, rows} = Response.to_rows(sip)

    assert [%{"n" => %{"name" => "My Node"}}] = rows
    assert %{"expires" => "Sun, 9 Aug 2015 14:33:42 +0000"} = ~i(sip.transaction)
  end
end
