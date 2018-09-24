defmodule Bff.TopicController do
  use Bff.Web, :controller



  def index(conn, _assign) do
    header = [
              {"Content-Type", "application/json"}
             ]

    case HTTPoison.get("http://business-rules:8001/topic/", header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->

        hash_response = Poison.decode!(body)

        conn
        |> put_status(200)
        |> render(Bff.WormholeView, "tunnel.json", %{data: hash_response})

      {:error, _response} ->
        conn
        |> put_status(401)
        |> render(Bff.ErrorView, "500.json")

    end
  end

  def show(conn, %{"id" => id}) do
    header = [
              {"Content-Type", "application/json"}
             ]
             
    case HTTPoison.get("http://business-rules:8001/topic/#{id}/", header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        hash_response = Poison.decode!(body)
        conn
        |> put_status(200)
        |> render(Bff.WormholeView, "tunnel.json", %{data: hash_response})

      {:error, _response} ->
        conn
        |> put_status(401)
        |> render(Bff.ErrorView, "500.json")

    end
  end

end