defmodule TestFormatter do
  @moduledoc false

  use GenServer

  def init(opts), do: {:ok, opts}

  def handle_cast({:test_finished, %ExUnit.Test{name: name, state: state}}, opts) do
    status =
      case state do
        nil -> "✓"
        {:failed, _} -> "✗"
        {:skipped, _} -> "-"
        _ -> "?"
      end

    IO.puts("  #{status} #{format_name(name)}")
    {:noreply, opts}
  end

  def handle_cast(_, opts), do: {:noreply, opts}

  defp format_name(name) do
    name
    |> to_string()
    |> String.replace_prefix("test ", "")
  end
end
