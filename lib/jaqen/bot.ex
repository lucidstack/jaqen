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

  def handle_message(%{type: "message", text: text} = message, slack, state) do
    info "#{text} from #{message.channel}"

    case message |> Jaqen.NaiveAi.answer(slack) do
      {:ok, :web_socket, response} -> via_web_socket(response, slack)
      {:ok, :web_api,    response} -> via_web_api(response)
      :skip                        -> nil
    end

    {:ok, state ++ [message.text]}
  end

  def handle_message(message, slack, state) do
    {:ok, state}
  end

  defp via_web_socket(response, slack) do
    response
    |> Poison.encode!
    |> send_raw(slack)
  end

  defp via_web_api(response) do
    "https://slack.com/api/chat.postMessage"
    |> HTTPoison.get!(%{}, params: response)
  end
end
