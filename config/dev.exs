use Mix.Config

config :jaqen, api_token: "API_TOKEN"

if File.exists?("config/dev.secret.exs") do
  import_config "#{Mix.env}.secret.exs"
end
