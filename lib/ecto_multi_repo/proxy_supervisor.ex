defmodule EctoMultiRepo.ProxySupervisor do
  @moduledoc false

  def start_link() do
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def start_proxy(
        id,
        hostname,
        port,
        database,
        username,
        password,
        pool_size,
        timeout
      ) do
    args = %{
      id: id,
      hostname: hostname,
      port: port,
      database: database,
      username: username,
      password: password,
      pool_size: pool_size,
      timeout: timeout
    }

    DynamicSupervisor.start_child(__MODULE__, {EctoMultiRepo.Proxy, args})

    id
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
end
