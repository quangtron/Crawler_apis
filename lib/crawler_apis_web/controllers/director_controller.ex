defmodule CrawlerApisWeb.DirectorController do
  use CrawlerApisWeb, :controller
  alias CrawlerApisWeb.Bill

  def index(conn, _params) do
    conn |> json(%{docs: Bill.Director.get_directors(), status: 200})
  end
end
