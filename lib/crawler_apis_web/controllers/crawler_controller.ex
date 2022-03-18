defmodule CrawlerApisWeb.CrawlerController do
  use CrawlerApisWeb, :controller
  use CrawlerBll

  def craw(conn, %{"url" => url}) do
    conn |> put_status(200) |> json(%{data: craw_by_url(url), status: 200})
  end

  def craw_many(conn, %{"urls" => urls}) do
    conn |> put_status(200) |> json(%{data: craw_by_urls(urls), status: 200})
  end
end
