defmodule CrawlerApisWeb.CountryController do
  use CrawlerApisWeb, :controller
  alias CrawlerApisWeb.Bill

  def index(conn, _params) do
    conn |> json(%{docs: Bill.Country.get_countries(), status: 200})
  end
end
