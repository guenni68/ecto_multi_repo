defmodule EctoMultiRepo.Proxy do
  @moduledoc false

  use GenStateMachine, restart: :temporary

  alias EctoMultiRepo.{
    Watchdog,
    ProcessRegistry
  }

  def start_link(%{id: id} = arg) do
    GenStateMachine.start_link(__MODULE__, arg, name: via_tuple(id))
  end

  def noop(id) do
    GenStateMachine.cast(id, :noop)
  end

  def aggregate(id, queryable, aggregate, opts \\ []) do
    GenStateMachine.call(via_tuple(id), {:aggregate, queryable, aggregate, opts})
  end

  def aggregate(id, queryable, aggregate, field, opts) do
    GenStateMachine.call(via_tuple(id), {:aggregate, queryable, aggregate, field, opts})
  end

  def all(id, queryable, opts) do
    GenStateMachine.call(via_tuple(id), {:all, queryable, opts})
  end

  def checked_out?(id) do
    GenStateMachine.call(via_tuple(id), :checked_out?)
  end

  def checkout(id, fun, opts) do
    GenStateMachine.call(via_tuple(id), {:checkout, fun, opts})
  end

  def config(id) do
    GenStateMachine.call(via_tuple(id), :config)
  end

  def delete!(id, struct, opts) do
    GenStateMachine.call(via_tuple(id), {:delete!, struct, opts})
  end

  def delete(id, struct, opts) do
    GenStateMachine.call(via_tuple(id), {:delete, struct, opts})
  end

  def delete_all(id, struct, opts) do
    GenStateMachine.call(via_tuple(id), {:delete_all, struct, opts})
  end

  def default_options(id, operation) do
    GenStateMachine.call(via_tuple(id), {:default_options, operation})
  end

  def exists?(id, queryable, opts \\ []) do
    GenStateMachine.call(via_tuple(id), {:exists?, queryable, opts})
  end

  def explain(id, operation, queryable, opts \\ []) do
    GenStateMachine.call(via_tuple(id), {:explain, operation, queryable, opts})
  end

  def get(conn_ident, queryable, id, opts \\ []) do
    GenStateMachine.call(via_tuple(conn_ident), {:get, queryable, id, opts})
  end

  def get!(conn_ident, queryable, id, opts \\ []) do
    GenStateMachine.call(via_tuple(conn_ident), {:get!, queryable, id, opts})
  end

  def get_by(id, queryable, clauses, opts) do
    GenStateMachine.call(via_tuple(id), {:get_by, queryable, clauses, opts})
  end

  def query(id, sql, params, opts) do
    GenStateMachine.call(via_tuple(id), {:query, sql, params, opts})
  end

  defp via_tuple(id) do
    ProcessRegistry.via_tuple({__MODULE__, id})
  end

  @impl GenStateMachine
  def init(arg) do
    actions = [{:next_event, :internal, arg}]
    {:ok, :connecting, nil, actions}
  end

  @impl GenStateMachine
  def handle_event(
        :internal,
        %{timeout: timout, repo_module: repo_module} = arg,
        :connecting,
        nil
      ) do
    params =
      arg
      |> Map.drop([:id, :timeout, :repo_module])
      |> Map.put(:name, nil)
      |> Enum.to_list()

    watchdog = Watchdog.start_watching(timout)
    {:ok, repo} = repo_module.start_link(params)
    repo_module.put_dynamic_repo(repo)

    {:next_state, :running, %{watchdog: watchdog, repo_module: repo_module}}
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
  defp running(
         {:call, from},
         {:all, queryable, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.all(queryable, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # checked out?
  defp running(
         {:call, from},
         :checked_out?,
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.checked_out?()
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # checkout
  defp running(
         {:call, from},
         {:checkout, fun, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.checkout(fun, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # config
  defp running(
         {:call, from},
         :config,
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.config()
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # delete!
  defp running(
         {:call, from},
         {:delete!, struct, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.delete!(struct, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # delete
  defp running(
         {:call, from},
         {:delete, struct, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.delete(struct, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # delete_all
  defp running(
         {:call, from},
         {:delete_all, struct, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.delete_all(struct, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # default_options
  defp running(
         {:call, from},
         {:default_options, operation},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.default_options(operation)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # exists?
  defp running(
         {:call, from},
         {:exists?, queryable, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.exists?(queryable, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # explain
  defp running(
         {:call, from},
         {:explain, operation, queryable, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.explain(operation, queryable, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # get
  defp running(
         {:call, from},
         {:get, queryable, id, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.get(queryable, id, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # get!
  defp running(
         {:call, from},
         {:get!, queryable, id, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.get!(queryable, id, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
  end

  # get_by
  defp running(
         {:call, from},
         {:get_by, queryable, clauses, opts},
         %{
           watchdog: watchdog,
           repo_module: repo_module
         }
       ) do
    Watchdog.im_alive(watchdog)
    res = repo_module.get_by(queryable, clauses, opts)
    actions = [{:reply, from, res}]
    {:keep_state_and_data, actions}
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
