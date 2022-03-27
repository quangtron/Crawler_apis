defmodule CrawlerApisWeb.Bill.Movie do
  alias CrawlerApis.{Movie, Repo}
  import Ecto.Query

  @drop_values [:__meta__, :inserted_at, :updated_at]
  @offset_default "0"
  @limit_default "10"

  def get_movies_by_query(query) do
    IO.inspect(query)
    offset = String.to_integer(query["offset"] || @offset_default)
    limit = String.to_integer(query["limit"] || @limit_default)

    db_query =
      Movie
      |> query_by_category(query["category"])
      |> query_by_country(query["country"])
      |> query_by_director(query["director"])
      |> select([m], %{data: m, total: count("*") |> over()})

    movies =
      Repo.all(
        from(
          db_query,
          offset: ^offset,
          limit: ^limit,
          preload: [:categories, :directors, :countries]
        )
      )

    total = Enum.at(movies, 0).total

    movies =
      movies
      |> Enum.map(fn x ->
        temp = Map.drop(x.data, @drop_values)

        Map.put(
          temp,
          :categories,
          Enum.map(temp.categories, fn y ->
            Map.drop(y, [:movies] ++ @drop_values) |> Map.from_struct()
          end)
        )
        |> Map.put(
          :directors,
          Enum.map(temp.directors, fn y ->
            Map.drop(y, [:movies] ++ @drop_values) |> Map.from_struct()
          end)
        )
        |> Map.put(
          :countries,
          Enum.map(temp.countries, fn y ->
            Map.drop(y, [:movies] ++ @drop_values) |> Map.from_struct()
          end)
        )
        |> Map.from_struct()
      end)

    %{data: movies, offset: offset, limit: limit, total: total}
  end

  defp query_by_category(query, filters) when is_map(filters) do
    if filters["id"] do
      join(query, :inner, [m], c in assoc(m, :categories))
      |> where([..., c], c.id == ^String.to_integer(filters["id"]))
    else
      query
    end
  end

  defp query_by_category(query, _), do: query

  defp query_by_country(query, filters) when is_map(filters) do
    if filters["id"] do
      join(query, :inner, [m], country in assoc(m, :countries))
      |> where([..., country], country.id == ^String.to_integer(filters["id"]))
    else
      query
    end
  end

  defp query_by_country(query, _), do: query

  defp query_by_director(query, filters) when is_map(filters) do
    if filters["id"] do
      join(query, :inner, [m], d in assoc(m, :directors))
      |> where([..., d], d.id == ^String.to_integer(filters["id"]))
    else
      query
    end
  end

  defp query_by_director(query, _), do: query
end
