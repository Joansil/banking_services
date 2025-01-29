defmodule BankingServiceWeb.TransactionController do
  use BankingServiceWeb, :controller
  alias BankingService.Transactions

  def create(conn, %{"transaction" => transaction_params}) do
    with {:ok, transaction} <- Transactions.create_transaction(transaction_params),
         {:ok, transaction} <- Transactions.update_transaction_status(transaction, "completed") do
      conn
      |> put_status(:created)
      |> json(%{message: "Transaction completed successfully", transaction: transaction})
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Transaction failed", details: changeset_errors(changeset)})

      _ ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "An unexpected error occurred"})
    end
  end

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc -> String.replace(acc, "%{#{key}}", to_string(value)) end)
    end)
  end
end
