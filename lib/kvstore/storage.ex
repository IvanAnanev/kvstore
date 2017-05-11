# Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии.
defmodule KVstore.Storage do
  use GenServer

  @table_name :storage
  @default_ttl 12 * 60 * 60_000 # 12 hours

  ## Client API

  @doc """
  Starts the storage.
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  @doc """
  Set key, value pair with ttl life circle.
  If ttl is not given, use default ttl 12 hours
  """
  def set(key, value, ttl \\ @default_ttl) do
    GenServer.cast(__MODULE__, {:set, key, value, ttl})
  end

  @doc """
  Get key value
  return [] if key not found.
  return [{key, value}] if found.
  """
  def get(key) do
    case :ets.lookup(@table_name, key) do
      [{^key, value}] -> value
      [] -> :error
    end
  end

  ## Server Callbacks

  def init(_state) do
    # create ets table
    :ets.new(@table_name, [:set, :named_table])
    {:ok, %{}}
  end

  def handle_cast({:set, key, value, ttl}, state) do
    # ttl timer reset by key in state if it has on state
    if Map.has_key?(state, key), do: Process.cancel_timer(Map.get(state, key))
    # set {key, value} in ets table
    :ets.insert(@table_name, {key, value})
    # set new ttl timer for delete {key, value}
    timer = Process.send_after(self(), {:delete, key},  ttl)
    # save ttl timer on state
    new_state = Map.put(state, key, timer)
    {:noreply, new_state}
  end
  def handle_cast(_, state) do
    {:noreply, state}
  end

  def handle_info({:delete, key}, state) do
    # delete {key, value} from ets
    :ets.delete(@table_name, key)
    {:noreply, state}
  end
  def handle_info(_, state) do
    {:noreply, state}
  end

  def handle_call(_, _, state) do
    {:noreply, state}
  end
end
