defmodule EctoMultiRepo do
  @moduledoc """
  Documentation for `EctoMultiRepo`.
  """

  defmacro __using__(_opts) do
    quote do
      use EctoMultiRepo.Behaviour
      alias EctoMultiRepo.{ProxySupervisor, Proxy}

      defdelegate start_repo(
                    id \\ UUID.uuid1(),
                    hostname,
                    port,
                    database,
                    username,
                    password,
                    pool_size \\ 3,
                    timeout \\ :timer.minutes(10)
                  ),
                  to: ProxySupervisor,
                  as: :start_proxy

      defdelegate noop(id), to: Proxy

      defdelegate aggregate(id, queryable, aggregate, opts \\ []), to: Proxy

      defdelegate aggregate(id, queryable, aggregate, field, opts), to: Proxy

      defdelegate all(id, queryable, opts \\ []), to: Proxy

      defdelegate checked_out?(id), to: Proxy

      defdelegate checkout(id, fun, opts \\ []), to: Proxy

      defdelegate config(id), to: Proxy

      defdelegate delete!(id, struct, opts \\ []), to: Proxy

      defdelegate delete(id, struct, opts \\ []), to: Proxy

      defdelegate delete_all(id, queryable, opts \\ []), to: Proxy

      defdelegate default_options(id, operation), to: Proxy

      defdelegate exists?(id, queryable, opts \\ []), to: Proxy

      defdelegate explain(id, operation, queryable, opts \\ []), to: Proxy

      defdelegate get!(conn_ident, queryable, id, opts \\ []), to: Proxy

      defdelegate query(
                    id,
                    sql,
                    params \\ [],
                    opts \\ []
                  ),
                  to: Proxy
    end
  end
end
