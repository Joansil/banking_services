defmodule BankingService.Repo do
  use Ecto.Repo,
    otp_app: :banking_service,
    adapter: Ecto.Adapters.Postgres
end
