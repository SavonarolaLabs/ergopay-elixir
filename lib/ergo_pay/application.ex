def start(_, _) do
  children = [
    ErgoPay.Session,
    {Plug.Cowboy, scheme: scheme(), plug: ErgoPay.Router, options: server_options()}
  ]

  Supervisor.start_link(children, strategy: :one_for_one, name: ErgoPay.Supervisor)
end

defp scheme, do: if(Mix.env() == :prod, do: :https, else: :http)

defp server_options do
  port = String.to_integer(System.get_env("PORT", "8443"))
  base = [port: port]

  if Mix.env() == :prod do
    key = System.get_env("SSL_KEY", "/etc/letsencrypt/live/crystalpool.cc/privkey.pem")
    cert = System.get_env("SSL_CERT", "/etc/letsencrypt/live/crystalpool.cc/fullchain.pem")
    Keyword.merge(base, keyfile: key, certfile: cert)
  else
    base
  end
end
