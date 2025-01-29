defmodule BankingService.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
     create table(:accounts, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :email, :string
      add :name, :string
      add :balance, :decimal
      timestamps(type: :utc_datetime)
    end

    create unique_index(:accounts, [:email])
  end
end
