defmodule CrawlerBll do
  defmacro __using__(_opts) do
    quote do
      defp fetch_data_head(url), do: Crawly.fetch(url)

      defp fetch_tail_body_data(%{url: url, page_number: page_number}) do
        with {:ok, data} <-
               Floki.parse_document(Crawly.fetch("#{url}page/#{page_number}/").body),
             true <- check_page_has_film(data) > 0 && page_number <= 100 do
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

      def craw_by_url(url) do
        IO.puts(url)
        head_data = fetch_data_head(url)
        header = head_data.headers
        {:ok, head_body_data} = Floki.parse_document(head_data.body)

        (head_body_data ++ fetch_tail_body_data(%{url: url, page_number: 2}))
        |> get_film_info_list()
        |> convert_data(header)
      end

      def craw_by_urls(urls) do
        urls |> Enum.map(fn x -> Map.merge(craw_by_url(x), %{link: x}) end)
      end
    end
  end
end
