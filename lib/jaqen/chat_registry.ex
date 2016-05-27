defmodule Jaqen.ChatRegistry do
  alias Jaqen.Loader

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    sentences_by_user = :code.priv_dir(:jaqen)
    |> Path.join("slack_export/**/????-??-??.json")
    |> Path.wildcard
    |> Loader.exports

    {:ok, sentences_by_user}
  end

  def all(user_id) do
    GenServer.call(__MODULE__, {:all, user_id})
  end

  def random(user_id) do
    GenServer.call(__MODULE__, {:random, user_id})
  end

  def markov(user_id) do
    GenServer.call(__MODULE__, {:markov, user_id})
  end

  # GenServer implementation
  ##########################

  def handle_call({:all, user_id}, _from, state) do
    case state[user_id] do
      nil      -> {:reply, {:error, :user_not_found}, state}
      messages -> {:reply, Enum.join(messages, " "),  state}
    end
  end

  def handle_call({:random, user_id}, _from, state) do
    case state[user_id] do
      nil      -> {:reply, {:error, :user_not_found}, state}
      messages -> {:reply, Enum.random(messages),     state}
    end
  end

  def handle_call({:markov, user_id}, _from, state) do
    case state[user_id] do
      nil      -> {:reply, {:error, :user_not_found}, state}
      messages -> {:reply, Jaqen.Markov.generate(Enum.join(messages, " ")), state}
    end
  end
end
