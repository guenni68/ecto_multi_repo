defmodule EctoMultiRepo do
  @moduledoc """
  Documentation for `EctoMultiRepo`.
  """

  alias EctoMultiRepo.Generator

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

    delegates = Generator.generate_delegates()

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

      unquote(delegates)
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
