defmodule HelloPhoenix.Repo.Migrations.CreateReflection do
  use Ecto.Migration

  def change do
    create table(:reflections) do
      add :date, :string
      add :markdown, :string
      add :author, :string
      add :read_cnt, :integer, default: 0
      add :published, :boolean, default: false, null: false

      timestamps()
    end

  end
end
