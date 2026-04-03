defmodule IMAP.Capability do
  @moduledoc """
  Module representing capability.
  """

  def from_data(data) when is_list(data) do
    Enum.map(data, fn
      {:capability, [atom: name]} -> name
      {:capability, ["AUTH=", {:auth_type, [atom: name]}]} -> "AUTH=#{name}"
    end)
  end
end
