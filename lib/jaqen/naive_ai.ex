defmodule Jaqen.NaiveAi do
  @salute_regex ~r/^h(i*|e*y)\s.*!?$/i
  @beefeater_regex ~r/beefeater\??/i
  @yo_regex ~r/yo/i
  @morning_regex ~r/(good )?morning.*!?$/i
  @me_regex   ~r/what would I say.*?$/i
  @like_regex ~r/what would (?<username>[\w.-_+]+) say.*?$/i
  @sexy_regex ~r/wink/i
  @fantastic_regex ~r/fantastic|great|amazing|wonderful|majestic/i
  @cheerup_regex ~r/cheer\s.*up/i
  @thanks_regex ~r/thank/i

  def answer(message, slack) do
    cond do
      Regex.match? @me_regex, message.text ->
        user = Jaqen.Users.Registry.get_all
        |> Enum.map(&(&1 |> elem(1) |> Jaqen.Users.User.get))
        |> Enum.find(&(&1.id == message.user))

        message = user
        |> Map.get(:id)
        |> Jaqen.ChatRegistry.markov
        |> make_message(message.channel, %{name: user.name, image: user.profile.image_192})

        {:ok, :web_api, message}

      captures = Regex.named_captures(@like_regex, message.text) ->
        users = captures["username"] |> String.split("+") |> Enum.map(&get_user/1)

        message = users
        |> Enum.map(&Jaqen.ChatRegistry.all(&1.id))
        |> Enum.join(" ")
        |> Jaqen.Markov.generate
        |> make_message(message.channel, %{name: captures["username"], image: Enum.random(users).profile.image_192})

        {:ok, :web_api, message}
      Regex.match? @sexy_regex, message.text ->
        {:ok, :web_socket, make_message("https://media.giphy.com/media/l65tlPFwZXacU/giphy.gif", message.channel)}

      Regex.match?(@beefeater_regex, message.text) and mentioned?(message.text, slack.me) ->
        {:ok, :web_socket, make_message("Always :hearts:", message.channel)}

      Regex.match? @cheerup_regex, message.text ->
        {:ok, :web_socket, make_message("Here you go, <@#{message.user}>! :dog: :grin: :hearts: #{rand_giphy}", message.channel)}

      Regex.match?(@morning_regex, message.text) and mentioned?(message.text, slack.me) ->
        {:ok, :web_socket, make_message("Good morning <@#{message.user}>! :sunny:", message.channel)}

      Regex.match?(@thanks_regex, message.text) and mentioned?(message.text, slack.me) ->
        {:ok, :web_socket, make_message("It's a pleasure :bow:", message.channel)}

      Regex.match?(@fantastic_regex, message.text) and mentioned?(message.text, slack.me) ->
        {:ok, :web_socket, make_message("Thank you, <@#{message.user}>! :grinning:", message.channel)}

      Regex.match?(@salute_regex, message.text) and mentioned?(message.text, slack.me) ->
        {:ok, :web_socket, make_message("Hey there <@#{message.user}>! :wave:", message.channel)}

      Regex.match?(@yo_regex, message.text) and mentioned?(message.text, slack.me) ->
        {:ok, :web_socket, make_message("Yo!", message.channel)}

      true ->
        :skip
    end
  end

  @cuteness ["kitten", "puppy", "seal", "puppies", "dog", "kittens"]
  defp rand_giphy do
    url = "http://api.giphy.com/v1/gifs/search"
    params = %{q: Enum.random(@cuteness), limit: 50, api_key: "dc6zaTOxFJmzC"}

    HTTPoison.get!(url, %{}, params: params).body
    |> Poison.decode!
    |> Map.get("data")
    |> Enum.random
    |> Map.get("images")
    |> Map.get("fixed_height")
    |> Map.get("url")
  end

  defp make_message(text, channel) do
    %{type: "message", text: text, channel: channel}
  end

  defp make_message(text, channel, %{name: as, image: image}) do
    %{
      type: "message", text: text,
      channel: channel,
      as_user: false, username: as, icon_url: image,
      token: Application.get_env(:jaqen, :api_token)
    }
  end

  defp mentioned?(message, %{name: name, id: id}) do
    Regex.match?(~r/(#{name}|#{id})/i, message)
  end

  defp get_user(username) do
    username |> Jaqen.Users.Registry.whereis_name |> Jaqen.Users.User.get
  end
end
