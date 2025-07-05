defmodule ErgoPay.Application do
  use Application

  def start(_type, _args) do
    children = [
      ErgoPay.Session,
      {Plug.Cowboy,
       scheme: :http, plug: ErgoPay.Router, options: [port: Application.get_env(:ergo_pay, :port)]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ErgoPay.Supervisor)
  end
end
