defmodule Bff.UserView do
  use Bff.Web, :view

  def render("login.json", %{data: data}) do
    IO.inspect data
    %{
      user: %{
      	id: data["id"],
      	email: data["email"],
      	token: data["access_token"]
      }
    }
  end
end