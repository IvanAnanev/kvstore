# Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии.
defmodule KVstore.Storage do
  use GenServer

  @table_name :storage
  @default_ttl 12 * 60 * 60_000 # 12 hours

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def init(_state) do
    state = %{}
    :ets.new(@table_name, [:set, :named_table])
    {:ok, state}
  end

  # Client API
  def set(key, value, ttl \\ @default_ttl) do
    GenServer.cast(__MODULE__, {:set, key, value, ttl})
  end

  def get(key) do
    :ets.lookup(@table_name, key)
  end

  # callbacks
  def handle_cast({:set, key, value, ttl}, state) do
    if Map.has_key?(state, key), do: Process.cancel_timer(Map.get(state, key))
    :ets.insert(@table_name, {key, value})
    timer = Process.send_after(self(), {:delete, key},  ttl)
    new_state = Map.put(state, key, timer)
    {:noreply, new_state}
  end
  def handle_cast(_, state) do
    {:noreply, state}
  end

  def handle_info({:delete, key}, state) do
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
