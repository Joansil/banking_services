defmodule BankingServiceWeb.AccountController do
  use BankingServiceWeb, :controller

  alias BankingService.Accounts
  alias BankingService.Accounts.AccountServer
  alias BankingService.Transactions

  def create(conn, %{"account" => account_params}) do
    case Accounts.create_account(account_params) do
      {:ok, account} ->
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
        errors = transverse_errors(changeset)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: errors})
    end
  end

  defp transverse_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&translate_error/1)
    |> Enum.map(fn {field, messages} ->
      %{field: field, messages: Enum.join(messages, ", ")}
    end)
  end

  defp translate_error({msg, _opts}) do
    case msg do
      "has already been taken" -> "This email is already registered."
      "can't be blank" -> "This field is required."
      "is invalid" -> "This value is invalid."
      _ -> msg
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

  def update_balance(conn, %{"account_id" => account_id, "amount" => amount}) do
    case Ecto.UUID.cast(account_id) do
      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid account_id format"})

      {:ok, uuid_account_id} ->
        case Decimal.new(amount) do
          %Decimal{} = decimal_amount ->
            case Accounts.update_balance(uuid_account_id, decimal_amount) do
              {:ok, updated_account} ->
                Transactions.create_transaction(%{
                  account_id: uuid_account_id,
                  amount: decimal_amount,
                  status: "completed"
                })

                conn
                |> put_status(:ok)
                |> json(%{
                  message: "Account balance updated successfully",
                  account: Map.from_struct(updated_account)
                })

              {:error, reason} ->
                conn
                |> put_status(:unprocessable_entity)
                |> json(%{error: "Failed to update account balance", details: reason})
            end

          _error ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Invalid amount", details: amount})
        end
    end
  end

  # defp update_balance_and_record_transaction(account_id, amount) do
  #   Ecto.Multi.new()
  #   |> Ecto.Multi.update(:update_balance, Accounts.update_balance(account_id, amount))
  #   |> Ecto.Multi.insert(:create_transaction, Transactions.create_transaction(account_id, amount))
  #   |> Repo.transaction()
  #   |> case do
  #     {:ok, %{update_balance: account, create_transaction: transaction}} ->
  #       {:ok, account, transaction}

  #     {:error, step, reason, _changes_so_far} ->
  #       {:error, "Failed to process the transaction due to: #{step} - #{reason}"}
  #   end
  # end
end
