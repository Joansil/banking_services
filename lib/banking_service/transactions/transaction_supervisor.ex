defmodule BankingService.Transactions.TransactionSupervisor do
  use Supervisor

  alias BankingService.Transactions.TransactionServer

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    children = [
      %{
        id: TransactionServer,
        start: {TransactionServer, :start_link, []},
        type: :worker,
        restart: :temporary
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
