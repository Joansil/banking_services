defmodule BankingService.Transactions do
  alias BankingService.Repo
  alias BankingService.Transactions.Transaction
  alias BankingService.Accounts.Account

  def create_transaction(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:check_balance, fn _repo, _changes ->
      check_balance(attrs)
    end)
    |> Ecto.Multi.insert(:transaction, Transaction.changeset(%Transaction{}, attrs))
    |> Ecto.Multi.run(:update_balances, fn repo, %{transaction: transaction} ->
      update_balances(repo, transaction)
    end)
    |> Repo.transaction()
  end

  defp check_balance(%{account_from_id: account_id, amount: amount}) do
    account = Repo.get!(Account, account_id)

    if account.balance >= amount do
      {:ok, account}
    else
      {:error, "Insufficient balance"}
    end
  end

  defp update_balances(repo, %Transaction{account_from_id: from_id, account_to_id: to_id, amount: amount}) do
    from_account = Repo.get!(Account, from_id)
    to_account = Repo.get!(Account, to_id)

    from_account = Ecto.Changeset.change(from_account, balance: from_account.balance - amount)
    to_account = Ecto.Changeset.change(to_account, balance: to_account.balance + amount)

    repo.update!(from_account)
    repo.update!(to_account)

    {:ok, %{from_account: from_account, to_account: to_account}}
  end
end
