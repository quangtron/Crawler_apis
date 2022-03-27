defmodule CrawlerApisWeb.Router do
  use CrawlerApisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CrawlerApisWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug, origin: "http://localhost:3000/"
  end

  scope "/", CrawlerApisWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/apis", CrawlerApisWeb do
    pipe_through :api

    post "/crawler", CrawlerController, :craw
    post "/crawler/many", CrawlerController, :craw_many
    resources "/movie", MovieController, only: [:index]
    resources "/category", CategoryController, only: [:index]
    resources "/country", CountryController, only: [:index]
    resources "/director", DirectorController, only: [:index]
  end

  # Other scopes may use custom stacks.
  # scope "/api", CrawlerApisWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CrawlerApisWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
