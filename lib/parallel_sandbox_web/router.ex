defmodule ParallelSandboxWeb.Router do
  use ParallelSandboxWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ParallelSandboxWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug(ParallelSandboxWeb.Plugs.SandboxPlug)
  end

  scope "/", ParallelSandboxWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  scope "/api", ParallelSandboxWeb do
    pipe_through :api

    resources "/urls", UrlController, except: [:new, :edit]
    resources "/sandbox", SandboxController, only: [:create, :delete]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:parallel_sandbox, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ParallelSandboxWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
