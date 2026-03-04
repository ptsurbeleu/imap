defmodule IMAP.Connection do
  @moduledoc """
  Manages the underlying TCP/SSL connection to an IMAP server.

  Handles establishing, maintaining, and closing the socket connection.
  Used internally by `IMAP` to send raw command data and receive server
  responses.
  """

  @type reason :: term()
  @type transport :: :ssl | :gen_tcp
  @type session :: {socket_module :: transport(), conn: pid()}

  @callback connect(
              transport :: transport(),
              host :: charlist(),
              port :: non_neg_integer(),
              opts :: [keyword()]
            ) ::
              {:ok, pid()} | {:error, term()}

  @callback send(session(), msg :: iodata()) ::
              {:ok | {:error, reason()}}

  @callback recv(session()) ::
              {:ok, binary() | list()} | {:error, reason()}

  @doc false
  def connect(socket_module, host, port, opts) do
    socket_module.connect(host, port, opts, 5000)
  end

  @doc false
  def send({socket_module, conn}, msg) do
    socket_module.send(conn, msg)
  end

  @doc false
  def recv({socket_module, conn}) do
    socket_module.recv(conn, 0)
  end

  def close({socket_module, conn}),
    do: socket_module.close(conn)
end
