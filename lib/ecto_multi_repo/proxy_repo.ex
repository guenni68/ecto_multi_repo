defmodule EctoMultiRepo.ProxyRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :ecto_multi_repo,
    adapter: Application.compile_env(:odata_repo, :adapter, Ecto.Adapters.Postgres)
end
