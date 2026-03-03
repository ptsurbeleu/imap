defmodule Imap.MixProject do
  use Mix.Project

  @version "0.1.0"

  @source_url "https://github.com/ptsurbeleu/imap"

  def project do
    [
      app: :imap,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "A library to interact with an IMAP server",
      name: "imap",
      elixirc_paths: elixirc_paths(Mix.env()),
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs(),
      dialyzer: []
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ssl]
    ]
  end

  defp package do
    [
      name: "imap",
      files: ["lib", "priv", "test", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Pavel Tsurbeleu <tussles.85titans@icloud.com>"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # NOTE: Useful to test integration with the target package
      # {:abnf_parsec, path: "../abnf_parsec", runtime: false},
      {:abnf_parsec, "~> 2.1", runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.2", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [main: "readme", extras: ["README.md"]]
  end
end
