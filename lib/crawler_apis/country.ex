defmodule CrawlerApis.Country do
  use Ecto.Schema
  import Ecto.Changeset

  schema "countries" do
    field :name, :string
    many_to_many :movies, CrawlerApis.Movie, join_through: "movies_countries"

    timestamps()
  end

  @doc false
  def changeset(country, attrs) do
    country
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
