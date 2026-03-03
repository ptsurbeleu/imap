defmodule Utils do
  @moduledoc """
  Module to host various utility helpers.
  """
  def tag(cmd, label), do: %{cmd | tag: label}

  def hashtag(cmd, label) do
    # NOTE: This code is prone to collisions, hence if working tests start
    # to randomly fail - this might be the culprit, eq. wrong test case
    # is picked up due to the label hashing collision.
    label_hash =
      :crypto.hash(:md5, label)
      |> Base.encode16(case: :lower)
      |> String.slice(0, 8)

    %{cmd | tag: label_hash}
  end
end
