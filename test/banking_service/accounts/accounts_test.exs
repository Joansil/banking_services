defmodule BankingService.AccountsTest do
  use BankingService.DataCase

  alias BankingService.Accounts
  alias BankingService.Repo
  alias BankingService.Accounts.Account
  alias Decimal

  setup do
    {:ok, from_account} =
      Repo.insert(%Account{
        name: "Sender",
        email: "sender@example.com",
        balance: Decimal.new("500.00")
      })

    {:ok, to_account} =
      Repo.insert(%Account{
        name: "Receiver",
        email: "receiver@example.com",
        balance: Decimal.new("100.00")
      })

    {:ok, from_account: from_account, to_account: to_account}
  end

  test "transfers balance successfully", %{from_account: from_account, to_account: to_account} do
    assert {:ok, _updated_to_account} =
             Accounts.transfer_balance(from_account.id, to_account.id, Decimal.new("200.00"))

    assert Repo.get!(Account, from_account.id).balance == Decimal.new("300.00")
    assert Repo.get!(Account, to_account.id).balance == Decimal.new("300.00")
  end

  test "fails when insufficient funds", %{from_account: from_account, to_account: to_account} do
    assert {:error, "Insufficient funds"} =
             Accounts.transfer_balance(from_account.id, to_account.id, Decimal.new("600.00"))
  end

  test "handles concurrent transfers correctly", %{
    from_account: from_account,
    to_account: to_account
  } do
    tasks =
      for _ <- 1..10,
          do:
            Task.async(fn ->
              Accounts.transfer_balance(from_account.id, to_account.id, Decimal.new("10.00"))
            end)

    Enum.each(tasks, &Task.await/1)

    assert Repo.get!(Account, from_account.id).balance == Decimal.new("400.00")
    assert Repo.get!(Account, to_account.id).balance == Decimal.new("200.00")
  end
end
