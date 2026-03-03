defmodule ClientCommandTest do
  alias IMAP.ClientCommand
  import Utils
  use ExUnit.Case

  test "NOOP" do
    assert "b001 NOOP\r\n" == ClientCommand.noop() |> tag("b001") |> ClientCommand.serialize()
  end

  test "CAPABILITY" do
    assert "b002 CAPABILITY\r\n" ==
             ClientCommand.capability() |> tag("b002") |> ClientCommand.serialize()
  end

  test "LOGOUT" do
    assert "b003 LOGOUT\r\n" == ClientCommand.logout() |> tag("b003") |> ClientCommand.serialize()
  end
end
