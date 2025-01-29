defmodule BankingServiceWeb.AccountController do
  use BankingServiceWeb, :controller

  alias BankingService.Accounts
  alias BankingService.Accounts.AccountServer

  def create(conn, %{"account" => account_params}) do
    case Accounts.create_account(account_params) do
      {:ok, account} ->
        # Inicia o GenServer para a conta logo após a criação
        case AccountServer.start_link(account.id) do
          {:ok, _pid} ->
            conn
            |> put_status(:created)
            |> json(account)

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Failed to start GenServer for account: #{reason}"})
        end

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: changeset})
    end
  end

  def show(conn, %{"id" => id}) do
    case AccountServer.get_balance(id) do
      {:error, :not_found} ->
        case AccountServer.start_link(id) do
          {:ok, _pid} ->
            balance = AccountServer.get_balance(id)
            account = Accounts.get_account!(id)

            conn
            |> put_status(:ok)
            |> json(%{
              id: account.id,
              email: account.email,
              name: account.name,
              balance: balance
            })

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Failed to restart GenServer: #{reason}"})
        end

      balance ->
        account = Accounts.get_account!(id)

        conn
        |> put_status(:ok)
        |> json(%{
          id: account.id,
          email: account.email,
          name: account.name,
          balance: balance
        })
    end
  end
end
