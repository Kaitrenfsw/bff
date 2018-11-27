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

        hash_response = Poison.decode!(body)
        if Map.has_key?(hash_response, "code") and hash_response["code"] == 20100 do
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


  def sources(conn, %{"user_id" => user_id}) do
    
    header = [
              {"Content-Type", "application/json"}
             ]

    case HTTPoison.get("http://business-rules:8001/sourceUser/#{user_id}/", header, []) do

      {:ok, %HTTPoison.Response{body: own_body}} ->

        own_hash_response = Poison.decode!(own_body)
  
        hash_of_own_sources = Enum.map(own_hash_response["sources"], fn v -> 
          {v["id"], v} 
        end)
        |> Map.new

        header = [
                  {"Content-Type", "application/json"}
                 ]


        case HTTPoison.get("http://business-rules:8001/sourceVotes/", header, []) do
          
          {:ok, %HTTPoison.Response{body: body}} ->

            hash_response = Poison.decode!(body)
            IO.inspect hash_response
            IO.inspect "hola"
            IO.inspect "hola"
            IO.inspect "hola"
            IO.inspect "hola"
            hash_with_favorite = Enum.map(hash_response, fn v -> 
              case hash_of_own_sources[v["id"]] do
                
                nil ->
                  %{site: v["site"], name: v["name"], id: v["id"], favorite: 0, down_votes: v["down_votes"], up_votes: v["up_votes"]}
                _ ->
                  %{site: v["site"], name: v["name"], id: v["id"], favorite: 1, down_votes: v["down_votes"], up_votes: v["up_votes"]}

              end

            end)
            conn
            |> put_status(200)
            |> render(Bff.WormholeView, "tunnel.json", %{data: hash_with_favorite})

          {:error, _response} ->
            conn
            |> put_status(401)
            |> render(Bff.ErrorView, "500.json")

        end


      {:error, _response} ->
        conn
        |> put_status(401)
        |> render(Bff.ErrorView, "500.json")

    end







  end

end