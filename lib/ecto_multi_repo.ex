defmodule EctoMultiRepo do
  @moduledoc """
  Documentation for `EctoMultiRepo`.
  """

  alias EctoMultiRepo.{
    ProxySupervisor,
    Proxy,
    Generator
  }

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

    call_timeout =
      opts
      |> Keyword.get(:call_timeout, :timer.seconds(15))

    delegates = Generator.generate_delegates(call_timeout)

    quote do
      def start_repo(
            id \\ UUID.uuid1(),
            hostname,
            port,
            database,
            username,
            password,
            pool_size \\ 3
          ) do
        ProxySupervisor.start_proxy(
          id,
          hostname,
          port,
          database,
          username,
          password,
          pool_size,
          unquote(call_timeout),
          unquote(repo_module)
        )
      end

      defdelegate noop(id), to: Proxy

      unquote(delegates)
    end
  end

  defp choose_repo_module(nil) do
    raise """
    Missing option :database_type at use: #{__MODULE__}
    valid options are:
      - :postgres
      - :mysql
      - :mssql
    """
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
