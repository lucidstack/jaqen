defmodule Jaqen do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    token = Application.get_env(:jaqen, :api_token)

    children = [
      supervisor(Jaqen.Users.Supervisor, []),
      worker(Jaqen.ChatRegistry, []),
      worker(Jaqen.Bot, [token, []]),
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
