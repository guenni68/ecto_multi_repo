defmodule EctoMultiRepo.ProxySupervisor do
  @moduledoc false

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl DynamicSupervisor
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_proxy(
        id,
        hostname,
        port,
        database,
        username,
        password,
        pool_size,
        timeout,
        repo_module
      ) do
    args = %{
      id: id,
      hostname: hostname,
      port: port,
      database: database,
      username: username,
      password: password,
      pool_size: pool_size,
      timeout: timeout,
      repo_module: repo_module
    }

    case DynamicSupervisor.start_child(__MODULE__, {EctoMultiRepo.Proxy, args}) do
      {:ok, _pid} ->
        {:ok, id}

      {:error, {:already_started, _pid}} ->
        {:ok, id}

      error ->
        error
    end
  end
end
