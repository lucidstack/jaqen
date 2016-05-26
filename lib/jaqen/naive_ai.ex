defmodule Jaqen.NaiveAi do
  @salute_regex ~r/^h(i*|e*y).*!?$/i
  @morning_regex ~r/(good)? morning.*!?$/i
  @me_regex   ~r/what would I say.*?$/i
  @like_regex ~r/what would (?<username>[\w.-_]+) say.*?$/i

  def answer(message, slack) do
    cond do
     Regex.match? @salute_regex, message.text ->
       %{
         type: "message",
         text: "Hey there <@#{message.user}>! :wave:",
         channel: message.channel
       } |> Poison.encode!
     Regex.match? @morning_regex, message.text ->
       %{
         type: "message",
         text: "Good morning <@#{message.user}>! :sunny:",
         channel: message.channel
       } |> Poison.encode!
     Regex.match? @me_regex, message.text ->
       %{
         type: "message",
         text: Jaqen.ChatRegistry.markov(message.user),
         channel: message.channel
       } |> Poison.encode!
     captures = Regex.named_captures(@like_regex, message.text) ->
       user = captures["username"]
       |> Jaqen.Users.Registry.whereis_name
       |> Jaqen.Users.User.get

       %{
         type: "message",
         text: Jaqen.ChatRegistry.markov(user.id),
         channel: message.channel,
         as_user: false,
         username: captures["username"],
         unfurl_links: true,
         parse: "full",
         icon_url: user.profile.image_original
       } |> Poison.encode!
      true ->
        :skip
    end
  end
end
