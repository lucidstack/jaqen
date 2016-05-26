defmodule Jaqen.Users.Registry do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :users_registry)
  end

  def get_all do
    GenServer.call(:users_registry, :get_all)
  end

  def whereis_name(username) do
    GenServer.call(:users_registry, {:whereis_name, username})
  end

  def register_name(username, pid) do
    GenServer.call(:users_registry, {:register_name, username, pid})
  end

  def unregister_name(username) do
    GenServer.cast(:users_registry, {:unregister_name, username})
  end

  def send(username, message) do
    case whereis_name(username) do
      :undefined ->
        {:badarg, {username, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end


  # GenServer implementation
  ##########################
  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:whereis_name, username}, _from, state) do
    {:reply, Map.get(state, username, :undefined), state}
  end

  def handle_call({:register_name, username, pid}, _from, state) do
    case Map.get(state, username) do
      nil -> {:reply, :yes, Map.put(state, username, pid)}
      _   -> {:reply, :no, state}
    end
  end

  def handle_call(:get_all, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:unregister_name, username}, state) do
    {:noreply, Map.delete(state, username)}
  end
end
