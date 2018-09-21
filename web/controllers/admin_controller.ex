defmodule Bff.AdminController do
  use Bff.Web, :controller

  def create_account(conn, %{"user" => %{ 
                            "email" => email, 
                            "password" => password, 
                            "password_confirmation" => password_confirmation,
                            "group" => group
                          }
                        }) do
    [authorization_header | _] = get_req_header(conn, "authorization")

    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]

    user = %{user: %{
        group: group,
        email: email,
        password: password,
        password_confirmation: password_confirmation
      },
      action: "create_account"
    }

    IO.inspect user
    body_request = Poison.encode!(user)
    case HTTPoison.post("http://user:4000/api/account/", body_request, header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        hash_response = Poison.decode!(body)
        IO.inspect hash_response
        if Map.has_key?(hash_response, "code") and hash_response["code"] == 20100 do
          IO.inspect "llegué"
          conn
          |> put_status(200)
          |> render(Bff.AdminView, "create.json", %{data: hash_response})
        else
          error = hash_response["errors"] || hash_response["error"]
          conn
          |> put_status(401)
          |> render(Bff.ErrorView, "service_error.json", %{error: error})
        end

      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end


  end

end