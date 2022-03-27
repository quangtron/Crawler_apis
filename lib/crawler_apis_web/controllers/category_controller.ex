defmodule CrawlerApisWeb.CategoryController do
  use CrawlerApisWeb, :controller
  alias CrawlerApisWeb.Bill

  def index(conn, _params) do
    conn |> json(%{docs: Bill.Category.get_categories(), status: 200})
  end
end
