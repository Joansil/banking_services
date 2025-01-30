defmodule BankingService.Factory do
  use ExMachina.Ecto, repo: BankingService.Repo

  def account_factory do
    %BankingService.Accounts.Account{
      email: sequence(:email, &"user#{&1}@example.com"),
      name: sequence(:name, &"User #{&1}"),
      balance: Decimal.new("1000.00")
    }
  end
end
