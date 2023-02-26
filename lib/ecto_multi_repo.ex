defmodule EctoMultiRepo do
  @moduledoc """
  Documentation for `EctoMultiRepo`.
  """

  defmacro __using__(_opts) do
    quote do
      alias EctoMultiRepo.ProxySupervisor

      defdelegate start_repo(
                    id \\ UUID.uuid1(),
                    hostname,
                    port,
                    database,
                    username,
                    password,
                    pool_size \\ 10,
                    timeout \\ :timer.minutes(10)
                  ),
                  to: ProxySupervisor,
                  as: :start_proxy
    end
  end
end
