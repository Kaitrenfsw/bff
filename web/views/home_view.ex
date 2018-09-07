defmodule Bff.HomeView do
  use Bff.Web, :view

  def render("heartbeat.json", _assign) do
    %{
      service: "bff"
    }
  end
end