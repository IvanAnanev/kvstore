defmodule KVstore do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, KVstore.Router, [], port: 8080),
      worker(KVstore.Storage, [KVstore.Storage])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
