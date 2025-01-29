defmodule BankingService.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder,
           only: [
             :id,
             :amount,
             :status,
             :account_from_id,
             :account_to_id,
             :inserted_at,
             :updated_at
           ]}

  schema "transactions" do
    field :amount, :decimal
    field :status, :string
    belongs_to :account_from, BankingService.Accounts.Account, type: :binary_id
    belongs_to :account_to, BankingService.Accounts.Account, type: :binary_id
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:account_from_id, :account_to_id, :amount, :status])
    |> validate_required([:account_from_id, :account_to_id, :amount, :status])
    |> foreign_key_constraint(:account_from_id)
    |> foreign_key_constraint(:account_to_id)
  end
end
