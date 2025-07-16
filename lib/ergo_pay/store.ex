defmodule ErgoPay.Store do
  def put(obj) do
    id = generate_id()
    ensure_started()

    Agent.update(__MODULE__, fn m ->
      m = Map.put(m, id, obj)

      if map_size(m) > 100 do
        {old_id, _} = Enum.min_by(m, fn {k, _} -> String.to_integer(k) end)
        Map.delete(m, old_id)
      else
        m
      end
    end)

    id
  end

  def get(id) do
    ensure_started()
    Agent.get(__MODULE__, &Map.get(&1, id))
  end

  defp ensure_started do
    case Process.whereis(__MODULE__) do
      nil -> Agent.start_link(fn -> %{} end, name: __MODULE__)
      _ -> :ok
    end
  end

  defp generate_id do
    :erlang.unique_integer([:positive, :monotonic]) |> Integer.to_string()
  end
end
