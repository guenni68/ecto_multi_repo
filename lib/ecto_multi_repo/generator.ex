defmodule EctoMultiRepo.Generator do
  @moduledoc false

  alias EctoMultiRepo.{
    Watchdog,
    Proxy
  }

  functions = [
    aggregate: 2,
    aggregate: 3,
    aggregate: 4,
    all: 1,
    all: 2,
    checked_out?: 0,
    checkout: 1,
    checkout: 2,
    config: 0,
    default_options: 1,
    delete: 1,
    delete: 2,
    delete!: 1,
    delete!: 2,
    delete_all: 1,
    delete_all: 2,
    disconnect_all: 1,
    disconnect_all: 2,
    exists?: 1,
    exists?: 2,
    explain: 2,
    explain: 3,
    get: 2,
    get: 3,
    get!: 2,
    get!: 3,
    get_by: 2,
    get_by: 3,
    get_by!: 2,
    get_by!: 3,
    in_transaction?: 0,
    insert: 1,
    insert: 2,
    insert!: 1,
    insert!: 2,
    insert_all: 2,
    insert_all: 3,
    insert_or_update: 1,
    insert_or_update: 2,
    insert_or_update!: 1,
    insert_or_update!: 2,
    load: 2,
    one: 1,
    one: 2,
    one!: 1,
    one!: 2,
    preload: 2,
    preload: 3,
    prepare_query: 3,
    query: 1,
    query: 2,
    query: 3,
    query!: 1,
    query!: 2,
    query!: 3,
    query_many: 1,
    query_many: 2,
    query_many: 3,
    query_many!: 1,
    query_many!: 2,
    query_many!: 3,
    reload: 1,
    reload: 2,
    reload!: 1,
    reload!: 2,
    rollback: 1,
    stop: 0,
    stop: 1,
    stream: 1,
    stream: 2,
    to_sql: 2,
    transaction: 1,
    transaction: 2,
    update: 1,
    update: 2,
    update!: 1,
    update!: 2,
    update_all: 2,
    update_all: 3
  ]

  bang_funs =
    functions
    |> Enum.flat_map(fn {fun_name, _arity} ->
      ends_with_bang =
        fun_name
        |> Atom.to_string()
        |> String.ends_with?("!")

      if ends_with_bang do
        [fun_name]
      else
        []
      end
    end)
    |> Enum.uniq()

  def get_functions() do
    unquote(functions)
  end

  def get_bang_functions() do
    unquote(bang_funs)
  end

  # delegates
  def generate_delegates(call_timeout) do
    get_functions()
    |> group_functions()
    |> Enum.flat_map(&generate_delegate(&1, call_timeout))
  end

  defp generate_delegate({fun_name, %{min: min, max: max}}, _call_timeout) do
    {default, _args} = create_args(min, max)

    [
      quote do
        defdelegate unquote(fun_name)(id, unquote_splicing(default)), to: Proxy
      end
    ]
  end

  # handle event functions
  defmacro generate_handle_event_funs() do
    get_functions()
    |> group_functions()
    |> Enum.flat_map(&generate_handle_event_fun/1)
  end

  defp generate_handle_event_fun({fun_name, %{min: _min, max: max}}) do
    {args, args} = create_args(max, max)

    cond do
      fun_name in get_bang_functions() ->
        [
          quote do
            def handle_event(
                  {:call, from},
                  {unquote(fun_name), unquote_splicing(args)},
                  _state,
                  %{watchdog: watchdog, repo_module: repo_module}
                ) do
              Watchdog.im_alive(watchdog)

              res =
                try do
                  {:ok, repo_module.unquote(fun_name)(unquote_splicing(args))}
                rescue
                  exception ->
                    {:error, {exception, __STACKTRACE__}}
                end

              actions = [{:reply, from, res}]
              {:keep_state_and_data, actions}
            end
          end
        ]

      true ->
        [
          quote do
            def handle_event(
                  {:call, from},
                  {unquote(fun_name), unquote_splicing(args)},
                  _state,
                  %{watchdog: watchdog, repo_module: repo_module}
                ) do
              Watchdog.im_alive(watchdog)
              res = repo_module.unquote(fun_name)(unquote_splicing(args))
              actions = [{:reply, from, res}]
              {:keep_state_and_data, actions}
            end
          end
        ]
    end
  end

  # api calls
  defmacro generate_api_calls() do
    get_functions()
    |> group_functions()
    |> Enum.flat_map(&generate_api_call/1)
  end

  defp generate_api_call({fun_name, %{min: min, max: max}}) do
    {_default, args} = create_args(min, max)

    cond do
      fun_name in get_bang_functions() ->
        [
          quote do
            def unquote(fun_name)(id, unquote_splicing(args)) do
              case GenStateMachine.call(
                     via_tuple(id),
                     {unquote(fun_name), unquote_splicing(args)},
                     @call_timeout
                   ) do
                {:ok, res} ->
                  res

                {:error, {exception, stacktrace}} ->
                  reraise exception, stacktrace
              end
            end
          end
        ]

      true ->
        [
          quote do
            def unquote(fun_name)(id, unquote_splicing(args)) do
              GenStateMachine.call(
                via_tuple(id),
                {unquote(fun_name), unquote_splicing(args)},
                @call_timeout
              )
            end
          end
        ]
    end
  end

  # utilities
  def create_args(min, max, default_value \\ [])

  def create_args(n, n, _default_value) do
    args = Macro.generate_arguments(n, nil)
    {args, args}
  end

  def create_args(min, max, default_value) do
    args = Macro.generate_arguments(max, nil)

    default_args =
      args
      |> Enum.with_index(1)
      |> Enum.map(fn {arg, idx} ->
        if idx <= min do
          arg
        else
          quote do
            unquote(arg) \\ unquote(default_value)
          end
        end
      end)

    {default_args, args}
  end

  def group_functions(funs \\ get_functions()) do
    funs
    |> Enum.group_by(
      fn {fun_name, _arity} ->
        fun_name
      end,
      fn {_fun_name, arity} ->
        arity
      end
    )
    |> Enum.map(fn {fun_name, arities} ->
      min = Enum.min(arities)
      max = Enum.max(arities)
      {fun_name, %{min: min, max: max}}
    end)
    |> Enum.sort_by(fn {fun_name, _} -> fun_name end)
  end
end
