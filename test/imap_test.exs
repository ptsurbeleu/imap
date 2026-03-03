defmodule IMAPTest do
  alias IMAP.{ClientCommand, UntaggedResponse}
  import Utils

  use ExUnit.Case

  # Singleton module setup, each test case uses same instance
  setup do
    # Launch an agent's instance
    {:ok, spid} = IMAP.SocketModule.start_link()
    # Seed IMAP Client Library with pid of the agent's instance via options
    {:ok, pid} =
      IMAP.new(%{
        IMAP.SocketModule => [spid: spid],
        host: "xyz.io",
        socket_module: IMAP.SocketModule
      })

    # Start IMAP connection
    %UntaggedResponse{name: "OK"} = IMAP.start_imap_connection(pid)
    # Seed test context with both pids
    [imap: pid, spid: spid]
  end

  test "NOOP command (w/ no status updates)", %{imap: pid} do
    response =
      IMAP.send_command(pid, ClientCommand.noop() |> tag("a002"))

    assert match?(%{tag: "a002"}, response), "Expected tag to match"
    assert match?(%{name: "OK"}, response), "Expected name to match"
    assert match?(%{data: %{text: "NOOP completed"}}, response), "Expected text to match"
  end

  test "NOOP command (w/ status updates)", %{imap: pid} do
    response =
      IMAP.send_command(pid, ClientCommand.noop() |> tag("a047"))

    assert match?(%{tag: "a047"}, response), "Expected tag to match"
    assert match?(%{name: "OK"}, response), "Expected name to match"
    assert match?(%{data: %{text: "NOOP completed"}}, response), "Expected text to match"
  end
end
