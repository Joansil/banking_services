defmodule BankingService.Transactions.TransactionServer do
  use GenServer

  alias BankingService.Repo
  alias BankingService.Transactions.Transaction
  alias BankingService.Accounts.Account

  def start_link(attrs) do
    GenServer.start_link(__MODULE__, attrs, name: via_tuple(attrs["transaction_id"]))
  end

  def process_transaction(transaction_id) do
    GenServer.cast(via_tuple(transaction_id), :process)
  end

  def init(attrs) do
    {:ok, attrs}
  end

  def handle_cast(:process, attrs) do
    result =
      BankingService.Transactions.create_transaction(attrs)
      |> case do
        {:ok, transaction} ->
          {:ok, %{transaction: transaction}}

        {:error, reason} ->
          {:error, reason}
      end

    {:noreply, result}
  end

  defp via_tuple(transaction_id), do: {:via, Registry, {:transaction_registry, transaction_id}}
end
