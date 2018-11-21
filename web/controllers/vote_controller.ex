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

    body = %{new_id: new_id, source_id: 17, vote: vote}
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

  def user_source(conn, %{"user_id" => user_id, "source_id" => source_id, "action" => action}) do

    header = [
              {"Content-Type", "application/json"}
             ]

    body = %{user_id: user_id, source_id: source_id}

    body_request = Poison.encode!(body)

    case HTTPoison.put("http://business-rules:8001/sourceUser/#{action}/", body_request, header, []) do
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

  def create_content_user(conn, %{"user_id" => user_id, "content_id" => content_id}) do

    header = [
              {"Content-Type", "application/json"}
             ]

    body = %{user_id: user_id, content_id: content_id}

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

    case HTTPoison.delete("http://business-rules:8001/contentUser/#{id}/", header, []) do
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

  def saved_news(conn, _assign) do
    



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

          case HTTPoison.get("http://business-rules:8001/contentUser/#{user_response["user"]["id"]}/", header, []) do

            {:ok, %HTTPoison.Response{body: body}} ->


              case HTTPoison.get("http://business-rules:8001/sourceUser/#{user_response["user"]["id"]}/", header, []) do

                {:ok, %HTTPoison.Response{body: own_body}} ->

                  own_hash_response = Poison.decode!(own_body)
            
                  hash_of_own_sources = Enum.map(own_hash_response["sources"], fn v -> 
                    {v["id"], v} 
                  end)
                  |> Map.new


                {:error, _response} ->
                  hash_of_own_sources = %{}

              end

              case HTTPoison.get("http://business-rules:8001/userVote/#{user_response["user"]["id"]}/", header, []) do
                {:ok, %HTTPoison.Response{body: user_vote_body}} ->
                  user_vote_hash_response = Poison.decode!(user_vote_body)
                  user_vote_hash = Enum.map(user_vote_hash_response["records"], fn v -> 
                    {v["new_id"], v}
                  end) 
                  |> Map.new

                {:error, _response} ->
                  user_vote_hash = %{}
              end
              
              case HTTPoison.get("http://business-rules:8001/topicUser/#{user_response["user"]["id"]}/", header, []) do

                {:ok, %HTTPoison.Response{body: body}} ->
                  {:ok, %HTTPoison.Response{body: topics_body}} = HTTPoison.get("http://business-rules:8001/topic/", header, [])
                  hash_of_topics = Enum.map(Poison.decode!(topics_body), fn v -> 
                    {v["id"], v["name"]} 
                  end)
                  |> Map.new

                {:error, _response} ->
                  hash_of_topics = %{}
                end

              hash_response = Poison.decode!(body)
              array = Enum.map(hash_response["contents"], fn v -> 
                filters = [ %{ "type" => "match", "field" => "_id", "value" => v["content_id"] } ]

                filters = Poison.encode! filters


                query = "http://categorized_data:4000/api/documents/?page_size=30&filters=" <> filters

                case HTTPoison.get(query, header, []) do

                  {:ok, %HTTPoison.Response{body: new_body}} ->

                    new_hash_response = Poison.decode!(new_body)
                    [new | _] = new_hash_response["documents"]["records"]
                    new

                    topics_with_name = Enum.map(new["topics"], 
                          fn l -> 
                            %{
                                "topic_name" => hash_of_topics[l["id"]],
                                "id" => l["id"],
                                "weight" => l["weight"]
                              } 
                        end
                          )

                    case HTTPoison.get("http://business-rules:8001/newVotes/#{new["id"]}/", header, []) do
                      {:ok, %HTTPoison.Response{body: new_votes_body}} ->
                        new_votes_hash_response = Poison.decode!(new_votes_body)

                        up_votes = new_votes_hash_response["up_votes"]
                        down_votes = new_votes_hash_response["down_votes"]
                      {:error, _response} ->
                        up_votes = 0
                        down_votes = 0

                    end



                    is_fav = if hash_of_own_sources[new["source_id"]], do: 1, else: 0
                    sort_topics_with_name = Enum.reverse(Enum.sort_by(topics_with_name,  fn(n) -> n["weight"] end))
                    saved = 1

                    case user_vote_hash[new["id"]]["vote"] do
                      0 ->  
                        voted = 2
                      1 ->
                        voted = 1
                      _ -> 
                        voted = 0
                    end

                    new
                    |> Map.put("topics", sort_topics_with_name)
                    |> Map.put("fav_source", is_fav)
                    |> Map.put("up_votes", up_votes)
                    |> Map.put("down_votes", down_votes)
                    |> Map.put("saved", saved)
                    |> Map.put("voted", voted)

                  {:error, _response} ->
                    %{message: "problema"}

                end
              end) 
              IO.inspect array
              conn
              |> put_status(200)
              |> render(Bff.WormholeView, "tunnel.json", %{data: array})

            {:error, _response} ->
              conn
              |> put_status(401)
              |> render(Bff.ErrorView, "500.json")

          end

        end

      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")

    end
  end






  def get_sources(conn, %{"user_id" => user_id}) do

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

        case HTTPoison.get("http://business-rules:8001/source/", header, []) do
          
          {:ok, %HTTPoison.Response{body: body}} ->

            hash_response = Poison.decode!(body)

            hash_with_favorite = Enum.map(hash_response, fn v -> 

              case hash_of_own_sources[v["id"]] do
                
                nil ->
                  %{site: v["site"], name: v["name"], id: v["id"], favorite: 0}
                _ ->
                  %{site: v["site"], name: v["name"], id: v["id"], favorite: 1}

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

  def get_topic_stats(conn, _assigns) do

    [authorization_header | _] = get_req_header(conn, "authorization")
    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]

    case HTTPoison.get("http://user:4000/api/owners/idms/?action=owner_action", header, []) do
      {:ok, %HTTPoison.Response{body: users_body}} ->
        users_hash_response = Poison.decode!(users_body)
        users_ids = Enum.map(users_hash_response["users"], fn v -> Integer.to_string(v["id"]) end)

        users_ids_to_request = Enum.join(users_ids, "-")

        request_url = "http://business-rules:8001/topicStats/" <> users_ids_to_request <> "/"
        case HTTPoison.get(request_url, header, []) do
          
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

      {:error, _response} ->
        conn
        |> put_status(500)
        |> render(Bff.ErrorView, "500.json")
    end

  end
end