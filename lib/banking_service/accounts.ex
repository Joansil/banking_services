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
    account = Repo.get(Account, account_id)

    if account do
      changeset = Account.changeset(account, %{balance: Decimal.add(account.balance, amount)})

      case Repo.update(changeset) do
        {:ok, updated_account} -> {:ok, updated_account}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, "Account not found"}
    end
  end

  def create_account(attrs) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end
end
