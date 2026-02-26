defmodule IMAP do
  alias IMAP.{Connection, ClientCommand, Parser, Response}
  require Logger

  defstruct [
    :conn,
    :capability,
    selected_mailbox: nil,
    mailboxes: [],
    logged_in: false,
    tag_number: 0,
    debug: false,
  ]

  def new(opts) do
    opts = Enum.into(opts, %{})

    host = Map.fetch!(opts, :host)
    port = Map.get(opts, :port, 993)
    debug = Map.get(opts, :debug, false)

    socket_module = Map.get(opts, :socket_module, :ssl)

    conn_opts =
      case socket_module do
        :ssl ->
          [
            :binary
            | Keyword.merge(
                [
                  active: false,
                  # TODO: Figure out whether to use CAStore or rely on Erlang's CA API
                  # NOTE: Requires {:castore, "~> 1.0"}, in mix.exs (deps)
                  # cacertfile: CAStore.file_path(),
                  server_name_indication: to_charlist(host),
                  verify: :verify_peer,
                  customize_hostname_check: [
                    {:match_fun, :public_key.pkix_verify_hostname_match_fun(:https)}
                  ],
                  cacerts: :public_key.cacerts_get(),
                ],
                Map.get(opts, :ssl, [])
              )
          ]

        other ->
          Map.get(opts, other, [])
      end

    {:ok, conn} = Connection.connect(socket_module, to_charlist(host), port, conn_opts)
    session = {socket_module, conn}

    Agent.start_link(fn ->
      %__MODULE__{conn: session, debug: debug}
    end)
  end

  def start_imap_connection(pid) do
    session = Agent.get(pid, & &1)
    get_server_greeting(session)
  end

  defp get_server_greeting(session) do
    with raw_data = read_response(session),
         {:ok, [greeting: _] = greeting, "", _, _, _} <- Parser.greeting(raw_data) do
      Response.from_data(greeting, raw_data)
    end
  end

  def send_command(pid, %ClientCommand{} = command) do
    session = Agent.get(pid, & &1)

    tag = DateTime.utc_now() |> Calendar.strftime("%Y%d%m.%H%M%S")

    Connection.send(session.conn, ClientCommand.serialize(%{command | tag: tag}))

    read_response(session)
  end

  defp read_response(%{conn: conn} = session) do
    imap_receive_raw(conn)
    |> tap(& if session.debug, do: "S: #{&1}" |> String.trim_trailing() |> IO.puts())
  end

  def imap_receive_raw(conn) do
    {:ok, message} = Connection.recv(conn)
    message
  end
end
