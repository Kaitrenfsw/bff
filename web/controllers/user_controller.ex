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

          body_tracer = Poison.encode!(%{user_id: data["id"]})
          case HTTPoison.post("http://tracer:4000/api/login_log/", body_tracer, header, []) do

            {:ok, %HTTPoison.Response{body: body}} ->
              conn
              |> put_status(200)
              |> render(Bff.UserView, "login.json", %{data: data})

            {:error, _response} ->
              conn
              |> put_status(401)
              |> render(Bff.ErrorView, "401.json", message: hash_response)
          end
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

  def get_suggestions(conn, _params) do

    [authorization_header | _] = get_req_header(conn, "authorization")
    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]


    case HTTPoison.get("http://user:4000/api/profile/", header, []) do
      {:ok, %HTTPoison.Response{body: body}} ->
        hash_response = Poison.decode!(body)
        user_id = hash_response["user"]["id"]
      case HTTPoison.get("http://business-rules:8001/topicUser/#{user_id}/", header, []) do

        {:ok, %HTTPoison.Response{body: body}} ->
          {:ok, %HTTPoison.Response{body: topics_body}} = HTTPoison.get("http://business-rules:8001/topic/", header, [])
          hash_of_topics = Enum.map(Poison.decode!(topics_body), fn v -> 
            {v["id"], v["name"]} 
          end)
          |> Map.new
          topics = Poison.decode!(body)
          news = Enum.map(topics, fn v ->

            filters = [ %{type: "nested", path: "topics", queries: [%{type: "match", field: "id", value: v["id"]}]} ]
            filters = Poison.encode! filters

            query = "categorized_data:4000/api/documents/?page_size=30&filters=" <> filters
            {:ok, %HTTPoison.Response{body: news_body}} = HTTPoison.get(query, header, [])
            news_decoded_body = Poison.decode! news_body
            Enum.map(news_decoded_body["documents"]["records"], fn k -> 
              topics_with_name = Enum.map(k["topics"], 
                    fn l -> 
                      %{
                          "topic_name" => hash_of_topics[l["id"]],
                          "id" => l["id"],
                          "weight" => l["weight"]
                        } 
                  end
                    )
            sort_topics_with_name = Enum.reverse(Enum.sort_by(topics_with_name,  fn(n) -> n["weight"] end))

            Map.put(k, "topics", sort_topics_with_name)

            end
            )
            end
          )

          array = []

          finished = Enum.reduce(news, array, fn(x, acc) -> acc ++ x end)

          

          conn
          |> put_status(200)
          |> render(Bff.WormholeView, "tunnel.json", %{data: Enum.uniq(finished)})

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


  def relevant_suggestions(conn, %{"topic_id" => topic_id}) do

    [authorization_header | _] = get_req_header(conn, "authorization")
    header = [
              {"Content-Type", "application/json"},
              {"authorization", authorization_header}
             ]




    filters = [ %{type: "nested", path: "topics", queries: [%{type: "match", field: "id", value: topic_id}]} ]
    filters = Poison.encode! filters

    query = "categorized_data:4000/api/documents/?page_size=10&filters=" <> filters
    
    case HTTPoison.get(query, header, []) do
      {:ok, %HTTPoison.Response{body: news_body}} ->

      {:ok, %HTTPoison.Response{body: topics_body}} = HTTPoison.get("http://business-rules:8001/topic/", header, [])
      hash_of_topics = Enum.map(Poison.decode!(topics_body), fn v -> 
        {v["id"], v["name"]} 
      end)
      |> Map.new

        news_decoded_body = Poison.decode! news_body
        new = Enum.map(news_decoded_body["documents"]["records"], fn k -> 
          topics_with_name = Enum.map(k["topics"], 
                fn l -> 
                  {
                    inspect(l["id"]),
                    %{"topic_name" => hash_of_topics[l["id"]],
                                            "id" => l["id"],
                                            "weight" => l["weight"]
                                          } 
                  }
              end
                )
          |> Map.new
        Map.put(k, "topics", topics_with_name)
        end
        )

      array = []
      sort_news = Enum.sort_by(new,  fn(n) -> n["topics"][topic_id]["weight"] end)

      conn
      |> put_status(200)
      |> render(Bff.WormholeView, "tunnel.json", %{data: Enum.reverse(Enum.uniq(sort_news))})

    {:error, _response} ->
      conn
      |> put_status(401)
      |> render(Bff.ErrorView, "500.json")
    end
  end


end