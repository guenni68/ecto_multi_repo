defmodule EctoMultiRepo.ProxyRepo.Postgres do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :ecto_multi_repo,
    adapter: Ecto.Adapters.Postgres
end
