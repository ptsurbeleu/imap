defmodule IMAP.Response do
  @moduledoc """
  Represents IMAP response struct to handle further post-processing and transformation
  after parsing of the raw response was done.
  """
  alias IMAP.{TaggedResponse, UntaggedResponse}

  @doc """
    Reads an IMAP greeting from parser's output
  """
  def from_data([greeting: data], raw_data),
    do: UntaggedResponse.from_data(data, raw_data)

  def from_data([response: [response_done: [response_tagged: _] = data]], raw_data),
    do: TaggedResponse.from_data(data, raw_data)

  def from_data([response_data: data], raw_data),
    do: UntaggedResponse.from_data(data, raw_data)
end
