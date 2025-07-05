defmodule ErgoPay.Router.Auth do
  import Plug.Conn

  def handle(conn) do
    id = conn.params["id"]
    addr = conn.params["address"]

    if id == nil do
      json(conn, 400, %{message: "Missing id", messageSeverity: "ERROR"})
    else
      route(conn, id, addr)
    end
  end

  defp route(conn, id, "multiple_check") do
    json(conn, 200, %{})
  end

  defp route(%Plug.Conn{method: "POST", body_params: %{"_json" => list}} = conn, id, "multiple") do
    cond do
      is_list(list) and list != [] ->
        first = hd(list)
        ErgoPay.Session.set(id, %{list: list, addr: first})
        json(conn, 200, %{address: first})

      true ->
        json(conn, 400, %{message: "Invalid address list", messageSeverity: "ERROR"})
    end
  end

  defp route(conn, id, addr) when is_binary(addr) do
    ErgoPay.Session.set(id, %{addr: addr})
    json(conn, 200, %{address: addr})
  end

  defp route(conn, id, nil) do
    case ErgoPay.Session.get(id) do
      nil -> json(conn, 400, %{message: "Not connected", messageSeverity: "ERROR"})
      %{addr: addr} -> json(conn, 200, %{address: addr})
    end
  end

  defp json(conn, status, map) do
    body = map |> Enum.reject(fn {_, v} -> v == nil end) |> Enum.into(%{}) |> Jason.encode!()
    conn |> put_resp_content_type("application/json") |> send_resp(status, body) |> halt()
  end
end
