defmodule EctoMultiRepo.Proxy do
  @moduledoc false

  use GenStateMachine, restart: :temporary

  alias EctoMultiRepo.{
    Watchdog,
    ProxyRepo,
    ProcessRegistry,
    Behaviour
  }

  use Behaviour

  def start_link(%{id: id} = arg) do
    GenStateMachine.start_link(__MODULE__, arg, name: via_tuple(id))
  end

  @impl Behaviour
  def noop(id) do
    GenStateMachine.cast(id, :noop)
  end

  @impl Behaviour
  def aggregate(id, queryable, aggregate, opts \\ []) do
    GenStateMachine.call(via_tuple(id), {:aggregate, queryable, aggregate, opts})
  end

  @impl Behaviour
  def aggregate(id, queryable, aggregate, field, opts) do
    GenStateMachine.call(via_tuple(id), {:aggregate, queryable, aggregate, field, opts})
  end

  @impl Behaviour
  def all(id, queryable, opts) do
    GenStateMachine.call(via_tuple(id), {:all, queryable, opts})
  end

  @impl Behaviour
  def checked_out?(id) do
    GenStateMachine.call(via_tuple(id), :checked_out?)
  end

  @impl Behaviour
  def checkout(id, fun, opts) do
    GenStateMachine.call(via_tuple(id), {:checkout, fun, opts})
  end

  @impl Behaviour
  def config(id) do
    GenStateMachine.call(via_tuple(id), :config)
  end

  @impl Behaviour
  def delete!(id, struct, opts) do
    GenStateMachine.call(via_tuple(id), {:delete!, struct, opts})
  end

  @impl Behaviour
  def delete(id, struct, opts) do
    GenStateMachine.call(via_tuple(id), {:delete, struct, opts})
  end

  @impl Behaviour
  def delete_all(id, struct, opts) do
    GenStateMachine.call(via_tuple(id), {:delete_all, struct, opts})
  end

  @impl Behaviour
  def default_options(id, operation) do
    GenStateMachine.call(via_tuple(id), {:default_options, operation})
  end

  @impl Behaviour
  def exists?(id, queryable, opts \\ []) do
    GenStateMachine.call(via_tuple(id), {:exists?, queryable, opts})
  end

  @impl Behaviour
  def explain(id, operation, queryable, opts \\ []) do
    GenStateMachine.call(via_tuple(id), {:explain, operation, queryable, opts})
  end

  @impl Behaviour
  def get(conn_ident, queryable, id, opts \\ []) do
    GenStateMachine.call(via_tuple(conn_ident), {:get, queryable, id, opts})
  end

  @impl Behaviour
  def get!(conn_ident, queryable, id, opts \\ []) do
    GenStateMachine.call(via_tuple(conn_ident), {:get!, queryable, id, opts})
  end

  @impl Behaviour
  def get_by(id, queryable, clauses, opts) do
    GenStateMachine.call(via_tuple(id), {:get_by, queryable, clauses, opts})
  end

  #  @impl Behaviour
  def query(id, sql, params, opts) do
    GenStateMachine.call(via_tuple(id), {:query, sql, params, opts})
  end

  defp via_tuple(id) do
    ProcessRegistry.via_tuple({__MODULE__, id})
  end

  @impl GenStateMachine
  def init(%{timeout: timout, repo_module: repo_module} = arg) do
    params =
      arg
      |> Map.drop([:id, :timeout, :repo_module])
      |> Map.put(:name, nil)
      |> Enum.to_list()

    watchdog = Watchdog.start_watching(timout)
    {:ok, repo} = repo_module.start_link(params)
    repo_module.put_dynamic_repo(repo)

    {:ok, :running, %{watchdog: watchdog, repo_module: repo_module}}
  end

  @impl GenStateMachine
  def handle_event(event_type, payload, :running, data) do
    running(event_type, payload, data)
  end

  defp running(event_type, payload, data)

  # noop
  defp running(:cast, :noop, %{watchdog: watchdog}) do
    Watchdog.im_alive(watchdog)
    :keep_state_and_data
  end

  # aggregate
  defp running(
         {:call, from},
         {:aggregate, queryable, aggregate, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.aggregate(queryable, aggregate, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  defp running(
         {:call, from},
         {:aggregate, queryable, aggregate, field, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.aggregate(queryable, aggregate, field, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # all
  def handle_call({:all, queryable, opts}, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.all(queryable, opts)
    {:reply, res, watchdog}
  end

  # checked out?
  def handle_call(:checked_out?, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.checked_out?()
    {:reply, res, watchdog}
  end

  # checkout
  def handle_call({:checkout, fun, opts}, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.checkout(fun, opts)
    {:reply, res, watchdog}
  end

  # config
  def handle_call(:config, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.config()
    {:reply, res, watchdog}
  end

  # delete!
  def handle_call({:delete!, struct, opts}, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.delete!(struct, opts)
    {:reply, res, watchdog}
  end

  # delete
  def handle_call({:delete, struct, opts}, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.delete(struct, opts)
    {:reply, res, watchdog}
  end

  # delete
  def handle_call({:delete_all, struct, opts}, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.delete_all(struct, opts)
    {:reply, res, watchdog}
  end

  # default_options
  def handle_call({:default_options, operation}, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.default_options(operation)
    {:reply, res, watchdog}
  end

  # exists?
  def handle_call({:exists?, queryable, opts}, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.exists?(queryable, opts)
    {:reply, res, watchdog}
  end

  # explain
  def handle_call({:explain, operation, queryable, opts}, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.explain(operation, queryable, opts)
    {:reply, res, watchdog}
  end

  # get
  def handle_call({:get, queryable, id, opts}, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.get(queryable, id, opts)
    {:reply, res, watchdog}
  end

  # get!
  def handle_call({:get!, queryable, id, opts}, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.get!(queryable, id, opts)
    {:reply, res, watchdog}
  end

  # get_by
  def handle_call({:get_by, queryable, clauses, opts}, _from, watchdog) do
    Watchdog.im_alive(watchdog)
    res = ProxyRepo.get_by(queryable, clauses, opts)
    {:reply, res, watchdog}
  end

  # query
  defp running(
         {:call, from},
         {:query, sql, params, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.query(sql, params, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end
end
