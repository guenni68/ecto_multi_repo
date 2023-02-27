defmodule EctoMultiRepo do
  @moduledoc """
  Documentation for `EctoMultiRepo`.
  """

  defmacro __using__(_opts) do
    quote do
      alias EctoMultiRepo.{
        ProxySupervisor,
        Proxy,
        Behaviour
      }

      use Behaviour

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

      @impl Behaviour
      defdelegate noop(id), to: Proxy

      @impl Behaviour
      defdelegate aggregate(id, queryable, aggregate, opts \\ []), to: Proxy

      @impl Behaviour
      defdelegate aggregate(id, queryable, aggregate, field, opts), to: Proxy

      @impl Behaviour
      defdelegate all(id, queryable, opts \\ []), to: Proxy

      @impl Behaviour
      defdelegate checked_out?(id), to: Proxy

      @impl Behaviour
      defdelegate checkout(id, fun, opts \\ []), to: Proxy

      @impl Behaviour
      defdelegate config(id), to: Proxy

      @impl Behaviour
      defdelegate delete!(id, struct, opts \\ []), to: Proxy

      @impl Behaviour
      defdelegate delete(id, struct, opts \\ []), to: Proxy

      @impl Behaviour
      defdelegate delete_all(id, queryable, opts \\ []), to: Proxy

      @impl Behaviour
      defdelegate default_options(id, operation), to: Proxy

      @impl Behaviour
      defdelegate exists?(id, queryable, opts \\ []), to: Proxy

      @impl Behaviour
      defdelegate explain(id, operation, queryable, opts \\ []), to: Proxy

      @impl Behaviour
      defdelegate get(conn_ident, queryable, id, opts \\ []), to: Proxy

      @impl Behaviour
      defdelegate get!(conn_ident, queryable, id, opts \\ []), to: Proxy

      @impl Behaviour
      defdelegate get_by(id, queryable, clauses, opts \\ []), to: Proxy

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
