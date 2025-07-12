defmodule ErgoPay.Router.Auth do
  import Plug.Conn

  @spec handle(Plug.Conn.t()) :: Plug.Conn.t()
  def handle(conn) do
    id = conn.path_params["id"] || conn.params["id"]
    addr = conn.path_params["address"] || conn.params["address"]

    # Log incoming address info
    IO.puts("[AUTH REQUEST] id=#{inspect(id)} address=#{inspect(addr)} method=#{conn.method}")

    cond do
      id == nil ->
        log_response(nil, "Missing id", "ERROR")
        json(conn, 400, %{address: nil, message: "Missing id", messageSeverity: "ERROR"})

      addr == "multiple_check" ->
        log_response(nil, "multiple addresses supported", "INFORMATION")
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
            log_response(first, "address list stored", "INFORMATION")

            json(conn, 200, %{
              address: first,
              message: "address list stored",
              messageSeverity: "INFORMATION"
            })

          true ->
            log_response(nil, "Invalid address list", "ERROR")
            json(conn, 400, %{
              address: nil,
              message: "Invalid address list",
              messageSeverity: "ERROR"
            })
        end

      is_binary(addr) ->
        ErgoPay.Session.set(id, %{addr: addr})
        log_response(addr, "address received", "INFORMATION")

        json(conn, 200, %{
          address: addr,
          message: "address received",
          messageSeverity: "INFORMATION"
        })

      true ->
        case ErgoPay.Session.get(id) do
          nil ->
            log_response(nil, "Not connected", "ERROR")
            json(conn, 400, %{
              address: nil,
              message: "Not connected",
              messageSeverity: "ERROR"
            })

          %{addr: a} ->
            log_response(a, "connected", "INFORMATION")
            json(conn, 200, %{
              address: a,
              message: "connected",
              messageSeverity: "INFORMATION"
            })
        end
    end
  end

  defp extract_list(%{"_json" => l}) when is_list(l), do: l
  defp extract_list(l) when is_list(l), do: l
  defp extract_list(_), do: nil

  defp json(conn, status, map) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(map))
    |> halt()
  end

  defp log_response(addr, message, severity) do
    IO.puts("[AUTH RESPONSE] address=#{inspect(addr)} message=#{message} severity=#{severity}")
  end
end
