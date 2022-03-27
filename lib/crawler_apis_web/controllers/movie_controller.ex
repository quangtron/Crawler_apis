defmodule CrawlerApisWeb.MovieController do
  use CrawlerApisWeb, :controller
  alias CrawlerApisWeb.Bill

  def index(conn, params) do
    rs = Bill.Movie.get_movies_by_query(params)
    # |> Enum.map(fn x -> x.id end)
    conn
    |> json(%{docs: rs.data, offset: rs.offset, limit: rs.limit, total: rs.total, status: 200})
  end
end
