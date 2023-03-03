defmodule EctoMultiRepo.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/guenni68/ecto_multi_repo.git"

  def project do
    [
      app: :ecto_multi_repo,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      source_url: @source_url,
      homepage_url: @source_url,
      docs: [
        # The main page in the docs
        main: "EctoMultiRepo",
        api_reference: false,
        extras: ["CHANGELOG.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {EctoMultiRepo.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.9"},
      {:uuid, "~> 1.1"},
      {:gen_state_machine, "~> 3.0"},
      {:postgrex, "~> 0.16.5"},
      {:myxql, "~> 0.6.3"},
      {:tds, "~> 2.3"},
      {:ex_doc, "~> 0.29.1", only: :dev, runtime: false}
    ]
  end

  defp description() do
    """
    EctoMultiRepo is a "batteries included" library that allows you to
    create ecto repos dynamically at runtime.
    """
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
