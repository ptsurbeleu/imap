defmodule ImapTest do
  use ExUnit.Case
  doctest Imap

  test "greets the world" do
    assert Imap.hello() == :world
  end
end
