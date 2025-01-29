defmodule BankingService.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount, :decimal
      add :status, :string
      add :account_from_id, references(:accounts, on_delete: :nothing, type: :binary_id)
      add :account_to_id, references(:accounts, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:account_from_id])
    create index(:transactions, [:account_to_id])
  end
end
