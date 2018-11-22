defmodule Bff.OwnerController do
  use Bff.Web, :controller

  def create_account(conn, %{ 
                            "email" => email, 
                            "password" => password, 
                            "password_confirmation" => password_confirmation
                        }) do
    [authorization_header | _] = get_req_header(conn, "authorization")

    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]

    user = %{user: %{
        email: email,
        password: password,
        password_confirmation: password_confirmation
      },
      action: "owner_action"
    }

    body_request = Poison.encode!(user)
    case HTTPoison.post("http://user:4000/api/idm_account/", body_request, header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->

        hash_response = Poison.decode!(body)

        if Map.has_key?(hash_response, "code") and hash_response["code"] == 20100 do

          permission = %{permission: %{
              object_name: "user",
              object_id: Integer.to_string(hash_response["id"]),
              group: "owner"
            },
            action: "owner_action"
          }

          permission_body_request = Poison.encode!(permission)

          {:ok, %HTTPoison.Response{body: permission_body}} = HTTPoison.post("http://user:4000/api/permissions/", permission_body_request, header, [])
          
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

    case HTTPoison.get("http://user:4000/api/owners/idms?action=owner_action", header, []) do
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



    case HTTPoison.delete("http://user:4000/api/owners/idms/?id=#{id}&action=owner_action", header, []) do
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
              action: "owner_action",
              profile: %{
                "name" => name,
                "last_name" => last_name,
                "phone" => phone
              }
            }

    body_request = Poison.encode!(body)
    case HTTPoison.put("http://user:4000/api/owners/idms", body_request, header, []) do
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

  def update_password(conn, %{"id" => id, "password" => password, "password_confirmation" => password_confirmation}) do
    [authorization_header | _] = get_req_header(conn, "authorization")
    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]

    body = %{
              id: id,
              action: "owner_action",
              password: password,
              password_confirmation: password_confirmation
            }

    body_request = Poison.encode!(body)
    case HTTPoison.put("http://user:4000/api/owners/idms/update_password", body_request, header, []) do
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

  def user_logs(conn, %{"user_id" => user_id}) do

    header = [
              {"Content-Type", "application/json"}
             ]

    case HTTPoison.get("http://tracer:4000/api/all_logs/?user_id=#{user_id}", header, []) do

      {:ok, %HTTPoison.Response{body: body}} ->

        {:ok, %HTTPoison.Response{body: topics_body}} = HTTPoison.get("http://business-rules:8001/topic/", header, [])
        hash_of_topics = Enum.map(Poison.decode!(topics_body), fn v -> 
          {v["id"], v["name"]} 
        end)
        |> Map.new


        hash_response = Poison.decode!(body)

        unsuscription = Enum.map(hash_response["unsubscriptions"], fn v ->
          v
          |> Map.put(:topic_name, hash_of_topics[v["topic_id"]])
        end)

        suscription = Enum.map(hash_response["subscriptions"], fn v ->
          v
          |> Map.put(:topic_name, hash_of_topics[v["topic_id"]])
        end)

        logins = Enum.map(hash_response["logins"], fn v ->
          v
          |> Map.put(:topic_name, hash_of_topics[v["topic_id"]])
        end)        


        response = %{unsubscriptions: unsuscription, subscriptions: suscription, logins: logins}
        conn
        |> put_status(200)
        |> render(Bff.AdminView, "same.json", %{data: response})
      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")    end


  end

  


end