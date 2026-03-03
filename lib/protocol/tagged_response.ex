defmodule IMAP.TaggedResponse do
  @moduledoc """
  This module represents tagged responses data structure.
  """
  alias IMAP.ResponseText

  #   {:ok,
  #  [
  #    response: [
  #      response_done: [
  #        response_tagged: [
  #          tag: ["a002"],
  #          resp_cond_state: ["OK", {:resp_text, ["NOOP completed"]}]
  #        ]
  #      ]
  #    ]
  #  ], "", %{}, {2, 24}, 24}

  # #<struct Net::IMAP::TaggedResponse tag="RUBY0001", name="OK",
  # data=#<struct Net::IMAP::ResponseText code=nil, text="NOOP completed">,
  # raw_data="RUBY0001 OK NOOP completed\r\n">
  defstruct [:tag, :name, :data, :raw_data]

  def from_data([response_tagged: data], raw_data),
    do: read(%__MODULE__{raw_data: raw_data}, data)

  defp read(state, tag: [tag], resp_cond_state: data),
    do: read(%{state | tag: tag}, data)

  defp read(state, [name, {:resp_text, data}]),
    do: %{state | name: name, data: ResponseText.from_data(data)}
end
