defmodule IMAP.SocketModule do
  @moduledoc """
  Module designed to be a drop-in replacement for :ssl module in the test environment.
  """
  require Logger
  use Agent

  def start_link do
    # Initialize session buffer with a default server greeting
    state = %{
      buffer: [read_default_greeting()],
      fd: nil
    }

    Agent.start_link(fn -> state end, name: __MODULE__)
  end

  # NOTE: This is merely a wrapper to fetch pid of the agent's process
  def connect(_host, _port, [spid: spid] = _opts, _timeout),
    do: {:ok, spid} |> tap(&Logger.info("C: connecting... #{inspect(&1)}"))

  @doc false
  def send(pid, msg) do
    # Capture command's name, to map it into file name
    file_name =
      Regex.named_captures(~r/\s(?<name>(\w+))/, msg) |> Map.get("name") |> String.downcase()

    # By default file is opened in :binary mode
    {:ok, fd} =
      File.open(__DIR__ <> "/../case/#{file_name}.md", [:read, :binary, :raw, {:read_ahead, 4096}])

    # Capture file's descriptor in the agent's state
    Agent.update(pid, &%{&1 | fd: fd})
    buffer = Agent.get(pid, & &1.buffer)

    # Set file position at the next line matching the command, and returns :ok
    with :ok <- lookup(fd, "C: #{msg}"),
         data <- read_section(fd, []) do
      # Push the next line as the server's response to the buffer
      Agent.update(pid, &%{&1 | buffer: data ++ buffer})
    else
      {:error, reason} ->
        Logger.error("Lookup failed: #{inspect(reason)}")
    end
  end

  @doc false
  def recv(pid, 0) do
    # Pop the message on top, each time the client calls recv
    state = Agent.get(pid, & &1)
    [msg | buffer] = state.buffer

    # Update agent's state
    Agent.update(pid, fn _ -> %{state | buffer: buffer} end)

    # This needs to support more use cases (eq. errors and etc.)
    {:ok, msg}
  end

  def disconnect(pid) do
    fd = Agent.get(pid, & &1.fd)
    File.close(fd)
  end

  defp read_default_greeting do
    # By default file is opened in :binary mode
    {:ok, fd} =
      File.open(__DIR__ <> "/../case/greeting.md", [:read, :binary, :raw, {:read_ahead, 4096}])

    # Skip all lines until we hit the first ; DEFAULT_SERVER_GREETING
    greeting =
      with :ok <- lookup(fd, "; DEFAULT_SERVER_GREETING\r\n") do
        read_line(fd, <<>>)
      end

    :ok = File.close(fd)

    greeting |> trim()
  end

  defp lookup(fd, string) do
    case read_line(fd, <<>>) do
      :eof ->
        :eof

      ^string ->
        :ok

      ln when is_binary(ln) ->
        lookup(fd, string)

      other ->
        other
    end
  end

  defp read_section(fd, acc) do
    # NOTE: More specific clauses always must be listed prior to the generic ones
    case read_line(fd, <<>>) do
      # Match EOF
      :eof ->
        acc

      # Match CRLF
      <<"\r\n">> ->
        acc

      # Skip ```
      <<"```", _::binary>> ->
        read_section(fd, acc)

      # Match an every line
      ln when is_binary(ln) ->
        read_section(fd, acc ++ [trim(ln)])

      # Match everything else
      other ->
        other
    end
  end

  def read_line(fd, acc) do
    case IO.binread(fd, 1) do
      :eof ->
        if acc == <<>>, do: :eof, else: acc

      <<"\n">> ->
        acc <> "\n"

      {:error, error_reason} ->
        {:error, error_reason}

      byte ->
        read_line(fd, acc <> byte)
    end
  end

  defp trim(<<"S: ", data::binary>> = _msg), do: data
  defp trim(<<"C: ", data::binary>> = _msg), do: data
end
