defmodule CrawlerApis.Repo.Migrations.CreateMoviesCategories do
  use Ecto.Migration

  def change do
    create table(:movies_categories) do
      add :movie_id, references(:movies)
      add :category_id, references(:categories)
    end

    create unique_index(:movies_categories, [:movie_id, :category_id])
  end
end
