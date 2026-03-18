defmodule CapabilityTest do
  alias IMAP.{ClientCommand, UntaggedResponse}
  import Map, only: [take: 2]
  import Utils

  use ExUnit.Case
  @moduletag :CAPABILITY

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

  test "CAPABILITY command", %{imap: pid} do
    response =
      IMAP.send_command(pid, ClientCommand.capability() |> tag("a0001"))

    assert %{tag: "a0001", name: "OK"} = response
    assert %{data: %{text: "CAPABILITY completed"}} = response
  end

  test "CAPABILITY command nested", %{imap: pid} do
    response =
      IMAP.send_command(pid, ClientCommand.capability() |> tag("a00003"))

    assert %{tag: "a00003", name: "OK"} = response
    assert %{data: %{text: "CAPABILITY completed"}} = response
  end

  test "CAPABILITY command to iCloud", %{imap: pid} do
    response =
      IMAP.send_command(pid, ClientCommand.capability() |> tag("c00003"))

    assert %{tag: "c00003", name: "OK"} = response
    assert %{data: %{text: "Completed"}} = response
  end

  test "CAPABILITY command to Gmail", %{imap: pid} do
    response =
      IMAP.send_command(pid, ClientCommand.capability() |> tag("a005"))

    assert %{tag: "a005", name: "OK"} = response

    assert %{
             data: %{
               text: "Thats all sheff wrote! d2e1a72fcca58-82a1004806amb45731469b3a"
             }
           } = response
  end
end
