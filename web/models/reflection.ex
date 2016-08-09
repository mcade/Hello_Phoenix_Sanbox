defmodule HelloPhoenix.Reflection do
  use HelloPhoenix.Web, :model

  schema "reflections" do
    field :date, :string
    field :markdown, :string
    field :author, :string
    field :read_cnt, :integer, default: 0
    field :published, :boolean, default: false

    timestamps()
  end
  
  @required_fields ~w(date author markdown published)
  @optional_fields ~w()

  @doc """
  Builds a changeset based on the `model` and `params`.
  """
  
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
