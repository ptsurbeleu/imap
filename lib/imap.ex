defmodule IMAP do
  alias IMAP.{ClientCommand, Connection, Parser, Response, TaggedResponse, UntaggedResponse}
  require Logger

  @moduledoc """
  Frontend (aka. primary interface) for interacting with an IMAP server.

  Manages the full lifecycle of an IMAP session — from starting a connection
  (aka. server greeting) and authenticating, to selecting mailboxes and issuing
  arbitrary commands.

  @typedoc \"\"\"
  - `:conn`             - A tuple with {socket_module, connection}.
  - `:capability`       - Server capabilities reported after connecting (aka. server greeting) or executing CAPABILITY command.
  - `:selected_mailbox` - The currently selected mailbox, or `nil` if none is selected.
  - `:mailboxes`        - List of mailboxes retrieved from the server.
  - `:logged_in`        - Whether the session is currently authenticated. Defaults to `false`.
  - `:tag_number`       - Internal counter used to generate unique command tags
                          (e.g. `1` → `"A001"`). Defaults to `0`.
  - `:debug`            - When `true`, enables verbose logging of raw client/server
                          exchanges via `Logger`. Defaults to `false`.
  """

  @type t :: %__MODULE__{
          # NOTE: Need to learn more about typespecs
          conn: any() | nil,
          capability: list() | nil,
          selected_mailbox: String.t() | nil,
          mailboxes: list(),
          logged_in: boolean(),
          tag_number: non_neg_integer(),
          debug: boolean()
        }

  defstruct [
    :conn,
    :capability,
    selected_mailbox: nil,
    mailboxes: [],
    logged_in: false,
    tag_number: 0,
    debug: false,
    responses: %{},
    tagged_responses: %{}
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
                  # NOTE: Requires {:castore, "~> 1.0"}, in mix.exs (deps)
                  # cacertfile: CAStore.file_path(),
                  server_name_indication: to_charlist(host),
                  verify: :verify_peer,
                  customize_hostname_check: [
                    {:match_fun, :public_key.pkix_verify_hostname_match_fun(:https)}
                  ],
                  cacerts: :public_key.cacerts_get()
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
    with raw_data <- read_response(session),
         {:ok, [greeting: _] = greeting, "", _, _, _} <- Parser.greeting(raw_data) do
      Response.from_data(greeting, raw_data)
    end
  end

  def send_command(pid, %ClientCommand{} = command) do
    session = Agent.get(pid, & &1)

    # NOTE: Preserve an existing tag, in case the command already specifies it (important for the test framework).
    tag = Map.get(command, :tag) || DateTime.utc_now() |> Calendar.strftime("%Y%d%m.%H%M%S")

    raw_data =
      ClientCommand.serialize(%{command | tag: tag})
      |> tap(&("C: #{&1}" |> String.trim_trailing() |> Logger.debug()))

    Connection.send(session.conn, raw_data)

    read_server_response(session)
  end

  defp read_server_response(session) do
    # >>> RFC5301 - 2.2.2.  Server Protocol Sender and Client Protocol Receiver <<<
    # >>> https://www.rfc-editor.org/rfc/rfc3501.html#section-2.2.2             <<<
    #
    # The protocol receiver of an IMAP4rev1 client reads a response line
    # from the server. It then takes action on the response based upon the
    # first token of the response, which can be a tag, a "*", or a "+".
    {:ok, response, "", _, _, _} =
      case raw_data = read_response(session) do
        # Untagged response
        <<"* ", _::binary>> ->
          Parser.response_data(raw_data)

        # Continuation response
        <<"+ ", _::binary>> ->
          Parser.continue_req(raw_data)

        # Tagged response
        _ ->
          Parser.response(raw_data)
      end

    # Translate parser's output into developer-friendly structs
    case Response.from_data(response, raw_data) do
      %UntaggedResponse{} ->
        # NOTE: Discard untagged responses for now (if any)
        read_server_response(session)

      %TaggedResponse{} = tagged ->
        tagged
    end
  end

  def hangup(%{conn: conn}),
    do: :ok = Connection.close(conn)

  defp read_response(%{conn: conn} = _session) do
    imap_receive_raw(conn)
    |> tap(&("S: #{&1}" |> String.trim_trailing() |> Logger.debug()))
  end

  def imap_receive_raw(conn) do
    {:ok, message} = Connection.recv(conn)
    message
  end
end
