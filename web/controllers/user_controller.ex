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
          |> render(Bff.ErrorView, "401.json")
        end

      {:error, _response} ->
        conn
        |> put_status(401)
        |> render(Bff.ErrorView, "500.json")

    end


  end

  def show(conn, _assign) do
    header = [
              {"Content-Type", "application/json"}
             ]


    case HTTPoison.get("http://user:4000/api/profile/", header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        hash_response = Poison.decode!(body)
        data = hash_response["data"]
        conn
        |> put_status(200)
        |> render(Bff.UserView, "same.json", %{data: data})
      {:error, _response} ->
        conn
        |> put_status(401)
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


  # def topics(conn, _assign) do
  #   header = [
  #             {"Content-Type", "application/json"}
  #            ]
             
  #   user = %{session: %{email: email, password: password}}
  #   body_request = Poison.encode!(user)
  #   case HTTPoison.post("http://business-rules:8000/topicUser/pk/", body_request, header, []) do
  #     {:ok, %HTTPoison.Response{body: body}} ->
  #       hash_response = Poison.decode!(body)
  #       if Map.has_key?(hash_response, "code") and hash_response["code"] == 20101 do
  #         data = hash_response["data"]
  #         conn
  #         |> put_status(200)
  #         |> render(Bff.UserView, "login.json", %{data: data})
  #       else
  #         conn
  #         |> put_status(401)
  #         |> render(Bff.ErrorView, "401.json")
  #       end

  #     {:error, _response} ->
  #       conn
  #       |> put_status(401)
  #       |> render(Bff.ErrorView, "500.json")

  #   end
  # end

end