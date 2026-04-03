defmodule IMAP.UntaggedResponse do
  alias IMAP.{Capability, ResponseText}

  @moduledoc """
    Untagged IMAP response.
  """
  defstruct [:name, :data, :raw_data]

  @doc """
  Reads an untagged response from parser's data.

  ## Examples
      iex> UntaggedResponse.from_data([
      ...> "*",
      ...> {:resp_cond_auth,
      ...>  [
      ...>    "OK",
      ...>    {:resp_text,
      ...>     [
      ...>       "[",
      ...>       {:capability_data,
      ...>        [
      ...>          "CAPABILITY",
      ...>          {:capability, [atom: "XAPPLEPUSHSERVICE"]},
      ...>          {:capability, [atom: "IMAP4"]},
      ...>          {:capability, [atom: "IMAP4rev1"]},
      ...>          {:capability, [atom: "SASL-IR"]},
      ...>          {:capability, ["AUTH=", {:auth_type, [atom: "ATOKEN"]}]},
      ...>          {:capability, ["AUTH=", {:auth_type, [atom: "PLAIN"]}]},
      ...>          {:capability, ["AUTH=", {:auth_type, [atom: "ATOKEN2"]}]},
      ...>          {:capability, ["AUTH=", {:auth_type, [atom: "XOAUTH2"]}]}
      ...>        ]},
      ...>       "]",
      ...>       "(2538B104-b1489b0b0463) p00-iscream-7dfc5877dc-kmwkw"
      ...>     ]}
      ...>  ]}
      ...> ], "* OK [CAPABILITY XAPPLEPUSHSERVICE IMAP4 IMAP4rev1 SASL-IR AUTH=ATOKEN AUTH=PLAIN AUTH=ATOKEN2 AUTH=XOAUTH2] (2538B104-b1489b0b0463) p00-iscream-7dfc5877dc-kmwkw\\r\\n")
      %UntaggedResponse{
        name: "OK",
        data: %ResponseText{
          code: %ResponseCode{
            name: "CAPABILITY",
            data: ["XAPPLEPUSHSERVICE", "IMAP4", "IMAP4rev1", "SASL-IR", "AUTH=ATOKEN", "AUTH=PLAIN",
             "AUTH=ATOKEN2", "AUTH=XOAUTH2"]
          },
          text: "(2538B104-b1489b0b0463) p00-iscream-7dfc5877dc-kmwkw"
        },
        raw_data: "* OK [CAPABILITY XAPPLEPUSHSERVICE IMAP4 IMAP4rev1 SASL-IR AUTH=ATOKEN AUTH=PLAIN AUTH=ATOKEN2 AUTH=XOAUTH2] (2538B104-b1489b0b0463) p00-iscream-7dfc5877dc-kmwkw\\r\\n"
      }

      iex> UntaggedResponse.from_data([
      ...> "*",
      ...>   {:resp_cond_auth,
      ...>    [
      ...>      "OK",
      ...>      {:resp_text,
      ...>       ["Gimap ready for requests from 174.165.192.148 d2e1a72fcca58-825228b72b3mb279401911b3a"]}
      ...>    ]}
      ...>  ], "* OK Gimap ready for requests from 174.165.192.148 d2e1a72fcca58-825228b72b3mb279401911b3a\\r\\n")
      %UntaggedResponse{
        name: "OK",
        data: %ResponseText{
          code: nil,
          text: "Gimap ready for requests from 174.165.192.148 d2e1a72fcca58-825228b72b3mb279401911b3a"
        },
        raw_data: "* OK Gimap ready for requests from 174.165.192.148 d2e1a72fcca58-825228b72b3mb279401911b3a\\r\\n"
      }
  """
  def from_data(["*", data], raw_data),
    do: read(%__MODULE__{raw_data: raw_data}, data)

  defp read(state, {:capability_data, [name | data]}),
    do: %{state | name: name, data: Capability.from_data(data)}

  defp read(state, {:resp_cond_auth, [name, data]}),
    do: read(%{state | name: name}, data)

  defp read(state, {:message_data, [{:nz_number, number}, name, msg_att]}),
    do: read(%{state | data: number, name: name}, msg_att)

  defp read(state, {:mailbox_data, [data, name]}),
    do: read(%{state | name: name}, data)

  defp read(state, {:msg_att, _}),
    do: state

  defp read(state, {:resp_text, data}),
    do: %{state | data: ResponseText.from_data(data)}

  defp read(state, {:message_data, [{:nz_number, number}, name]}),
    do: %{state | data: number, name: name}

  defp read(state, {:nz_number, number}),
    do: %{state | data: number}

  defp read(state, {:number, number}),
    do: %{state | data: number}
end
