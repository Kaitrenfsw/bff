defmodule Bff.ProcessingView do
  use Bff.Web, :view

  def render("topic.json", _assign) do
    Poison.decode! _assign[:body]
  end

  def render("topic_user.json", _assign) do
    Poison.decode! _assign[:body]
  end

  def render("update_model.json", _assign) do
    %{message: "Se inició la actualización del modelo."}
  end
end