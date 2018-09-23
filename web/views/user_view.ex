defmodule Bff.UserView do
  use Bff.Web, :view

  def render("login.json", %{data: data}) do
    IO.inspect data
    %{
      user: %{
      	id: data["id"],
      	email: data["email"],
      	token: data["access_token"],
        user_type: data["user_type"]
      }
    }
  end

  def render("same.json", %{data: data}) do
    data
  end

end