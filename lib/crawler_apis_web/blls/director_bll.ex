defmodule CrawlerApisWeb.Bill.Director do
  alias CrawlerApis.{Director, Repo}
  import Ecto.Query

  @drop_values [:inserted_at, :updated_at, :movies, :__meta__]

  def get_directors() do
    Repo.all(from(m in Director))
    |> Enum.map(fn x ->
      Map.drop(x, @drop_values) |> Map.from_struct()
    end)
  end
end
