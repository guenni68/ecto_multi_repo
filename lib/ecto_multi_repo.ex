defmodule EctoMultiRepo do
  @moduledoc """
  Documentation for `EctoMultiRepo`.
  """

  defmacro __using__(_opts) do
    quote do
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
