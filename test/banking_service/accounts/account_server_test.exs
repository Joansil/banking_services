defmodule BankingService.Accounts.AccountServerTest do
  use BankingService.DataCase

  alias BankingService.Accounts.{Account, AccountServer}
  alias BankingService.Repo
  alias Decimal

  setup do
    {:ok, account} =
      Repo.insert(%Account{
        name: "Test User",
        email: "test@example.com",
        balance: Decimal.new("100.00")
      })

    {:ok, _pid} = AccountServer.start_link(account.id)
    {:ok, account: account}
  end

  test "retrieves correct balance", %{account: account} do
    assert AccountServer.get_balance(account.id) == Decimal.new("100.00")
  end

  test "updates balance correctly", %{account: account} do
    AccountServer.update_balance(account.id, Decimal.new("50.00"))
    assert AccountServer.get_balance(account.id) == Decimal.new("150.00")
  end

  test "handles concurrent balance updates", %{account: account} do
    tasks =
      for _ <- 1..10,
          do: Task.async(fn -> AccountServer.update_balance(account.id, Decimal.new("10.00")) end)

    Enum.each(tasks, &Task.await/1)
    assert AccountServer.get_balance(account.id) == Decimal.new("200.00")
  end
end
