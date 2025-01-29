defmodule BankingService.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :amount, :decimal, null: false
      add :status, :string, null: false
      add :account_from_id, references(:accounts, type: :uuid, on_delete: :nothing), null: false
      add :account_to_id, references(:accounts, type: :uuid, on_delete: :nothing), null: false
      timestamps()
    end

    create constraint(:transactions, :amount_positive, check: "amount > 0")
    create index(:transactions, [:account_from_id])
    create index(:transactions, [:account_to_id])
  end
end
