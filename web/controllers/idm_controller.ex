defmodule Bff.IdmController do
  use Bff.Web, :controller


  def get_dashboard(conn, _assign) do

    [authorization_header | _] = get_req_header(conn, "authorization")
    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]
    case HTTPoison.get("http://user:4000/api/account/", header, []) do
      {:ok, %HTTPoison.Response{body: user_body}} ->
        user_response = Poison.decode!(user_body)
        if Map.has_key?(user_response, "error") do
          conn
          |> put_status(401)
          |> render(Bff.ErrorView, "401.json")
        else

          header = [
                    {"Content-Type", "application/json"}
                   ]        
          case HTTPoison.get("http://business-rules:8001/userDashboard/#{user_response["user"]["id"]}/", header, []) do
            {:ok, %HTTPoison.Response{body: body}} ->

              hash_response = Poison.decode!(body)

              conn
              |> put_status(200)
              |> render(Bff.WormholeView, "tunnel.json", %{data: hash_response})

            {:error, _response} ->
              conn
              |> put_status(500)
              |> render(Bff.ErrorView, "500.json")

          end

        end

      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end

  end

  def update_dashboard(conn, %{"graphs_selected" => graphs_selected}) do
    [authorization_header | _] = get_req_header(conn, "authorization")
    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]
    case HTTPoison.get("http://user:4000/api/account/", header, []) do
      {:ok, %HTTPoison.Response{body: user_body}} ->
        user_response = Poison.decode!(user_body)
        if Map.has_key?(user_response, "error") do
          conn
          |> put_status(401)
          |> render(Bff.ErrorView, "401.json")
        else

          header = [
                    {"Content-Type", "application/json"}
                   ]        

          params = Poison.encode!(%{"graphs_selected" => graphs_selected})
          case HTTPoison.put("http://business-rules:8001/userDashboard/#{user_response["user"]["id"]}/", params, header, []) do
            {:ok, %HTTPoison.Response{body: body}} ->
              hash_response = Poison.decode!(body)

              conn
              |> put_status(200)
              |> render(Bff.WormholeView, "tunnel.json", %{data: hash_response})

            {:error, _response} ->
              conn
              |> put_status(500)
              |> render(Bff.ErrorView, "500.json")

          end

        end

      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end

  end 

  def delete_dashboard(conn, _assign) do
    [authorization_header | _] = get_req_header(conn, "authorization")
    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]
    case HTTPoison.get("http://user:4000/api/account/", header, []) do
      {:ok, %HTTPoison.Response{body: user_body}} ->
        user_response = Poison.decode!(user_body)
        if Map.has_key?(user_response, "error") do
          conn
          |> put_status(401)
          |> render(Bff.ErrorView, "401.json")
        else

          header = [
                    {"Content-Type", "application/json"}
                   ]        

          case HTTPoison.delete("http://business-rules:8001/userDashboard/#{user_response["user"]["id"]}/", header, []) do
            {:ok, %HTTPoison.Response{body: body}} ->
              hash_response = Poison.decode!(body)

              conn
              |> put_status(200)
              |> render(Bff.WormholeView, "tunnel.json", %{data: hash_response})

            {:error, _response} ->
              conn
              |> put_status(500)
              |> render(Bff.ErrorView, "500.json")

          end

        end

      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end

  end    
end