defmodule Bff.VisualizationController do
  use Bff.Web, :controller

  plug :check_topics_ids when action in [:get_multiple_frequency_curve, :get_hot_topics]

  def get_graph(conn, %{"topic_id" => topic_id}) do
    header = [
              {"Content-Type", "application/json"}
             ]

    case HTTPoison.get("http://business-rules:8001/topicComparison/#{topic_id}/", header, []) do
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

  def get_frequency_curve(conn, %{"topic_id" => topic_id, "date" => date}) do
    header = [
              {"Content-Type", "application/json"}
             ]

    case HTTPoison.get("http://business-rules:8001/dateConversion/#{date}/", header, []) do
      {:ok, %HTTPoison.Response{body: dates_body}} ->

        dates_hash_response = Poison.decode!(dates_body)


        hash_with_integer = Enum.map(dates_hash_response, fn v -> 
          {v["week"], v["sunday_date"]} 
        end)
        |> Map.new


        sunday_array = Enum.map(dates_hash_response, fn v -> 
          v["sunday_date"]
        end)


        [first_date | _] = dates_hash_response
        filters = [%{type: "nested", path: "topics", queries: [ %{ type: "match", field: "id", value: topic_id } ] }]

        filters = Poison.encode! filters

        grouping = [%{type: "range", key: "int_published",  opts: %{ step: 1, min: first_date["week"], max: (first_date["week"] + 23) } }]
        grouping = Poison.encode! grouping

        query = "http://categorized_data:4000/api/documents/?page_size=30&filters=" <> filters <> "&grouping=" <> grouping

        case HTTPoison.get(query, header, []) do
          {:ok, %HTTPoison.Response{body: body}} ->
            hash_response = Poison.decode!(body)
            value = first_date["week"] - 1
            hash_with_buckets_and_dates = Enum.zip(sunday_array, hash_response["buckets"]) |> Enum.into(%{})
            IO.inspect hash_with_buckets_and_dates
            response = %{weeks: Enum.map(hash_with_buckets_and_dates ,fn {k, v} -> 

              %{week: k, count: v["data"]["document_count"]} 
            end)}

            conn
            |> put_status(200)
            |> render(Bff.WormholeView, "tunnel.json", %{data: response})

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

  def get_multiple_frequency_curve(conn, %{"topics_ids" => topics_ids, "date" => date}) do
    header = [
              {"Content-Type", "application/json"}
             ]

    topics_ids = String.split(topics_ids, ",")
    case HTTPoison.get("http://business-rules:8001/dateConversion/#{date}/", header, []) do
      {:ok, %HTTPoison.Response{body: dates_body}} ->

        dates_hash_response = Poison.decode!(dates_body)


        hash_with_integer = Enum.map(dates_hash_response, fn v -> 
          {v["week"], v["sunday_date"]} 
        end)
        |> Map.new


        sunday_array = Enum.map(dates_hash_response, fn v -> 
          v["sunday_date"]
        end)


        [first_date | _] = dates_hash_response

        responses_array = %{ topics: Enum.map(topics_ids, fn topic_id ->
          filters = [%{type: "nested", path: "topics", queries: [ %{ type: "match", field: "id", value: topic_id } ] }]

          filters = Poison.encode! filters

          grouping = [%{type: "range", key: "int_published",  opts: %{ step: 1, min: first_date["week"], max: (first_date["week"] + 23) } }]
          grouping = Poison.encode! grouping

          query = "http://categorized_data:4000/api/documents/?page_size=30&filters=" <> filters <> "&grouping=" <> grouping

          case HTTPoison.get(query, header, []) do
            {:ok, %HTTPoison.Response{body: body}} ->
              hash_response = Poison.decode!(body)
              value = first_date["week"] - 1
              hash_with_buckets_and_dates = Enum.zip(sunday_array, hash_response["buckets"]) |> Enum.into(%{})
              response = %{topic_id: topic_id, weeks: Enum.map(hash_with_buckets_and_dates ,fn {k, v} -> 

                %{week: k, count: v["data"]["document_count"]} 
              end)}

            {:error, _response} ->

              %{error: "No fue posible consultar información para el topico #{topic_id}", topic_id: topic_id}
            end

          end)
        }



        conn
        |> put_status(200)
        |> render(Bff.WormholeView, "tunnel.json", %{data: responses_array})


      {:error, _response} ->
        conn
        |> put_status(401)
        |> render(Bff.ErrorView, "500.json")

    end    
  end

  def get_hot_topics(conn, %{"topics_ids" => topics_ids}) do
    header = [
              {"Content-Type", "application/json"}
             ]

    date = "2015-09-28"
    topics_ids = String.split(topics_ids, ",")

    case HTTPoison.get("http://business-rules:8001/dateConversion/#{date}/", header, []) do
      {:ok, %HTTPoison.Response{body: dates_body}} ->
        dates_hash_response = Poison.decode!(dates_body)
        [first_date| [second_date | [third_date | [fourth_date | _] ]]] = dates_hash_response

        dates_hash_response = [first_date, second_date, third_date, fourth_date]

        sunday_array = Enum.map(dates_hash_response, fn v -> 
          v["sunday_date"]
        end)

        [first_date | _] = dates_hash_response

        responses_array = %{ topics: Enum.map(topics_ids, fn topic_id ->
          filters = [%{type: "nested", path: "topics", queries: [ %{ type: "match", field: "id", value: topic_id } ] }]

          filters = Poison.encode! filters

          grouping = [%{type: "range", key: "int_published",  opts: %{ step: 1, min: first_date["week"], max: (first_date["week"] + 4) } }]
          grouping = Poison.encode! grouping

          query = "http://categorized_data:4000/api/documents/?page_size=30&filters=" <> filters <> "&grouping=" <> grouping

          case HTTPoison.get(query, header, []) do
            {:ok, %HTTPoison.Response{body: body}} ->
              hash_response = Poison.decode!(body)
              case HTTPoison.get("http://business-rules:8001/topic/#{topic_id}/", header, []) do
                {:ok, %HTTPoison.Response{body: business_body}} ->
                  
                  [business_hash_response | _] = Poison.decode!(business_body)
                  buckets = Enum.drop(hash_response["buckets"], -1)
                  buckets = Enum.drop(buckets, 1)
                  value = first_date["week"] - 1

                  counts = Enum.map(buckets ,fn v ->
                    v["data"]["document_count"]
                  end)

                  [first_elem | [second_elem | [third_elem | [ fourth_elem | _]]]] = counts

                  response = %{ topic_id: topic_id, 
                                topic_name: business_hash_response["name"],
                                coherence: business_hash_response["coherence"],
                                diff: fourth_elem - first_elem,
                                total_count: first_elem + second_elem + third_elem + fourth_elem
                              }

                {:error, _response} ->
                   %{error: "No fue posible consultar información para el topico #{topic_id}", topic_id: topic_id}

              end              

            {:error, _response} ->

              %{error: "No fue posible consultar información para el topico #{topic_id}", topic_id: topic_id}
            end

          end)
        } 

        conn
        |> put_status(200)
        |> render(Bff.WormholeView, "tunnel.json", %{data: responses_array})




      {:error, _response} ->
        conn
        |> put_status(401)
        |> render(Bff.ErrorView, "500.json")

    end    
  end


  defp check_topics_ids(conn, _) do
    if conn.params["topics_ids"] == "" do
      conn
      |> put_status(422)
      |> render(Bff.ErrorView, "401.json", %{error: "No tienes permisos para acceder a esta empresa"})
      |> Plug.Conn.halt()
    else
      conn
    end
  end


end