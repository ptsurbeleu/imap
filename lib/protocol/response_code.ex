defmodule IMAP.ResponseCode do
  defstruct [:name, :data]

  def from_data({:capability_data, [name | data]}) do
    # Re-assemble capabilities back into their original form
    # TODO: Figure out if there is a way to avoid this.
    caps = Enum.map(data, fn
      {:capability, [atom: name]} -> name
      {:capability, ["AUTH=", {:auth_type, [atom: name]}]} -> "AUTH=#{name}"
    end)

    %__MODULE__{name: name, data: caps}
  end
end
