defmodule CrawlerApis.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    many_to_many :movies, CrawlerApis.Movie, join_through: "movies_categories"

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])

    # |> validate_required([:name])
  end
end
