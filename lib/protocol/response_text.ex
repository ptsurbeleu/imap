defmodule IMAP.ResponseText do
  alias IMAP.{ResponseCode}

  defstruct [:code, :text]

  def from_data(["[", data, "]", text]),
    do: %__MODULE__{text: text, code: ResponseCode.from_data(data)}

  def from_data([text]),
    do: %__MODULE__{text: text}
end
