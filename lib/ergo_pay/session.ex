defmodule ErgoPay.Session do
  use GenServer
  @ttl 300_000
  @cleanup 60_000

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def set(id, data), do: GenServer.cast(__MODULE__, {:set, id, data})
  def get(id), do: GenServer.call(__MODULE__, {:get, id})

  def init(state) do
    :timer.send_interval(@cleanup, :cleanup)
    {:ok, state}
  end

  def handle_call({:get, id}, _from, state) do
    now = System.monotonic_time(:millisecond)

    reply =
      case Map.get(state, id) do
        {value, ts} when now - ts < @ttl -> value
        _ -> nil
      end

    {:reply, reply, state}
  end

  def handle_cast({:set, id, data}, state) do
    {:noreply, Map.put(state, id, {data, System.monotonic_time(:millisecond)})}
  end

  def handle_info(:cleanup, state) do
    now = System.monotonic_time(:millisecond)

    state =
      Enum.reduce(state, %{}, fn {id, {data, ts}}, acc ->
        if now - ts < @ttl, do: Map.put(acc, id, {data, ts}), else: acc
      end)

    {:noreply, state}
  end
end
