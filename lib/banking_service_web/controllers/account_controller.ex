defmodule BankingServiceWeb.AccountController do
  use BankingServiceWeb, :controller

  alias BankingService.Accounts

  def create(conn, %{"account" => account_params}) do
    case Accounts.create_account(account_params) do
      {:ok, account} ->
        conn
        |> put_status(:created)
        |> json(account)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: changeset})
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    conn
    |> put_status(:ok)
    |> json(%{
      id: account.id,
      email: account.email,
      name: account.name,
      balance: account.balance
    })
  end
end
