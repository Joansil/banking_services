defmodule BankingService.Transactions do
  alias BankingService.Repo
  alias BankingService.Transactions.Transaction
  alias BankingService.Accounts.Account
  alias Ecto.Multi

  def create_transaction(attrs) do
    attrs =
      attrs
      |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
      |> Map.put(:amount, Decimal.new(attrs["amount"]))

    Ecto.Multi.new()
    |> Ecto.Multi.run(:check_balance, fn _repo, _changes ->
      check_balance(attrs)
    end)
    |> Ecto.Multi.run(:create_transaction, fn repo, %{check_balance: account} ->
      %Transaction{}
      |> Transaction.changeset(attrs)
      |> repo.insert()
    end)
    |> Ecto.Multi.run(:update_balances, fn repo, %{create_transaction: transaction} ->
      # Extraindo as contas de origem e destino para usar na atualização
      from_account = Repo.get!(Account, transaction.account_from_id)
      to_account = Repo.get!(Account, transaction.account_to_id)

      # Chamando a função para atualizar os saldos com as contas
      update_balances(from_account, to_account, transaction.amount)
    end)
    |> Ecto.Multi.run(:update_transaction_status, fn repo, %{create_transaction: transaction} ->
      # Atualizando o status da transação para "completed"
      transaction
      |> Transaction.changeset(%{status: "completed"})
      |> repo.update()
    end)
    |> Repo.transaction()
  end

  defp check_balance(%{
         account_from_id: account_id,
         account_to_id: _to_id,
         amount: amount,
         status: _status
       }) do
    account = Repo.get!(Account, account_id)
    IO.inspect(account, label: "Account")

    if Decimal.compare(account.balance, amount) in [:gt, :eq] do
      {:ok, account}
    else
      {:error, "Insufficient balance"}
    end
  end

  defp update_balances(from_account, to_account, amount) do
    IO.inspect(from_account, label: "From Account")
    IO.inspect(to_account, label: "To Account")

    from_account_changeset =
      from_account
      |> Ecto.Changeset.change(balance: Decimal.sub(from_account.balance, amount))

    to_account_changeset =
      to_account
      |> Ecto.Changeset.change(balance: Decimal.add(to_account.balance, amount))

    Multi.new()
    |> Multi.update(:from_account, from_account_changeset)
    |> Multi.update(:to_account, to_account_changeset)
    |> Repo.transaction()
  end
end
