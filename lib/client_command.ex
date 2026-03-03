defmodule IMAP.ClientCommand do
  @moduledoc """
  Represents an IMAP command struct. This struct captures all client commands
  supported by [RFC3501 - IMAP4rev1](https://www.rfc-editor.org/rfc/rfc3501).
  """

  @typedoc """
  - `:tag`     - A unique identifier for the command, used to correlate server
                 responses back to the originating command (e.g. `"A001"`).
  - `:command` - The IMAP command verb (e.g. `LOGIN`, `SELECT`, `FETCH`, `LOGOUT` and etc.).
  - `:params`  - An ordered list of arguments to the command (e.g. mailbox name,
                 message sequence sets, fetch attributes and etc.).
                 No parameters indicated by an empty array `[]`.
  """
  @type t :: %__MODULE__{
          tag: String.t(),
          command: atom() | String.t() | nil,
          params: list()
        }

  defstruct tag: nil, command: nil, params: []

  @ops [
    noop: [],
    capability: [],
    login: [:username, :password],
    logout: []
  ]

  for {op, params} <- @ops do
    command = op |> to_string |> String.upcase()

    parameters =
      Enum.map(params, fn
        arg when is_atom(arg) -> Macro.var(arg, Elixir)
        {arg, default} -> quote(do: unquote(Macro.var(arg, Elixir)) \\ unquote(default))
      end)

    arguments =
      Enum.map(params, fn
        arg when is_atom(arg) -> Macro.var(arg, Elixir)
        {arg, _default} -> Macro.var(arg, Elixir)
      end)

    def unquote(op)(unquote_splicing(parameters)) do
      %__MODULE__{command: unquote(command), params: [unquote_splicing(arguments)]}
    end
  end

  def serialize(%__MODULE__{tag: tag, command: command, params: params}) do
    params =
      params
      |> List.flatten()
      |> case do
        [] -> nil
        _ -> Enum.join(params, " ")
      end

    [tag, command, params]
    |> Enum.filter(& &1)
    |> Enum.join(" ")
    |> Kernel.<>("\r\n")
  end
end
