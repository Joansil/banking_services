defmodule BankingService.Accounts do
  alias BankingService.Repo
  alias BankingService.Accounts.Account
  alias BankingService.Accounts.AccountServer
  alias Decimal

  def get_account!(id) do
    Repo.get!(Account, id)
  end

  def get_balance(account_id) do
    AccountServer.get_balance(account_id)
  end

  def update_balance(account_id, amount) do
    AccountServer.update_balance(account_id, amount)
  end

  def create_account(attrs) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end
end
