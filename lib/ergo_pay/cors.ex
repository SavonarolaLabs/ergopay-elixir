defmodule ErgoPay.CORS do
  import Plug.Conn
  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_header("access-control-allow-methods", "GET, POST, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "*")
    |> put_resp_header("access-control-max-age", "86400")
  end
end
