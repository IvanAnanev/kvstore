# Для веб сервера нужен маршрутизатор, место ему именно тут.
defmodule KVstore.Router do
  use Plug.Router

  alias KVstore.Plug.VerifyRequest

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug VerifyRequest, fields: ["key", "value"], paths:  ["/stores"]

  plug :match
  plug :dispatch

  get "/stores/:key", do: send_resp(conn, 200, "GET")
  post "/stores", do: send_resp(conn, 200, "POST")

  match _, do: send_resp(conn, 404, "Oops!")
end
