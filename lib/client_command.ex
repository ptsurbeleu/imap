defmodule IMAP.ClientCommand do
  defstruct tag: "TAG", command: nil, params: []

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
