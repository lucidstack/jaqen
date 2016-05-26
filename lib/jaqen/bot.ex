defmodule Jaqen.Bot do
  use Slack
  import Logger

  def handle_connect(slack, state) do
    info "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_message(%{user: user}, %{me: %{id: myself}}, state)
  when user == myself do
    {:ok, state}
  end

  def handle_message(%{type: "message"} = message, slack, state) do
    info "#{message.text} from #{message.channel}"

    case message |> Jaqen.NaiveAi.answer(slack) do
      :skip    -> nil
      response -> send_raw(response, slack)
    end

    {:ok, state ++ [message.text]}
  end

  def handle_message(message, slack, state) do
    {:ok, state}
  end
end
