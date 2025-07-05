defmodule ErgoPay.Router.Auth do
  import Plug.Conn

  @spec handle(Plug.Conn.t()) :: Plug.Conn.t()
  def handle(conn) do
    id = conn.path_params["id"] || conn.params["id"]
    addr = conn.path_params["address"] || conn.params["address"]

    cond do
      id == nil ->
        json(conn, 400, %{address: nil, message: "Missing id", messageSeverity: "ERROR"})

      addr == "multiple_check" ->
        json(conn, 200, %{
          address: nil,
          message: "multiple addresses supported",
          messageSeverity: "INFORMATION"
        })

      addr == "multiple" and conn.method == "POST" ->
        list = extract_list(conn.body_params)

        cond do
          is_list(list) and list != [] ->
            first = hd(list)
            ErgoPay.Session.set(id, %{list: list, addr: first})

            json(conn, 200, %{
              address: first,
              message: "address list stored",
              messageSeverity: "INFORMATION"
            })

          true ->
            json(conn, 400, %{
              address: nil,
              message: "Invalid address list",
              messageSeverity: "ERROR"
            })
        end

      is_binary(addr) ->
        ErgoPay.Session.set(id, %{addr: addr})

        json(conn, 200, %{
          address: addr,
          message: "address received",
          messageSeverity: "INFORMATION"
        })

      true ->
        case ErgoPay.Session.get(id) do
          nil ->
            json(conn, 400, %{
              address: nil,
              message: "Not connected",
              messageSeverity: "ERROR"
            })

          %{addr: a} ->
            json(conn, 200, %{
              address: a,
              message: "connected",
              messageSeverity: "INFORMATION"
            })
        end
    end
  end

  # Plug wraps root-level JSON arrays in %{"_json" => list}
  defp extract_list(%{"_json" => l}) when is_list(l), do: l
  defp extract_list(l) when is_list(l), do: l
  defp extract_list(_), do: nil

  defp json(conn, status, map) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(map))
    |> halt()
  end
end
