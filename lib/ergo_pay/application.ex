defmodule ErgoPay.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      ErgoPay.Session,
      {Plug.Cowboy, scheme: scheme(), plug: ErgoPay.Router, options: server_options()}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ErgoPay.Supervisor)
  end

  defp scheme do
    if Mix.env() == :prod, do: :https, else: :http
  end

  defp server_options do
    port = String.to_integer(System.get_env("PORT", "8443"))
    base_opts = [port: port]

    if Mix.env() == :prod do
      keyfile = System.get_env("SSL_KEY", "/etc/letsencrypt/live/crystalpool.cc/privkey.pem")
      certfile = System.get_env("SSL_CERT", "/etc/letsencrypt/live/crystalpool.cc/fullchain.pem")
      Keyword.merge(base_opts, keyfile: keyfile, certfile: certfile)
    else
      base_opts
    end
  end
end
