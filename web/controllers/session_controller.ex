defmodule HelloPhoenix.SessionController do
  use HelloPhoenix.Web, :controller
  alias HelloPhoenix.{User, Repo, SimpleAuth}
  
  def show(conn, %{"id" => access_token}) do
    case Repo.get_by(User, access_token: access_token) do
      nil ->
        conn
        |> put_flash(:error, "Access token not found or expired.")
        |> redirect(to: page_path(conn, :index))
      user ->
        conn
        |> SimpleAuth.login(user)
        |> put_flash(:info, "Welcome #{user.email}")
        |> redirect(to: page_path(conn, :index))
    end
  end
end