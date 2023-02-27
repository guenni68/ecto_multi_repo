defmodule EctoMultiRepo.Proxy do
  @moduledoc false

  use GenServer, restart: :temporary

  alias EctoMultiRepo.{
    WatchDog,
    ProxyRepo,
    ProcessRegistry,
    Behaviour
  }

  use Behaviour

  def start_link(%{id: id} = arg) do
    GenServer.start_link(__MODULE__, arg, name: via_tuple(id))
  end

  @impl Behaviour
  def noop(id) do
    GenServer.cast(id, :noop)
  end

  @impl Behaviour
  def aggregate(id, queryable, aggregate, opts \\ []) do
    GenServer.call(via_tuple(id), {:aggregate, queryable, aggregate, opts})
  end

  @impl Behaviour
  def aggregate(id, queryable, aggregate, field, opts) do
    GenServer.call(via_tuple(id), {:aggregate, queryable, aggregate, field, opts})
  end

  @impl Behaviour
  def all(id, queryable, opts) do
    GenServer.call(via_tuple(id), {:all, queryable, opts})
  end

  @impl Behaviour
  def checked_out?(id) do
    GenServer.call(via_tuple(id), :checked_out?)
  end

  @impl Behaviour
  def checkout(id, fun, opts) do
    GenServer.call(via_tuple(id), {:checkout, fun, opts})
  end

  @impl Behaviour
  def config(id) do
    GenServer.call(via_tuple(id), :config)
  end

  @impl Behaviour
  def delete!(id, struct, opts) do
    GenServer.call(via_tuple(id), {:delete!, struct, opts})
  end

  @impl Behaviour
  def delete(id, struct, opts) do
    GenServer.call(via_tuple(id), {:delete, struct, opts})
  end

  @impl Behaviour
  def delete_all(id, struct, opts) do
    GenServer.call(via_tuple(id), {:delete_all, struct, opts})
  end

  @impl Behaviour
  def default_options(id, operation) do
    GenServer.call(via_tuple(id), {:default_options, operation})
  end

  @impl Behaviour
  def exists?(id, queryable, opts \\ []) do
    GenServer.call(via_tuple(id), {:exists?, queryable, opts})
  end

  #  @impl Behaviour
  def query(id, sql, params, opts) do
    GenServer.call(via_tuple(id), {:query, sql, params, opts})
  end

  defp via_tuple(id) do
    ProcessRegistry.via_tuple({__MODULE__, id})
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

  # noop
  @impl GenServer
  def handle_cast(:noop, watchdog) do
    WatchDog.im_alive(watchdog)
    {:noreply, watchdog}
  end

  # aggregate
  @impl GenServer
  def handle_call({:aggregate, queryable, aggregate, opts}, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.aggregate(queryable, aggregate, opts)
    {:reply, res, watchdog}
  end

  @impl GenServer
  def handle_call({:aggregate, queryable, aggregate, field, opts}, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.aggregate(queryable, aggregate, field, opts)
    {:reply, res, watchdog}
  end

  # all
  @impl GenServer
  def handle_call({:all, queryable, opts}, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.all(queryable, opts)
    {:reply, res, watchdog}
  end

  # checked out?
  @impl GenServer
  def handle_call(:checked_out?, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.checked_out?()
    {:reply, res, watchdog}
  end

  # checkout
  @impl GenServer
  def handle_call({:checkout, fun, opts}, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.checkout(fun, opts)
    {:reply, res, watchdog}
  end

  # config
  @impl GenServer
  def handle_call(:config, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.config()
    {:reply, res, watchdog}
  end

  # delete!
  @impl GenServer
  def handle_call({:delete!, struct, opts}, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.delete!(struct, opts)
    {:reply, res, watchdog}
  end

  # delete
  @impl GenServer
  def handle_call({:delete, struct, opts}, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.delete(struct, opts)
    {:reply, res, watchdog}
  end

  # delete
  @impl GenServer
  def handle_call({:delete_all, struct, opts}, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.delete_all(struct, opts)
    {:reply, res, watchdog}
  end

  # default_options
  @impl GenServer
  def handle_call({:default_options, operation}, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.default_options(operation)
    {:reply, res, watchdog}
  end

  # exists?
  @impl GenServer
  def handle_call({:exists?, queryable, opts}, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.exists?(queryable, opts)
    {:reply, res, watchdog}
  end

  # query
  @impl GenServer
  def handle_call({:query, sql, params, opts}, _from, watchdog) do
    WatchDog.im_alive(watchdog)
    res = ProxyRepo.query(sql, params, opts)
    {:reply, res, watchdog}
  end
end
