defmodule PololuAStar32u4.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [{PololuAStar32u4.Driver, []}]

    opts = [strategy: :one_for_one, name: PololuAStar32u4.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
