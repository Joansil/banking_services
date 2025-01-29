defmodule BankingService.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: [:id, :name, :email, :balance, :inserted_at, :updated_at]}

  schema "accounts" do
    field :balance, :decimal
    field :email, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :name, :balance])
    |> validate_required([:email, :name, :balance])
    |> unique_constraint(:email)
  end
end
