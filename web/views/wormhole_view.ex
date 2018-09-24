defmodule Bff.WormholeView do
  use Bff.Web, :view



  def render("tunnel.json", %{data: data}) do
    data
  end

end