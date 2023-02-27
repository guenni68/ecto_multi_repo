defmodule EctoMultiRepo do
  @moduledoc """
  Documentation for `EctoMultiRepo`.
  """

  alias EctoMultiRepo.ProxyRepo.{
    Postgres
  }

  defmacro __using__(_opts) do
    repo_module =
      _opts
      |> Keyword.get(:database_type)
      |> choose_repo_module()

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

  defp choose_repo_module(nil) do
    raise "Missing option :database_type at use: #{__MODULE__}"
  end

  defp choose_repo_module(:postgres) do
    Postgres
  end

  defp choose_repo_module(other) do
    raise "Invalid option :database_type at use: #{__MODULE__}, #{inspect(other)}"
  end
end
