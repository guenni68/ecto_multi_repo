defmodule EctoMultiRepo.ProxyRepo.MSSQL do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :ecto_multi_repo,
    adapter: Ecto.Adapters.Tds
end
