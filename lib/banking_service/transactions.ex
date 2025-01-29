defmodule BankingService.Transactions do

  alias BankingService.Accounts.Account
  alias BankingService.Repo
  alias BankingService.Transactions.Transaction
  alias BankingService.Transactions.TransactionServer

  import Ecto.Query
  import Ecto.Multi

  def create_transaction(attrs) do
    IO.inspect(attrs, label: "Received attrs")

    case attrs do
      %{"amount" => amount, "account_from_id" => from_id, "account_to_id" => to_id} = transaction
      when is_binary(amount) ->
        IO.inspect(amount, label: "Amount extracted")

        decimal_amount = Decimal.new(amount)
        transaction = Map.put(transaction, "amount", decimal_amount)

        BankingService.Repo.transaction(fn ->
          with {:ok, from_account} <- get_account(from_id),
               {:ok, to_account} <- get_account(to_id),
               true <- valid_balance?(from_account, decimal_amount),
               {:ok, transaction} <- insert_transaction(transaction),
               {:ok, _updated_from} <-
                 update_balance(from_account, Decimal.negate(decimal_amount)),
               {:ok, _updated_to} <- update_balance(to_account, decimal_amount) do
            transaction
          else
            error -> Repo.rollback(error)
          end
        end)
        |> case do
          {:ok, transaction} -> {:ok, transaction}
          {:error, reason} -> {:error, reason}
        end

      _ ->
        {:error, "Invalid parameters"}
    end
  end

  def update_transaction_status(%Transaction{} = transaction, status) do
    transaction
    |> Ecto.Changeset.change(status: status)
    |> Repo.update()
  end

  # Métodos auxiliares para checar saldo e atualizar as contas
  defp get_account(account_id) do
    case Repo.get(Account, account_id) do
      nil -> {:error, "Account not found"}
      account -> {:ok, account}
    end
  end

  defp valid_balance?(account, amount) do
    Decimal.compare(account.balance, amount) != :lt
  end

  defp insert_transaction(attrs) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  defp update_balance(account, amount) do
    new_balance = Decimal.add(account.balance, amount)

    account
    |> Ecto.Changeset.change(%{balance: new_balance})
    |> Repo.update()
  end

  defp check_balance(%{
         "account_from_id" => account_id,
         "account_to_id" => _to_id,
         "amount" => amount,
         "status" => _status
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
