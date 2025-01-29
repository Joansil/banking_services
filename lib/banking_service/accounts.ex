defmodule BankingService.Accounts do
  alias BankingService.Repo
  alias BankingService.Accounts.Account

  def create_account(attrs) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def get_account!(id), do: Repo.get!(Account, id)
end
