defmodule BankingService.ConcurrentTransactionsTest do
  use BankingService.DataCase
  alias BankingService.Transactions
  alias BankingService.Accounts
  alias BankingService.Repo

  setup do
    {:ok, account1} = Accounts.create_account(%{
      "email" => "sender@example.com",
      "name" => "Sender",
      "balance" => "1000.00"
    })

    {:ok, account2} = Accounts.create_account(%{
      "email" => "receiver@example.com",
      "name" => "Receiver",
      "balance" => "500.00"
    })

    {:ok, %{account1: account1, account2: account2}}
  end

  describe "concurrent transactions" do
    test "processes multiple concurrent transactions maintaining consistency", %{account1: account1, account2: account2} do
      tasks = for _ <- 1..10 do
        Task.async(fn ->
          Transactions.create_transaction(%{
            "account_from_id" => account1.id,
            "account_to_id" => account2.id,
            "amount" => "50.00",
            "status" => "pending"
          })
        end)
      end

      results = Task.await_many(tasks, 5000)

      successful_transactions = Enum.count(results, fn
        {:ok, {:ok, _}} -> true
        _ -> false
      end)

      updated_account1 = Repo.get!(Accounts.Account, account1.id)
      updated_account2 = Repo.get!(Accounts.Account, account2.id)

      expected_account1_balance = Decimal.sub(
        Decimal.new("1000.00"),
        Decimal.mult(Decimal.new("50.00"), Decimal.new(successful_transactions))
      )
      expected_account2_balance = Decimal.add(
        Decimal.new("500.00"),
        Decimal.mult(Decimal.new("50.00"), Decimal.new(successful_transactions))
      )

      assert Decimal.compare(updated_account1.balance, expected_account1_balance) == :eq
      assert Decimal.compare(updated_account2.balance, expected_account2_balance) == :eq
    end

    test "optimistic lock prevents race conditions", %{account1: account1, account2: account2} do
      # Simulate concurrent updates to the same account
      task1 = Task.async(fn ->
        Transactions.create_transaction(%{
          "account_from_id" => account1.id,
          "account_to_id" => account2.id,
          "amount" => "600.00",
          "status" => "pending"
        })
      end)

      task2 = Task.async(fn ->
        Transactions.create_transaction(%{
          "account_from_id" => account1.id,
          "account_to_id" => account2.id,
          "amount" => "600.00",
          "status" => "pending"
        })
      end)

      # Only one transaction should succeed
      results = [Task.await(task1), Task.await(task2)]
      successful_transactions = Enum.count(results, fn
        {:ok, {:ok, _}} -> true
        _ -> false
      end)

      assert successful_transactions == 1
    end
  end
end
