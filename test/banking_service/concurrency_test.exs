defmodule BankingService.ConcurrencyTest do
  use BankingService.DataCase
  import BankingService.Factory
  alias BankingService.Accounts
  alias BankingService.Transactions
  alias BankingService.Repo

  describe "concurrent operations" do
    test "handles concurrent balance updates correctly" do
      account_from = insert(:account, balance: Decimal.new("500.00"))
      account_to = insert(:account, balance: Decimal.new("200.00"))

      # Number of concurrent transactions to try
      num_transactions = 5
      amount_per_transaction = "50.00"

      # Create multiple concurrent transactions
      tasks = for _i <- 1..num_transactions do
        Task.async(fn ->
          Transactions.create_transaction(%{
            "account_from_id" => account_from.id,
            "account_to_id" => account_to.id,
            "amount" => amount_per_transaction,
            "status" => "pending"
          })
        end)
      end

      # Wait for all transactions to complete
      results = Task.await_many(tasks, 5000)

      # Count successful transactions
      successful_transactions = Enum.count(results, fn
        {:ok, {:ok, _}} -> true
        _ -> false
      end)

      # Reload accounts to get final balances
      updated_account_from = Repo.get!(Accounts.Account, account_from.id)
      updated_account_to = Repo.get!(Accounts.Account, account_to.id)

      # Calculate expected balances
      total_transferred = Decimal.mult(
        Decimal.new(amount_per_transaction),
        Decimal.new(successful_transactions)
      )

      expected_from_balance = Decimal.sub(
        Decimal.new("500.00"),
        total_transferred
      )

      expected_to_balance = Decimal.add(
        Decimal.new("200.00"),
        total_transferred
      )

      # Assert final balances match expectations
      assert Decimal.compare(updated_account_from.balance, expected_from_balance) == :eq
      assert Decimal.compare(updated_account_to.balance, expected_to_balance) == :eq
    end

    test "prevents double-spending with concurrent transactions" do
      # Create account with exactly enough balance for one transaction
      account_from = insert(:account, balance: Decimal.new("100.00"))
      account_to = insert(:account, balance: Decimal.new("100.00"))

      # Try to execute two concurrent transactions of 100.00 each
      tasks = for _i <- 1..2 do
        Task.async(fn ->
          Transactions.create_transaction(%{
            "account_from_id" => account_from.id,
            "account_to_id" => account_to.id,
            "amount" => "100.00",
            "status" => "pending"
          })
        end)
      end

      # Wait for both transactions to complete
      results = Task.await_many(tasks, 5000)

      # Only one transaction should succeed
      successful_transactions = Enum.count(results, fn
        {:ok, {:ok, _}} -> true
        _ -> false
      end)

      assert successful_transactions == 1

      # Verify final balances
      updated_account_from = Repo.get!(Accounts.Account, account_from.id)
      updated_account_to = Repo.get!(Accounts.Account, account_to.id)

      assert Decimal.compare(updated_account_from.balance, Decimal.new("0.00")) == :eq
      assert Decimal.compare(updated_account_to.balance, Decimal.new("200.00")) == :eq
    end
  end
end
