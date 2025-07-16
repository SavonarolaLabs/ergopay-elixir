defmodule ErgoPay.Router.Pay do
  import Plug.Conn

  @project_dir Path.expand("../../../../ergfi", __DIR__)
  @script_path "src/lib/ergopay/ergopaySwap.cli.ts"

  def pay(conn, params) do
    swap_pair = params["swapPair"]
    amount = String.to_integer(params["amount"] || "0")
    e_pay_link_id = params["ePayLinkId"]
    last_input = params["lastInput"]
    payer_address = params["payerAddress"]
    fee_mining = String.to_integer(params["feeMining"] || "0")

    data = %{
      "swapPair" => swap_pair,
      "amount" => amount,
      "ePayLinkId" => e_pay_link_id,
      "lastInput" => last_input,
      "payerAddress" => payer_address,
      "feeMining" => fee_mining
    }

    json_string = Jason.encode!(data)
    command = "cd #{@project_dir} && bun run #{@script_path} '#{json_string}'"

    case System.cmd("sh", ["-c", command], stderr_to_stdout: true) do
      {stdout, 0} ->
        case Jason.decode(stdout) do
          {:ok, result} ->
            send_json(conn, 200, result)

          {:error, reason} ->
            send_error(conn, 500, "Invalid response from script", inspect(reason))
        end

      {stderr, _} ->
        send_error(conn, 500, stderr)
    end
  end

  defp send_json(conn, status, map) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(map))
    |> halt()
  end

  defp send_error(conn, status, message, details \\ nil) do
    error_map = %{"error" => message}
    error_map = if details, do: Map.put(error_map, "details", details), else: error_map

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(error_map))
    |> halt()
  end
end
