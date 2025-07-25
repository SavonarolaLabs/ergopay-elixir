defmodule ErgoPay.MixProject do
  use Mix.Project
  def project do
    [
      app: :ergo_pay,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end
  def application do
    [
      extra_applications: [:logger],
      mod: {ErgoPay.Application, []}
    ]
  end
  defp deps do
    [
      {:plug_cowboy, "~> 2.7"},
      {:jason, "~> 1.4"}
    ]
  end
end
