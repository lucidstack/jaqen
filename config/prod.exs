use Mix.Config

config :jaqen, api_token: System.get_env("SLACK_API_TOKEN")

if File.exists?("config/dev.secret.exs") do
  import_config "#{Mix.env}.secret.exs"
end
