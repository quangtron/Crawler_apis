defmodule CrawlerApisWeb.Bill.Category do
  alias CrawlerApis.{Category, Repo}
  import Ecto.Query

  @drop_values [:inserted_at, :updated_at, :movies, :__meta__]

  def get_categories() do
    Repo.all(from(m in Category))
    |> Enum.map(fn x ->
      Map.drop(x, @drop_values) |> Map.from_struct()
    end)
  end
end
