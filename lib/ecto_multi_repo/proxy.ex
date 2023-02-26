defmodule EctoMultiRepo.Proxy do
  @moduledoc false

  use GenServer, restart: :transient

  alias EctoMultiRepo.{
    WatchDog,
    ProxyRepo
  }

  def start_link(%{id: id} = arg) do
    GenServer.start_link(__MODULE__, arg, name: via_tuple(id))
  end

  defp via_tuple(id) do
    EctoMultiRepo.ProcessRegistry.via_tuple({__MODULE__, id})
  end

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

  def execute(id, command) do
    GenServer.call(via_tuple(id), {:execute, command})
  end

  def handle_call({:execute, command}, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.query(command)
    {:reply, res, watchdog}
  end
end
