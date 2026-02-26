defmodule IMAP.Response do
  alias IMAP.{UntaggedResponse}

  @doc """
    Reads an IMAP greeting from parser's output
  """
  def from_data([greeting: data], raw_data),
    do: UntaggedResponse.from_data(data, raw_data)
end
