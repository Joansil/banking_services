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
    Repo.transaction(fn ->
      case Repo.get(Account, account_id) do
        nil ->
          Repo.rollback("Account not found")

        account ->
          updated_balance = Decimal.add(account.balance, amount)
          changeset = Account.changeset(account, %{balance: updated_balance})

          case Repo.update(changeset) do
            {:ok, updated_account} -> {:ok, updated_account}
            {:error, reason} -> Repo.rollback(reason)
          end
      end
    end)
  end

  def transfer_balance(from_account_id, to_account_id, amount) do
    Repo.transaction(fn ->
      with from_account <- Repo.get(Account, from_account_id),
           _to_account <- Repo.get(Account, to_account_id),
           true <- Decimal.compare(from_account.balance, amount) != :lt,
           {:ok, _} <- update_balance(from_account_id, Decimal.negate(amount)),
           {:ok, updated_to_account} <- update_balance(to_account_id, amount) do
        {:ok, updated_to_account}
      else
        nil -> Repo.rollback("One or both accounts not found")
        false -> Repo.rollback("Insufficient funds")
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  def create_account(attrs) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end
end
