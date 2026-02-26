defmodule IMAP.ResponseCode do
  @moduledoc """
  `t:IMAP.ResponseCode` represents an IMAP response code, which can be retrieved from the `:code` field in `t:IMAP.ResponseText`.
  """
  defstruct [:name, :data]

  def from_data({:capability_data, [name | data]}) do
    # Re-assemble capabilities back into their original form
    caps =
      Enum.map(data, fn
        {:capability, [atom: name]} -> name
        {:capability, ["AUTH=", {:auth_type, [atom: name]}]} -> "AUTH=#{name}"
      end)

    %__MODULE__{name: name, data: caps}
  end
end
