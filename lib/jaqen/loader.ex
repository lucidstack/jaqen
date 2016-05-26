defmodule Jaqen.Loader do
  def users(json_path) do
    json_path
    |> File.read!
    |> Poison.decode!(keys: :atoms)
  end

  def exports(paths) when is_list(paths) do
    {:ok, registry} = Agent.start_link(fn -> %{} end)

    paths
    |> Enum.map(&Task.async(__MODULE__, :export, [&1, registry]))
    |> Enum.map(&Task.await(&1, 20000))

    messages = Agent.get(registry, &(&1))
    Agent.stop(registry)

    messages
  end

  def export(path, registry) do
    path
    |> File.read!
    |> Poison.decode!(keys: :atoms)
    |> Enum.each(fn(message) -> add_to_registry(message, registry) end)

    :ok
  end

  defp add_to_registry(%{user: user, text: text}, registry) do
    Agent.update registry, fn(messages) ->
      Map.update messages, user, [], &([text | &1])
    end
  end

  defp add_to_registry(_message, registry) do
    nil
  end
end
