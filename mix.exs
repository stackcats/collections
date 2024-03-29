defmodule Collections.MixProject do
  use Mix.Project

  def project do
    [
      app: :collections,
      version: "0.2.1",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/stackcats/collections",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:credo, "~> 1.6.1", only: [:dev, :test], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description do
    """
    A library provides efficient implementations of the most common general purpose programming data structures.
    """
  end

  defp package() do
    [
      name: :collections,
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["stackcats"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/stackcats/collections"}
    ]
  end
end
