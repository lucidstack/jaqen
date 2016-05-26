defmodule Jaqen.Users.Supervisor do
  alias Jaqen.Loader
  alias Jaqen.Users.User
  alias Jaqen.Users.Registry

  def start_link do
    import Supervisor.Spec

    registry = worker(Registry, [])
    users = :code.priv_dir(:jaqen)
    |> Path.join("slack_export/users.json")
    |> Loader.users
    |> Enum.map(&worker(User, [&1], id: &1.id))

    Supervisor.start_link(
      [registry | users],
      strategy: :one_for_one,
      name: __MODULE__
    )
  end
end
