defmodule Bff.UserController do
  use Bff.Web, :controller

  def login(conn, %{"email" => email, "password" => password}) do
    IO.inspect "HOLAAAAA"
    
    header = [
              {"Content-Type", "application/json"}
             ]    
    user = %{session: %{email: email, password: password}}
    body_request = Poison.encode!(user)
    IO.inspect HTTPoison.post("http://user:4000/api/sign_in/", body_request, header, [])
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

end