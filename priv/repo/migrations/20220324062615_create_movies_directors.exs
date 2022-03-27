defmodule CrawlerApis.Repo.Migrations.CreateMoviesDirectors do
  use Ecto.Migration

  def change do
    create table(:movies_directors) do
      add :movie_id, references(:movies)
      add :director_id, references(:directors)
    end

    create unique_index(:movies_directors, [:movie_id, :director_id])
  end
end
