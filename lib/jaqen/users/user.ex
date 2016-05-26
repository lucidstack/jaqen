defmodule Jaqen.Users.User do
  def start_link(data) do
    Agent.start_link(fn -> data end, name: user_tuple(data.name))
  end

  def get(pid) do
    Agent.get pid, &(&1)
  end

  def id(pid) do
    Agent.get pid, &(&1.id)
  end

  def username(pid) do
    Agent.get pid, &(&1.name)
  end

  defp user_tuple(username) do
    {:via, Jaqen.Users.Registry, username}
  end
end
