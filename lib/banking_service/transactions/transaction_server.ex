defmodule BankingService.Transactions.TransactionServer do
  use GenServer

  alias BankingService.Repo

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
      Repo.transaction(fn ->
        BankingService.Transactions.create_transaction(attrs)
      end)
      |> case do
        {:ok, {:ok, transaction}} ->
          {:ok, %{transaction: transaction}}

        {:ok, {:error, reason}} ->
          {:error, reason}

        {:error, reason} ->
          {:error, reason}
      end

    {:noreply, result}
  end

  def via_tuple(transaction_id), do: {:via, Registry, {:transaction_registry, transaction_id}}
end
