defmodule Expect.MixProject do
  use Mix.Project

  @github_url "https://github.com/tjarratt/expect"

  def project do
    [
      app: :expect,
      version: "3.0.0-rc",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      name: "Expect",
      description: "Write beautifully simple assertions for ExUnit using matchers",
      package: package(),
      source_url: @github_url,
      homepage_url: @github_url,
      test_paths: test_paths(System.get_env("INCLUDE_TESTS_WITH_WARNINGS"))
    ]
  end

  defp test_paths(nil), do: ["test"]
  defp test_paths(_), do: ["test", "test_with_warnings"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
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
      links: %{"GitHub" => @github_url},
      maintainers: ["Tim Jarratt"]
    ]
  end

  defp docs() do
    [
      main: "readme",
      extras: ["CHANGELOG.md", {:"README.md", [title: "Overview"]}],
      source_url: @github_url
    ]
  end
end
