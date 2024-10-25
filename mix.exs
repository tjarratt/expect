defmodule Expect.MixProject do
  use Mix.Project

  @github_url "https://github.com/tjarratt/expect"

  def project do
    [
      app: :expect,
      version: "0.1.1",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Expect",
      description: "Write beautifully simple assertions for ExUnit using matchers",
      package: package(),
      source_url: @github_url,
      homepage_url: @github_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp package() do
    [
      files: ~w[
        .formatter.exs
        README.*
        lib
        LICENSE
        mix.exs
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => @github_url},
      maintainers: ["Tim Jarratt"]
    ]
  end
end
