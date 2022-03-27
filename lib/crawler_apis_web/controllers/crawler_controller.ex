defmodule CrawlerApisWeb.CrawlerController do
  use CrawlerApisWeb, :controller

  def craw(conn, %{"url" => url}) do
    rs = CrawlerApisWeb.Bill.Crawler.craw_and_write_to_db(url)
    conn |> json(%{status: rs})
  end

  def craw_many(conn, %{"urls" => urls}) do
    conn
    |> put_status(200)
    |> json(%{docs: CrawlerApisWeb.Bill.Crawler.craw_by_urls(urls), status: 200})
  end
end
