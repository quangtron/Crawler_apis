defmodule CrawlerApis.Director do
  use Ecto.Schema
  import Ecto.Changeset

  schema "directors" do
    field :name, :string
    many_to_many :movies, CrawlerApis.Movie, join_through: "movies_directors"

    timestamps()
  end

  @doc false
  def changeset(director, attrs) do
    director
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
