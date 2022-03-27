defmodule CrawlerApisWeb.Bill.Country do
  alias CrawlerApis.{Country, Repo}
  import Ecto.Query

  @drop_values [:inserted_at, :updated_at, :movies, :__meta__]

  def get_countries() do
    Repo.all(from(m in Country))
    |> Enum.map(fn x ->
      Map.drop(x, @drop_values) |> Map.from_struct()
    end)
  end
end
