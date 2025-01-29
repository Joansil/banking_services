defmodule BankingService.Accounts.AccountServer do
  use GenServer

  alias BankingService.Repo
  alias BankingService.Accounts.Account
  alias Decimal

  def start_link(account_id) do
    GenServer.start_link(__MODULE__, account_id, name: via_tuple(account_id))
  end

  def get_balance(account_id) do
    case GenServer.whereis(via_tuple(account_id)) do
      nil ->
        {:error, :not_found}

      pid ->
        GenServer.call(pid, :get_balance)
    end
  end

  def update_balance(account_id, amount) do
    GenServer.cast(via_tuple(account_id), {:update_balance, amount})
  end

  def init(account_id) do
    {:ok, account_id}
  end

  def handle_call(:get_balance, _from, account_id) do
    account = Repo.get!(Account, account_id)
    {:reply, account.balance, account_id}
  end

  def handle_cast({:update_balance, amount}, account_id) do
    account = Repo.get!(Account, account_id)

    new_balance = Decimal.add(account.balance, amount)

    changeset =
      account
      |> Ecto.Changeset.change(balance: new_balance)

    Repo.update!(changeset)
    {:noreply, account_id}
  end

  defp via_tuple(account_id), do: {:via, Registry, {:account_registry, account_id}}
end
