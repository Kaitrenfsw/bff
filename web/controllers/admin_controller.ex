defmodule Bff.AdminController do
  use Bff.Web, :controller

  def create_account(conn, %{ 
                            "email" => email, 
                            "password" => password, 
                            "password_confirmation" => password_confirmation,
                            "group" => group
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

    body_request = Poison.encode!(user)
    case HTTPoison.post("http://user:4000/api/account/", body_request, header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        IO.inspect "ghola"
        IO.inspect "ghola"
        IO.inspect "ghola"
        IO.inspect "ghola"
        IO.inspect body

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
          |> put_status(422)
          |> render(Bff.ErrorView, "service_error.json", %{error: error})
        end

      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end


  end

  def index(conn, _assign) do
    [authorization_header | _] = get_req_header(conn, "authorization")

    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]

    case HTTPoison.get("http://user:4000/api/users?action=get_accounts", header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        hash_response = Poison.decode!(body)
        conn
        |> put_status(200)
        |> render(Bff.AdminView, "same.json", %{data: hash_response})
      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end

  end

  def show(conn, %{"id" => id}) do
    [authorization_header | _] = get_req_header(conn, "authorization")

    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]

    case HTTPoison.get("http://user:4000/api/users/#{id}?action=get_accounts", header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        hash_response = Poison.decode!(body)
        conn
        |> put_status(200)
        |> render(Bff.AdminView, "same.json", %{data: hash_response})
      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end
  end

  def delete_account(conn, %{"id" => id}) do

    [authorization_header | _] = get_req_header(conn, "authorization")

    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]

    body = %{
              id: id,
              action: "delete_account"
            }

    body_request = Poison.encode!(body)
    case HTTPoison.delete("http://user:4000/api/users/?id=#{id}&action=delete_account", header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        hash_response = Poison.decode!(body)
        conn
        |> put_status(200)
        |> render(Bff.AdminView, "same.json", %{data: hash_response})
      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end

  end

  def update_account(conn, %{"id" => id, "profile" => %{"name" => name, "last_name" => last_name, "phone" => phone}}) do
    [authorization_header | _] = get_req_header(conn, "authorization")
    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]

    body = %{
              id: id,
              action: "update_account",
              profile: %{
                "name" => name,
                "last_name" => last_name,
                "phone" => phone
              }
            }

    body_request = Poison.encode!(body)
    case HTTPoison.put("http://user:4000/api/users/", body_request, header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        hash_response = Poison.decode!(body)

        conn
        |> put_status(200)
        |> render(Bff.AdminView, "same.json", %{data: hash_response})
      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end
  end

  def lock_account(conn, %{"user" => %{"id" => id, "active" => active}}) do
    [authorization_header | _] = get_req_header(conn, "authorization")
    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]

    body = %{
              user: %{
                id: id,
                active: active
              },
              action: "admin_accounts"
            }

    body_request = Poison.encode!(body)
    case HTTPoison.put("http://user:4000/api/account/activate", body_request, header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        hash_response = Poison.decode!(body)
        IO.inspect hash_response
        conn
        |> put_status(200)
        |> render(Bff.AdminView, "same.json", %{data: hash_response})
      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end
  end  

end