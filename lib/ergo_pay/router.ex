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

  match "/auth" do
    ErgoPay.Router.Auth.handle(conn)
  end

  match "/ergopay/auth" do
    ErgoPay.Router.Auth.handle(conn)
  end

  options _ do
    send_resp(conn, 204, "")
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
