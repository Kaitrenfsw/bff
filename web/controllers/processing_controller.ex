defmodule Bff.ProcessingController do
  use Bff.Web, :controller

  def content(conn, assigns) do
    token = get_req_header(conn, "auth")
    
    response = HTTPoison.get! "http://processing:8000/topic/"
    body = response.body
    
    conn
    |> put_status(200)
    |> render(Bff.ProcessingView, "topic.json", body: body)
  end

  def topic_user(conn, assigns) do

    header = [
              {"Content-Type", "application/json"}
             ]    
    body = Poison.encode!(%{user_id: 1})
    
    case HTTPoison.post("http://processing:8000/topicUser/", body, header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->

        conn
        |> put_status(200)
        |> render(Bff.ProcessingView, "topic_user.json", body: body)
      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end

  end

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