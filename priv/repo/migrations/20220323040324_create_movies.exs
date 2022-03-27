defmodule CrawlerApis.Repo.Migrations.CreateMovies do
  use Ecto.Migration

  def change do
    create table(:movies) do
      add :title, :string
      add :number_of_episode, :integer
      add :thumnail, :string
      add :year, :integer
      add :full_series, :boolean, default: false, null: false
      add :link, :string

      timestamps()
    end
  end
end
