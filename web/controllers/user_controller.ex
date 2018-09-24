defmodule Bff.UserController do
  use Bff.Web, :controller

  def login(conn, %{"email" => email, "password" => password}) do
    
    header = [
              {"Content-Type", "application/json"}
             ]    
    user = %{session: %{email: email, password: password}}
    body_request = Poison.encode!(user)
    case HTTPoison.post("http://user:4000/api/sign_in/", body_request, header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        hash_response = Poison.decode!(body)
        if Map.has_key?(hash_response, "code") and hash_response["code"] == 20101 do
          data = hash_response["data"]
          conn
          |> put_status(200)
          |> render(Bff.UserView, "login.json", %{data: data})
        else
          conn
          |> put_status(401)
          |> render(Bff.ErrorView, "401.json", message: hash_response)
        end

      {:error, _response} ->
        conn
        |> put_status(401)
        |> render(Bff.ErrorView, "500.json")

    end


  end

  def show(conn, _assign) do

    [authorization_header | _] = get_req_header(conn, "authorization")
    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]


    case HTTPoison.get("http://user:4000/api/profile/", header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        hash_response = Poison.decode!(body)
        data = hash_response
        conn
        |> put_status(200)
        |> render(Bff.UserView, "same.json", %{data: data})
      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end
  end

  def update(conn, %{"profile" => %{"name" => name, "last_name" => last_name, "phone" => phone}}) do

    [authorization_header | _] = get_req_header(conn, "authorization")
    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]

    body = %{
              action: "update_account",
              profile: %{
                "name" => name,
                "last_name" => last_name,
                "phone" => phone
              }
            }

    body_request = Poison.encode!(body)
    case HTTPoison.put("http://user:4000/api/profile/", body_request, header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        hash_response = Poison.decode!(body)
        
        conn
        |> put_status(200)
        |> render(Bff.UserView, "same.json", %{data: hash_response})
      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end
  end


  def topics(conn, %{"id" => id}) do
    header = [
              {"Content-Type", "application/json"}
             ]
             
    case HTTPoison.get("http://business-rules:8001/topicUser/#{id}/", header, []) do
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

  def update_topics(conn, %{"id" => id, "user_topics_id" => topics_ids}) do
    header = [
              {"Content-Type", "application/json"}
             ]
    body = %{
      "user_topics_id" => topics_ids,
      "user_id" => id
    }

    body_request = Poison.encode!(body)
    case HTTPoison.put("http://business-rules:8001/topicUser/#{id}/", body_request, header, []) do
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