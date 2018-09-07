defmodule Bff.ProcessingController do
  use Bff.Web, :controller

  def content(conn, assigns) do
    token = get_req_header(conn, "auth")
    
    response = HTTPoison.get! "http://procesamiento:8000/topic/"
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
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.post("http://procesamiento:8000/topicUser/", body, header, [])

    IO.puts body

    IO.puts "get"
    conn
    |> put_status(200)
    |> render(Bff.ProcessingView, "topic_user.json", body: body)
  end

end