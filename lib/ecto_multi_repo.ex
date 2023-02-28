defmodule EctoMultiRepo do
  @moduledoc """
  Documentation for `EctoMultiRepo`.
  """

  alias EctoMultiRepo.ProxyRepo.{
    Postgres,
    MySQL,
    MSSQL
  }

  defmacro __using__(opts) do
    repo_module =
      opts
      |> Keyword.get(:database_type)
      |> choose_repo_module()

    quote do
      alias EctoMultiRepo.{
        ProxySupervisor,
        Proxy
      }

      def start_repo(
            id \\ UUID.uuid1(),
            hostname,
            port,
            database,
            username,
            password,
            pool_size \\ 3,
            timeout \\ :timer.minutes(10)
          ) do
        ProxySupervisor.start_proxy(
          id,
          hostname,
          port,
          database,
          username,
          password,
          pool_size,
          timeout,
          unquote(repo_module)
        )
      end

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

      defdelegate get(conn_ident, queryable, id, opts \\ []), to: Proxy

      defdelegate get!(conn_ident, queryable, id, opts \\ []), to: Proxy

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

  defp choose_repo_module(:mysql) do
    MySQL
  end

  defp choose_repo_module(:mssql) do
    MSSQL
  end

  defp choose_repo_module(other) do
    raise """
    Invalid option :database_type at use: #{__MODULE__}, #{inspect(other)}
    valid options are:
      - :postgres
      - :mysql
      - :mssql
    """
  end
end
