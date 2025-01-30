defmodule BankingService.Transactions.TransactionsIntegrationTest do
  use ExUnit.Case, async: false
  alias BankingService.Transactions
  alias BankingService.Accounts.Account
  alias BankingService.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "concurrent transactions should not cause race conditions" do
    from_account = Repo.insert!(%Account{balance: Decimal.new("200.00")})
    to_account = Repo.insert!(%Account{balance: Decimal.new("100.00")})

    attrs = %{
      "amount" => "50.00",
      "account_from_id" => from_account.id,
      "account_to_id" => to_account.id
    }

    tasks =
      for _ <- 1..10 do
        Task.async(fn ->
          Transactions.create_transaction(attrs)
        end)
      end

    results = Enum.map(tasks, &Task.await/1)

    assert Enum.all?(results, fn
             {:ok, _transaction} -> true
             {:error, _reason} -> false
           end)
  end

  test "database integrity is maintained after multiple transactions" do
    from_account = Repo.insert!(%Account{balance: Decimal.new("200.00")})
    to_account = Repo.insert!(%Account{balance: Decimal.new("100.00")})

    attrs = %{
      "amount" => "50.00",
      "account_from_id" => from_account.id,
      "account_to_id" => to_account.id
    }

    Enum.each(1..10, fn _ ->
      Transactions.create_transaction(attrs)
    end)

    from_account = Repo.get(Account, from_account.id)
    to_account = Repo.get(Account, to_account.id)

    assert Decimal.equal?(from_account.balance, Decimal.new("150.00"))
    assert Decimal.equal?(to_account.balance, Decimal.new("150.00"))
  end
end
