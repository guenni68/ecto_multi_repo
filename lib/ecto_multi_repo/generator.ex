defmodule EctoMultiRepo.Generator do
  @moduledoc false

  functions = [
    __adapter__: 0,
    aggregate: 2,
    aggregate: 3,
    aggregate: 4,
    all: 1,
    all: 2,
    checked_out?: 0,
    checkout: 1,
    checkout: 2,
    child_spec: 1,
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
    get_dynamic_repo: 0,
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
    put_dynamic_repo: 1,
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
    start_link: 0,
    start_link: 1,
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

  def get_functions() do
    unquote(functions)
  end

  defmacro generate_api_calls() do
    get_functions()
    |> Enum.flat_map(&generate_api_call/1)
  end

  defp generate_api_call({fun_name, _arity})
       when fun_name in [
              :__adapter__
            ] do
    []
  end

  defp generate_api_call({fun_name, arity}) do
    args = Macro.generate_arguments(arity, nil)

    [
      quote do
        def unquote(fun_name)(id, unquote_splicing(args)) do
          GenStateMachine.call(via_tuple(id), {unquote(fun_name), unquote_splicing(args)})
        end
      end
    ]
  end
end
