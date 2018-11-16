defmodule Bff.VoteController do
  use Bff.Web, :controller



  def new_votes(conn, _assign) do
    header = [
              {"Content-Type", "application/json"}
             ]

    case HTTPoison.get("http://business-rules:8001/newVotes/", header, []) do
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


  def source_votes(conn, _assign) do
    header = [
              {"Content-Type", "application/json"}
             ]

    case HTTPoison.get("http://business-rules:8001/sourceVotes/", header, []) do
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


  def one_source_votes(conn, %{"source_id" => source_id}) do
    header = [
              {"Content-Type", "application/json"}
             ]

    case HTTPoison.get("http://business-rules:8001/sourceVotes/#{source_id}/", header, []) do
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


  def update_user_vote(conn, %{"user_id" => user_id, "new_id" => new_id, "source_id" => source_id, "vote" => vote}) do
    header = [
              {"Content-Type", "application/json"}
             ]

    body = %{new_id: new_id, source_id: source_id, vote: vote}

    body_request = Poison.encode!(body)

    case HTTPoison.put("http://business-rules:8001/userVote/#{user_id}/", body_request, header, []) do
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

  def get_user_votes(conn, %{"user_id" => user_id}) do
    header = [
              {"Content-Type", "application/json"}
             ]

    case HTTPoison.get("http://business-rules:8001/userVote/#{user_id}/", header, []) do
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

  def remove_user_source(conn, %{"source_user_id" => source_user_id}) do
    header = [
              {"Content-Type", "application/json"}
             ]        

    case HTTPoison.delete("http://business-rules:8001/sourceUser/#{source_user_id}/", header, []) do
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

  def create_user_source(conn, %{"user_id" => user_id, "source_id" => source_id}) do

    header = [
              {"Content-Type", "application/json"}
             ]

    body = %{new_id: new_id, source_id: source_id}

    body_request = Poison.encode!(body)

    case HTTPoison.post("http://business-rules:8001/sourceUser/", body_request, header, []) do
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

  def get_source_user(conn, %{"user_id" => user_id}) do
    header = [
              {"Content-Type", "application/json"}
             ]

    case HTTPoison.get("http://business-rules:8001/sourceUser/#{user_id}/", header, []) do

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

  def create_user_source(conn, %{"user_id" => user_id, "content_id" => content_id}) do

    header = [
              {"Content-Type", "application/json"}
             ]

    body = %{new_id: new_id, content_id: content_id}

    body_request = Poison.encode!(body)

    case HTTPoison.post("http://business-rules:8001/contentUser/", body_request, header, []) do
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

  def remove_content_user(conn, %{"id" => id}) do
    header = [
              {"Content-Type", "application/json"}
             ]        

    case HTTPoison.delete("http://business-rules:8001/sourceUser/#{id}/", header, []) do
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

end