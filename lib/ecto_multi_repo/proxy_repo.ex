defmodule EctoMultiRepo.ProxyRepo do
  @moduledoc false

  adapter = Application.compile_env(:ecto_multi_repo, :adapter, Ecto.Adapters.Postgres)

  use Ecto.Repo,
    otp_app: :ecto_multi_repo,
    adapter: adapter
end
