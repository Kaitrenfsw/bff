defmodule Bff.ProcessingController do
  use Bff.Web, :controller

  def update_model(conn, assigns) do

    header = [
              {"Content-Type", "application/json"}
             ]    

    body = Poison.encode!(%{})

    case HTTPoison.post("http://processing:8000/ldamodel/", body, header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->

        conn
        |> put_status(200)
        |> render(Bff.ProcessingView, "update_model.json", body: body)
      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end


  end  

end