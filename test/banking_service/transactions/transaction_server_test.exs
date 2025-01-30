defmodule BankingService.Transactions.TransactionServerTest do
  use BankingService.DataCase
  alias BankingService.Transactions.TransactionServer
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

  describe "TransactionServer" do
    test "starts server correctly", %{account1: account1, account2: account2} do
      transaction_id = Ecto.UUID.generate()
      attrs = %{
        "transaction_id" => transaction_id,
        "account_from_id" => account1.id,
        "account_to_id" => account2.id,
        "amount" => "100.00",
        "status" => "pending"
      }

      assert {:ok, _pid} = TransactionServer.start_link(attrs)
    end

    test "successfully processes transaction", %{account1: account1, account2: account2} do
      transaction_id = Ecto.UUID.generate()
      attrs = %{
        "transaction_id" => transaction_id,
        "account_from_id" => account1.id,
        "account_to_id" => account2.id,
        "amount" => "100.00",
        "status" => "pending"
      }

      {:ok, _pid} = TransactionServer.start_link(attrs)
      TransactionServer.process_transaction(transaction_id)
      
      :timer.sleep(100)

      updated_account1 = Repo.get!(Accounts.Account, account1.id)
      updated_account2 = Repo.get!(Accounts.Account, account2.id)

      assert Decimal.compare(updated_account1.balance, Decimal.new("900.00")) == :eq
      assert Decimal.compare(updated_account2.balance, Decimal.new("600.00")) == :eq
    end
  end
end
