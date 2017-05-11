defmodule KVstore.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias KVstore.Router

  @opts Router.init([])

  test "set store without ttl" do
    conn = conn(:post, "/stores", "key=key2&value=value")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "set store with ttl" do
    conn = conn(:post, "/stores", "key=key2&value=value&ttl=100000")
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "get store" do
    KVstore.Storage.set("key3", "value", 100_000)
    conn = conn(:get, "/stores/key3", "")
           |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "get Not found" do
    conn = conn(:get, "/stores/key4", "")
           |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 401
  end

  test "returns 404" do
    conn = conn(:get, "/missing", "")
           |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end