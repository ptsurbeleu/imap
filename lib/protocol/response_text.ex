defmodule IMAP.ResponseText do
  @moduledoc """
  ResponseText represents texts of responses.

  The text may be prefixed by a ResponseCode.

  ResponseText is returned from TaggedResponse#data or
  UntaggedResponse#data for
  ["status responses"](https://www.rfc-editor.org/rfc/rfc3501#section-7.1):
  * every TaggedResponse, name is always
    "+OK+", "+NO+", or "+BAD+".
  * any UntaggedResponse when name is
    "+OK+", "+NO+", "+BAD+", "+PREAUTH+", or "+BYE+".
  """
  alias IMAP.ResponseCode

  defstruct [:code, :text]

  def from_data(["[", data, "]", text]),
    do: %__MODULE__{text: text, code: ResponseCode.from_data(data)}

  def from_data([text]),
    do: %__MODULE__{text: text}
end
