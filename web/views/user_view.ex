defmodule Bff.UserView do
  use Bff.Web, :view

  def render("login.json", _assigns) do
    %{
      user: %{
      	id: 1,
      	email: "algo",
      	token: "adskdskdsakdsakdsajadskjlje21kej2kl2qjiodni218jd21ipd2induwnkqnfi1f"
      }
    }
  end
end