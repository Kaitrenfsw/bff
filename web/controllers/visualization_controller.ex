defmodule Bff.VisualizationController do
  use Bff.Web, :controller



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


  # def get_hot_topics(conn, %{"topics_ids" => topics_ids}) do
  #   header = [
  #             {"Content-Type", "application/json"}
  #            ]

  #   date = "2015-09-28"

  #   case HTTPoison.get("http://business-rules:8001/dateConversion/#{date}/", header, []) do
  #     {:ok, %HTTPoison.Response{body: dates_body}} ->
  #       dates_hash_response = Poison.decode!(dates_body)
  #       [first_date| [second_date | [third_date | [fourth_date | _] ]]] = dates_hash_response

  #       dates_hash_response = [first_date, second_date, third_date, fourth_date]

  #       hash_with_integer = Enum.map(dates_hash_response, fn v -> 
  #         {v["week"], v["sunday_date"]} 
  #       end)
  #       |> Map.new


  #       [first_date | _] = dates_hash_response
  #       filters = [%{type: "nested", path: "topics", queries: [ %{ type: "match", field: "id", value: topic_id } ] }]

  #       filters = Poison.encode! filters

  #       grouping = [%{type: "range", key: "int_published",  opts: %{ step: 1, min: first_date["week"], max: (first_date["week"] + 4) } }]
  #       grouping = Poison.encode! grouping

  #       query = "http://categorized_data:4000/api/documents/?page_size=30&filters=" <> filters <> "&grouping=" <> grouping

  #       case HTTPoison.get(query, header, []) do
  #         {:ok, %HTTPoison.Response{body: body}} ->
  #           hash_response = Poison.decode!(body)
  #           value = first_date["week"] - 1

  #           response = %{weeks: Enum.map(hash_response["buckets"], fn v -> 
  #             value = value + 1
  #             %{week: hash_with_integer[round(value)], count: v["data"]["document_count"]} 
  #           end)}

  #           conn
  #           |> put_status(200)
  #           |> render(Bff.WormholeView, "tunnel.json", %{data: response})

  #         {:error, _response} ->
  #           conn
  #           |> put_status(401)
  #           |> render(Bff.ErrorView, "500.json")

  #       end 
  #     {:error, _response} ->
  #       conn
  #       |> put_status(401)
  #       |> render(Bff.ErrorView, "500.json")

  #   end    
  # end


end