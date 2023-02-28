defmodule EctoMultiRepo.Proxy do
  @moduledoc false

  alias EctoMultiRepo.{
    Watchdog,
    ProcessRegistry,
    Generator
  }

  use GenStateMachine, restart: :temporary
  require Generator

  def start_link(%{id: id} = arg) do
    GenStateMachine.start_link(__MODULE__, arg, name: via_tuple(id))
  end

  Generator.generate_api_calls()

  defp via_tuple(id) do
    ProcessRegistry.via_tuple({__MODULE__, id})
  end

  @impl GenStateMachine
  def init(arg) do
    actions = [{:next_event, :internal, arg}]
    {:ok, :connecting, nil, actions}
  end

  @impl GenStateMachine
  def handle_event(
        :internal,
        %{timeout: timout, repo_module: repo_module} = arg,
        :connecting,
        nil
      ) do
    params =
      arg
      |> Map.drop([:id, :timeout, :repo_module])
      |> Map.put(:name, nil)
      |> Enum.to_list()

    watchdog = Watchdog.start_watching(timout)
    {:ok, repo} = repo_module.start_link(params)
    repo_module.put_dynamic_repo(repo)

    {:next_state, :running, %{watchdog: watchdog, repo_module: repo_module}}
  end
end
