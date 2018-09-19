defmodule Bff.AdminView do
  use Bff.Web, :view

  def render("create.json", %{data: data}) do
    IO.inspect data
    %{
      user: %{
      	id: data["id"],
      	email: data["email"],
        message: data["message"]
      }
    }
  end
end