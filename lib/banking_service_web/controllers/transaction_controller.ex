defmodule BankingServiceWeb.TransactionController do
  use BankingServiceWeb, :controller

  alias BankingService.Transactions

  def create(conn, %{"transaction" => transaction_params}) do
    with {:ok, %{create_transaction: transaction}} <-
           Transactions.create_transaction(transaction_params) do
      conn
      |> put_status(:created)
      |> json(%{
        message: "Transaction processed successfully",
        transaction: transaction
      })
    else
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end
end
