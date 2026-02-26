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
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs()
    ]
  end

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
      # {:castore, "~> 1.0"},
      # {:abnf_parsec, path: "../abnf_parsec", runtime: false},
      {:abnf_parsec, "~> 2.1", runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs], runtime: false}
    ]
  end

  defp docs do
    [main: "readme", extras: ["README.md"]]
  end
end
