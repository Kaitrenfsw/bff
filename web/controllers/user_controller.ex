defmodule Bff.UserController do
  use Bff.Web, :controller

  def login(conn, %{"email" => email, "password" => password}) do
    IO.inspect email
    IO.inspect "hola"
    IO.inspect password
    IO.inspect "hola"
    user = %{email: email, password: password}

    conn
    |> put_status(200)
    |> render(Bff.UserView, "login.json")
  end

end