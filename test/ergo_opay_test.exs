defmodule ErgoPayTest do
  use ExUnit.Case
  alias Plug.Test
  @opts ErgoPay.Router.init([])

  @sample_addr "9fZukdzFpR3ayX28kNvztNFVQVw1Gc7YhcUM3FZ3VAbmbRzd"

  test "should return ok on /" do
    conn = Test.conn(:get, "/") |> ErgoPay.Router.call(@opts)
    assert conn.status == 200
    assert conn.resp_body == "ok"
  end

  test "should reject missing id" do
    conn = Test.conn(:get, "/auth") |> ErgoPay.Router.call(@opts)
    assert conn.status == 400
    body = Jason.decode!(conn.resp_body)
    assert body["message"] == "Missing id"
    assert body["messageSeverity"] == "ERROR"
  end

  test "should accept multiple_check" do
    conn =
      Test.conn(:post, "/auth?id=test&address=multiple_check")
      |> ErgoPay.Router.call(@opts)

    assert conn.status == 200
    body = Jason.decode!(conn.resp_body)
    assert body["message"] == "multiple addresses supported"
    assert body["messageSeverity"] == "INFORMATION"
    assert body["address"] == nil
  end

  test "should store multiple address list" do
    body = Jason.encode!(["addr1", "addr2"])

    conn =
      Test.conn(:post, "/auth?id=myid&address=multiple", body)
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> ErgoPay.Router.call(@opts)

    assert conn.status == 200
    body = Jason.decode!(conn.resp_body)
    assert body["address"] == "addr1"
    assert body["messageSeverity"] == "INFORMATION"
  end

  test "should accept single P2PK address" do
    conn =
      Test.conn(:get, "/auth?id=session1&address=#{@sample_addr}")
      |> ErgoPay.Router.call(@opts)

    assert conn.status == 200
    body = Jason.decode!(conn.resp_body)
    assert body["address"] == @sample_addr
    assert body["message"] == "address received"
  end

  test "should return stored address" do
    ErgoPay.Session.set("myid", %{addr: "addr1"})

    conn = Test.conn(:get, "/auth?id=myid") |> ErgoPay.Router.call(@opts)
    assert conn.status == 200
    body = Jason.decode!(conn.resp_body)
    assert body["address"] == "addr1"
    assert body["message"] == "connected"
  end
end
