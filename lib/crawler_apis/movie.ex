defmodule CrawlerApis.Movie do
  use Ecto.Schema
  import Ecto.Changeset

  schema "movies" do
    field :full_series, :boolean, default: false
    field :link, :string
    field :number_of_episode, :integer
    field :thumnail, :string
    field :title, :string
    field :year, :integer
    many_to_many :categories, CrawlerApis.Category, join_through: "movies_categories"
    many_to_many :countries, CrawlerApis.Country, join_through: "movies_countries"
    many_to_many :directors, CrawlerApis.Director, join_through: "movies_directors"

    timestamps()
  end

  @doc false
  def changeset(crawler_api_web, attrs) do
    crawler_api_web
    |> cast(attrs, [:title, :number_of_episode, :thumnail, :year, :full_series, :link])
    |> set_title_if_blank()

    # |> set_current_time()

    # |> validate_required([:title])
  end

  defp set_title_if_blank(changeset) do
    title = get_field(changeset, :title)

    if is_nil(title) do
      put_change(changeset, :title, "Updating...")
    else
      changeset
    end
  end

  # defp set_current_time(changeset) do
  #   now = NaiveDateTime.local_now()
  #   inserted_at = get_field(changeset, :inserted_at)
  #   updated_at = get_field(changeset, :updated_at)

  #   cond do
  #     is_nil(inserted_at) ->
  #       put_change(changeset, :inserted_at, now)

  #     is_nil(updated_at) ->
  #       put_change(changeset, :updated_at, now)

  #     true ->
  #       changeset
  #   end
  # end
end
