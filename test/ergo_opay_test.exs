defmodule ErgoPayTest do
  use ExUnit.Case
  alias Plug.Test
  @opts ErgoPay.Router.init([])

  test "should return ok on /" do
    conn = Test.conn(:get, "/") |> ErgoPay.Router.call(@opts)
    assert conn.status == 200
    assert conn.resp_body == "ok"
  end

  test "should reject missing id" do
    conn = Test.conn(:get, "/auth") |> ErgoPay.Router.call(@opts)
    assert conn.status == 400
    assert Jason.decode!(conn.resp_body)["message"] == "Missing id"
  end

  test "should accept multiple_check" do
    conn =
      Test.conn(:post, "/auth?id=test&address=multiple_check")
      |> ErgoPay.Router.call(@opts)

    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{}
  end

  test "should store multiple address list" do
    body = Jason.encode!(["addr1", "addr2"])

    conn =
      Test.conn(:post, "/auth?id=myid&address=multiple", body)
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> ErgoPay.Router.call(@opts)

    assert conn.status == 200
    assert Jason.decode!(conn.resp_body)["address"] == "addr1"
  end

  test "should return stored address" do
    # Set the session again for isolation
    ErgoPay.Session.set("myid", %{addr: "addr1"})

    conn = Test.conn(:get, "/auth?id=myid") |> ErgoPay.Router.call(@opts)
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body)["address"] == "addr1"
  end
end
