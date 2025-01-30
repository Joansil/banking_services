ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(BankingService.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:ex_machina)

# Ecto.Adapters.SQL.Sandbox.mode(BankingService.Repo, {:shared, self()})

# Application.put_env(:ex_machina, :repo, BankingService.Repo)
