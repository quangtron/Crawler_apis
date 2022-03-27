defmodule CrawlerApis.Repo.Migrations.CreateMoviesCountries do
  use Ecto.Migration

  def change do
    create table(:movies_countries) do
      add :movie_id, references(:movies)
      add :country_id, references(:countries)
    end

    create unique_index(:movies_countries, [:movie_id, :country_id])
  end
end
