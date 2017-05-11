defmodule KVstore.StorageTest do
  use ExUnit.Case

  test "store value by key with ttl" do
    assert KVstore.Storage.get("key") == :error

    assert KVstore.Storage.set("key", "value", 2_000) == :ok

    :timer.sleep(1_000)
    assert KVstore.Storage.get("key") == "value"

    :timer.sleep(2_000)
    assert KVstore.Storage.get("key") == :error
  end
end
