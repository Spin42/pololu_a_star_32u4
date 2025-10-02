defmodule PololuAStar32u4.MixProject do
  use Mix.Project

  def project do
    [
      app: :pololu_a_star_32u4,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      source_url: "https://github.com/Spin42/pololu_a_star_32u4"
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {PololuAStar32u4.Application, []}
    ]
  end

  defp deps do
    [
      {:circuits_i2c, "~> 2.0"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Elixir library for controlling the Pololu A-Star 32U4 board via I2C in RPi slave mode. " <>
      "Provides control for LEDs, motors, sensors, buttons, and audio."
  end

  defp package do
    [
      name: "pololu_a_star_32u4",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Spin42/pololu_a_star_32u4",
        "Docs" => "https://hexdocs.pm/pololu_a_star_32u4"
      },
      maintainers: ["CHANGE-THIS-NAME"]
    ]
  end

  defp docs do
    [
      main: "PololuAStar32u4",
      extras: ["README.md"],
      source_url: "https://github.com/Spin42/pololu_a_star_32u4"
    ]
  end
end
