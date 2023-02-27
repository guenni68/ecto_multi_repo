defmodule EctoMultiRepo.Proxy do
  @moduledoc false

  use GenServer, restart: :temporary

  alias EctoMultiRepo.{
    WatchDog,
    ProxyRepo
  }

  def start_link(%{id: id} = arg) do
    GenServer.start_link(__MODULE__, arg, name: via_tuple(id))
  end

  def noop(id) do
    GenServer.cast(id, :noop)
  end

  def query(id, sql, params, opts) do
    GenServer.call(via_tuple(id), {:query, sql, params, opts})
  end

  defp via_tuple(id) do
    EctoMultiRepo.ProcessRegistry.via_tuple({__MODULE__, id})
  end

  @impl GenServer
  def init(%{timeout: timout} = arg) do
    params =
      arg
      |> Map.drop([:id, :timeout])
      |> Map.put(:name, nil)
      |> Enum.to_list()

    watchdog = WatchDog.start_watching(timout)
    {:ok, repo} = ProxyRepo.start_link(params)
    ProxyRepo.put_dynamic_repo(repo)

    {:ok, watchdog}
  end

  @impl GenServer
  def handle_cast(:noop, watchdog) do
    WatchDog.im_alive(watchdog)
    {:noreply, watchdog}
  end

  @impl GenServer
  def handle_call({:query, sql, params, opts}, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.query(sql, params, opts)
    {:reply, res, watchdog}
  end
end
