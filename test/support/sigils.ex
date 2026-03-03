defmodule Sigils do
  @moduledoc false

  @doc """
  Handles the sigil `~a` to convert a strong to an atom.

  It returns an atom of the given string.
  """
  def sigil_a(string, []), do: String.to_atom(string)
end
