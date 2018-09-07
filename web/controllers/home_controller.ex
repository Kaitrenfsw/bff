defmodule Bff.HomeController do
  use Bff.Web, :controller

  def deal_with(conn, assigns) do
    conn
    |> put_status(:not_found)
    |> render(Bff.ErrorView, "404.json", assigns)
  end

  def heartbeat(conn, _assigns) do
    conn
    |> put_status(200)
    |> render(Bff.HomeView, "heartbeat.json")
  end
end