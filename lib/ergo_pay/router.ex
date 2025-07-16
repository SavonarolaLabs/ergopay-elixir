defmodule ErgoPay.Router do
  use Plug.Router

  plug(ErgoPay.CORS)
  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "ok")
  end

  get "/pay" do
    ErgoPay.Router.Pay.pay(conn)
  end

  # No session id provided – will trigger "Missing id" error in handler
  match "/auth" do
    ErgoPay.Router.Auth.handle(conn)
  end

  # Session id only – poll current state
  match "/auth/:id" do
    ErgoPay.Router.Auth.handle(conn)
  end

  # Session id plus address / keyword (single address, multiple, multiple_check)
  match "/auth/:id/:address" do
    ErgoPay.Router.Auth.handle(conn)
  end

  options _ do
    send_resp(conn, 204, "")
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
