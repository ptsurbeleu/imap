defmodule ClientCommandTest do
  alias IMAP.ClientCommand
  use ExUnit.Case

  test "NOOP" do
    assert "TAG NOOP\r\n" == (ClientCommand.noop() |> ClientCommand.serialize())
  end

  test "CAPABILITY" do
    assert "TAG CAPABILITY\r\n" == (ClientCommand.capability() |> ClientCommand.serialize())
  end

  test "LOGOUT" do
    assert "TAG LOGOUT\r\n" == (ClientCommand.logout() |> ClientCommand.serialize())
  end
end
