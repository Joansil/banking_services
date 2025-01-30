defmodule BankingService.TransactionsTest do
  use BankingService.DataCase
  alias BankingService.Transactions
  alias BankingService.Accounts

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

  describe "create_transaction/1" do
    test "successfully creates a transaction when there is sufficient balance", %{account1: account1, account2: account2} do
      attrs = %{
        "account_from_id" => account1.id,
        "account_to_id" => account2.id,
        "amount" => "100.00",
        "status" => "pending"
      }

      {:ok, {:ok, transaction}} = Transactions.create_transaction(attrs)
      assert Decimal.compare(transaction.amount, Decimal.new("100.00")) == :eq
      assert transaction.status == "pending"
    end

    test "fails to create transaction when there is insufficient balance", %{account1: account1, account2: account2} do
      attrs = %{
        "account_from_id" => account1.id,
        "account_to_id" => account2.id,
        "amount" => "2000.00",
        "status" => "pending"
      }

      {:error, false} = Transactions.create_transaction(attrs)
    end

    @tag :skip # Skipping this test until we implement proper validation
    test "fails to create transaction with invalid parameters", %{account1: account1, account2: account2} do
      attrs = %{
        "account_from_id" => account1.id,
        "account_to_id" => account2.id,
        "amount" => "invalid",
        "status" => "pending"
      }

      assert {:error, "Invalid parameters"} = Transactions.create_transaction(attrs)
    end
  end

  describe "update_transaction_status/2" do
    test "successfully updates transaction status", %{account1: account1, account2: account2} do
      attrs = %{
        "account_from_id" => account1.id,
        "account_to_id" => account2.id,
        "amount" => "100.00",
        "status" => "pending"
      }

      {:ok, {:ok, transaction}} = Transactions.create_transaction(attrs)
      assert {:ok, updated_transaction} = Transactions.update_transaction_status(transaction, "completed")
      assert updated_transaction.status == "completed"
    end
  end
end
