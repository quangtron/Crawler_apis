defmodule CrawlerApis.Repo do
  use Ecto.Repo,
    otp_app: :crawler_apis,
    adapter: Ecto.Adapters.Postgres
end
