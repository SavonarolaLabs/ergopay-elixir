defmodule ErgoPay.Router.Store do
  import Plug.Conn

  @spec handle(Plug.Conn.t()) :: Plug.Conn.t()
  def handle(%Plug.Conn{method: "POST"} = conn) do
    body = conn.body_params

    if byte_size(Jason.encode!(body)) > 20_000 do
      json(conn, 400, %{message: "Object too large"})
    else
      id = ErgoPay.Store.put(body)
      json(conn, 200, %{id: id})
    end
  end

  def handle(conn) do
    json(conn, 405, %{message: "Method not allowed"})
  end

  defp json(conn, status, map) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(map))
    |> halt()
  end
end
