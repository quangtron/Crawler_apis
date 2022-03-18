defmodule CrawlerApisWeb.PageController do
  use CrawlerApisWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
