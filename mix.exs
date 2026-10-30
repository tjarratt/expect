defmodule Expect.MixProject do
  use Mix.Project

  @git_url "https://pushin.eu/tjarratt/expect"

  def project() do
    [
      app: :expect,
      version: "3.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      name: "Expect",
      description: "Write beautifully simple assertions for ExUnit using matchers",
      package: package(),
      source_url: @git_url,
      homepage_url: @git_url
    ]
  end

  def application() do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps() do
    [
      {:credo, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:doctor, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_check, ">= 0.0.0", only: :dev, runtime: false},
      {:sobelow, ">= 0.0.0", only: :dev, runtime: false},
      {:mix_audit, ">= 0.0.0", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp package() do
    [
      files: ~w[
        README.*
        lib
        LICENSE
        mix.exs
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => @git_url},
      maintainers: ["Tim Jarratt"]
    ]
  end

  defp docs() do
    [
      main: "readme",
      extras: ["CHANGELOG.md", {:"README.md", [title: "Overview"]}],
      source_url: @git_url
    ]
  end
end
