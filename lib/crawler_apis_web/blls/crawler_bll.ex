defmodule CrawlerApisWeb.Bill.Crawler do
  alias CrawlerApis.{Movie, Category, Country, Director, Repo}

  @max_page 1
  @now NaiveDateTime.local_now()
  @country "/bphimmoi.net/country/"
  @director "/director/"
  @category "/bphimmoi.net/category/"
  @movie_type "MOVIE"
  @category_type "CATEGORY"
  @country_type "COUNTRY"
  @director_type "DIRECTOR"

  defp fetch_data_head(url), do: Crawly.fetch(url)

  defp fetch_tail_body_data(%{url: url, page_number: page_number}) do
    with {:ok, data} <-
           Floki.parse_document(Crawly.fetch("#{url}page/#{page_number}/").body),
         true <- check_page_has_film(data) > 0 && page_number <= @max_page do
      data ++ fetch_tail_body_data(%{url: url, page_number: page_number + 1})
    else
      :error -> :error
      _ -> []
    end
  end

  defp check_page_has_film(docs), do: docs |> Floki.find(".movie-list-index") |> length()

  defp get_film_info_list(docs) do
    docs
    |> Floki.find(".movie-list-index .movie-item")
    |> Enum.map(fn x ->
      %{
        link: Floki.attribute(x, "href") |> Enum.at(0),
        title: String.replace(Floki.text(x), "\t", "-"),
        full_series:
          Floki.find(x, ".block-wrapper .movie-meta .ribbon")
          |> Floki.text()
          |> String.downcase()
          |> String.contains?("full"),
        number_of_episode:
          Floki.find(x, ".block-wrapper .movie-meta .ribbon")
          |> Floki.text()
          |> String.split("/")
          |> Enum.map(fn x -> "0" <> String.replace(x, ~r/[^\d]/, "") end)
          |> List.last()
          |> String.to_integer(),
        thumnail:
          Floki.find(x, ".block-wrapper .movie-thumbnail .public-film-item-thumb")
          |> Floki.attribute("data-wpfc-original-src")
          |> Enum.at(0),
        year:
          Floki.find(x, ".block-wrapper .movie-meta .movie-title-2")
          |> Floki.text()
          |> String.split("(")
          |> Enum.map(fn x -> "0" <> String.replace(x, ~r/[^\d]/, "") end)
          |> List.last()
          |> String.to_integer()
      }
    end)
  end

  defp convert_data(items, header) do
    {_, date} = Enum.at(header, 0)

    %{
      crawled_at: date,
      total: length(items),
      items: items
    }
  end

  defp set_changeset(x, @movie_type) do
    Movie.changeset(
      %Movie{
        title: x.title,
        link: x.link,
        number_of_episode: x.number_of_episode,
        thumnail: x.thumnail,
        full_series: x.full_series,
        year: x.year,
        inserted_at: @now,
        updated_at: @now
      },
      %{}
    )
  end

  defp set_changeset(x, @category_type) do
    Category.changeset(
      %Category{
        name: x,
        inserted_at: @now,
        updated_at: @now
      },
      %{}
    )
  end

  defp set_changeset(x, @country_type) do
    Country.changeset(
      %Country{
        name: x,
        inserted_at: @now,
        updated_at: @now
      },
      %{}
    )
  end

  defp set_changeset(x, @director_type) do
    Director.changeset(
      %Director{
        name: x,
        inserted_at: @now,
        updated_at: @now
      },
      %{}
    )
  end

  defp convert_to_struct(items, type) do
    items
    |> Enum.map(fn x ->
      with data <-
             item = set_changeset(x, type),
           true <- item.valid? do
        data.data
      else
        :error -> IO.inspect(:error)
        _ -> []
      end
      |> Map.drop([:__meta__, :categories, :movies, :countries, :directors, :id])
    end)
  end

  defp craw_directors(link) do
    data = fetch_data_head(link)
    {:ok, body_data} = Floki.parse_document(data.body)

    info =
      body_data
      |> Floki.find(".movie-detail .movie-dd.dd-cat a")

    info
    |> Floki.attribute("href")
    |> Enum.filter(fn x -> String.contains?(x, @director) end)
    |> Enum.map(fn x -> List.last(String.split(x, "/")) end)
  end

  defp insert_movie_and_associate_to_db(movie) do
    IO.inspect(movie.link)
    data = fetch_data_head(movie.link)
    {:ok, body_data} = Floki.parse_document(data.body)

    info =
      body_data
      |> Floki.find(".movie-detail .movie-dd.dd-cat a")

    categories =
      info
      |> Enum.filter(fn x ->
        Floki.attribute(x, "href")
        |> Enum.filter(fn x -> String.contains?(x, @category) end)
        |> length() > 0
      end)
      |> Enum.map(fn x ->
        name = Floki.text(x) |> String.trim()
        Repo.get_by!(Category, name: name)
      end)

    directors =
      info
      |> Floki.attribute("href")
      |> Enum.filter(fn x -> String.contains?(x, @director) end)
      |> Enum.map(fn x ->
        name = List.last(String.split(x, "/"))
        Repo.get_by!(Director, name: name)
      end)

    countries =
      info
      |> Floki.attribute("href")
      |> Enum.filter(fn x -> String.contains?(x, @country) end)
      |> Enum.map(fn x ->
        name = List.last(String.split(x, "/"))
        Repo.get_by!(Country, name: name)
      end)

    # Insert moive
    m = set_changeset(movie, @movie_type) |> IO.inspect()
    m = Repo.insert!(m)

    # # Make association many-to-many (movies-categories)
    m = Repo.preload(m, [:directors, :categories, :countries])
    movie_changeset = Ecto.Changeset.change(m)

    movie_actors_changeset =
      movie_changeset
      |> Ecto.Changeset.put_assoc(:categories, movie_changeset.data.categories ++ categories)
      |> Ecto.Changeset.put_assoc(:countries, movie_changeset.data.countries ++ countries)
      |> Ecto.Changeset.put_assoc(:directors, movie_changeset.data.directors ++ directors)

    Repo.update!(movie_actors_changeset)
  end

  defp get_countries_and_categories(data) do
    list =
      data
      |> Floki.find(".list-movie-filter .list-movie-filter-item")

    countries =
      list
      |> Enum.at(3)
      |> Floki.find("option")
      |> Floki.attribute("value")

    categories =
      list
      |> Floki.find("#category option")
      |> Enum.map(&Floki.text/1)
      |> Enum.map(&String.trim/1)

    {countries, categories}
  end

  def craw_and_write_to_db(url) do
    IO.puts(url)
    head_data = fetch_data_head(url)
    {:ok, head_body_data} = Floki.parse_document(head_data.body)

    movies =
      (head_body_data ++ fetch_tail_body_data(%{url: url, page_number: 2}))
      |> get_film_info_list()
      |> convert_to_struct(@movie_type)
      |> Enum.map(fn x -> Map.from_struct(x) end)

    # {countries, categories} = head_body_data |> get_countries_and_categories()

    # categories =
    #   categories
    #   |> convert_to_struct(@category_type)
    #   |> Enum.map(fn x -> Map.from_struct(x) end)

    # countries =
    #   countries
    #   |> convert_to_struct(@country_type)
    #   |> Enum.map(fn x -> Map.from_struct(x) end)

    # directors =
    #   movies
    #   |> Enum.map(fn x -> craw_directors(x.link) end)
    #   |> Enum.concat()
    #   |> Enum.uniq()
    #   |> convert_to_struct(@director_type)
    #   |> Enum.map(fn x -> Map.from_struct(x) end)

    try do
      # Repo.insert_all(Category, categories)
      # Repo.insert_all(Country, countries)
      # Repo.insert_all(Director, directors)
      movies
      |> Enum.map(&insert_movie_and_associate_to_db/1)

      200
    catch
      error -> error
    end
  end

  def craw_by_urls(urls) do
    urls |> Enum.map(&craw_and_write_to_db/1)
  end
end
