# Для веб сервера нужен маршрутизатор, место ему именно тут.
defmodule KVstore.Router do
  use Plug.Router
  use Plug.ErrorHandler

  alias KVstore.Plug.VerifyRequest
  alias KVstore.Storage

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug VerifyRequest, fields: ["key", "value"], paths:  ["/stores"]

  plug :match
  plug :dispatch

  get "/stores/:key", do: get_store(conn)
  post "/stores", do: set_store(conn)

  match _, do: send_resp(conn, 404, "Oops!")

  # handle exception from VerifyReques
  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Incomplete request, need key and value!")
  end

  # plug for get store
  defp get_store(conn) do
    %{"key" => key} = conn.params
    IO.inspect(conn.params)
    case Storage.get(key) do
      :error -> send_resp(conn, 401, "Not found!")
      value -> send_resp(conn, 200, value)
    end
  end

  # plug for set store
  defp set_store(conn) do
    case conn.params do
      %{"key" => key, "ttl" => ttl, "value" => value} ->
        # parse ttl to integer and use it if is integer
        case Integer.parse(ttl) do
          {parse_ttl, ""} -> Storage.set(key, value, parse_ttl)
          _ -> Storage.set(key, value)
        end
        IO.inspect(conn.params)
        send_resp(conn, 200, "Success!")
     %{"key" => key, "value" => value} ->
        Storage.set(key, value)
        IO.inspect(conn.params)
        send_resp(conn, 200, "Success!")
    end
  end
end
