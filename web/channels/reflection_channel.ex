require IEx
require Poison
require Ecto.Query
alias HelloPhoenix.Repo
alias HelloPhoenix.Reflection
alias HelloPhoenix.User
alias HelloPhoenix.Mailer

defmodule HelloPhoenix.ReflectionChannel do
  use HelloPhoenix.Web, :channel

  def join("reflection", payload, socket) do
    if authorized?(payload) do
      send self(), :after_join
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
   {:noreply, socket}
  end

  def handle_info({ref, {:ok, result}}, socket) do
    #reply ref, {:ok, result}
    #push socket, result
    {:noreply, socket}
  end
  
  # def handle_info({:DOWN, ref, :process, pid, :normal}, socket) do
  #   {:noreply, socket}
  # end
  
  def handle_info(unknown_messages, socket) do
    IO.inspect socket
    IO.inspect unknown_messages
    {:noreply, socket}
  end
  # {#Reference<0.0.6.987>,
  # {:ok, "{\n  \"id\": \"<20160904030916.8248.64073.6c5c5.mailgun.org>\",\n  \"message\": \"Queued. Thank you.\"\n}"}
    
  # },
  # def handle_info(_, socket) do
  #   {:noreply, socket}
  # end

#   def handle_in("reset", id, socket) do
#     {id, date, author, markdown, published} = 
#       Repo.one( from r in Reflection, 
#                 where: ^id == r.id, 
#                 select: {r.id, r.date, r.author, r.markdown, r.published})
#       push socket, "reflection", %{id: id, date: date, author: author, text: markdown, published: published}
#     {:noreply, socket}
#   end
  # %Reflection{date: reflection["date"], markdown: reflection["markdown"]
  def handle_in("login", user_params, socket) do
    user_email = String.downcase(user_params["email"])
    user_struct =
      case Repo.get_by(User, email: user_email) do
        nil -> %User{email: user_email}
        user -> user
      end
      |> User.registration_changeset(user_params)
      
    case Repo.insert_or_update(user_struct) do
      {:ok, user} ->
        Task.async(fn -> Mailer.send_login_token(user) end)
        #{:reply, {:ok, user}, socket}
        {:noreply, socket}
        # conn
        # |> put_flash(:info, "We sent you a link to create an account. Please check your inbox.")
        # |> redirect(to: page_path(conn, :index))
        
      {:error, changeset} ->
        {:reply, :error, socket}
      # {:ok, _} ->
      #   conn
      #   |> put_flash(:info, "We sent you a link to create an account. Please check your inbox.")
      #   |> redirect(to: page_path(conn, :index))
      # {:error, changeset} ->
      #   render(conn, "new.html", changeset: changeset)
    end
  end
  
  def handle_in("logout", _params, socket) do
  end
  # def delete(conn, _params) do
  #   conn
  #   |> PasswordlessLoginApp.SimpleAuth.logout()
  #   |> put_flash(:info, "User logged out.")
  #   |> redirect(to: page_path(conn, :index))
  # end
  
  # def create(conn, %{"user" => user_params}) do
  #   user_email = String.downcase(user_params["email"])
  #   user_struct =
  #     case Repo.get_by(User, email: user_email) do
  #       nil -> %User{email: user_email}
  #       user -> user
  #     end
  #     |> User.registration_changeset(user_params)
  
  #   case Repo.insert_or_update(user_struct) do
  #     {:ok, changeset} ->
  #       {:reply, {:ok, changeset}, socket}
  #       # conn
  #       # |> put_flash(:info, "We sent you a link to create an account. Please check your inbox.")
  #       # |> redirect(to: page_path(conn, :index))
  #     {:error, changeset} ->
  #       {:reply, :error, socket}
  #       #render(conn, "new.html", changeset: changeset)
    
  #       if changeset.valid? do
  #         Repo.insert!(changeset)
  #         {:reply, {:ok, changeset}, socket}
  #       else
  #         {:reply,{:error, MyApp.ChangesetView.render("errors.json",
  #           %{changeset: changeset}), socket}
  #       end
  #   end
  # end
  

  def handle_in("submit", reflection, socket) do
    # refl = Repo.insert!(Reflection, id)
    # changeset = Reflection.changeset(refl, %{date: date, markdown: text, author: author, published: published})
    #changeset = Reflection.changeset(%Reflection{}, :empty)

    # if changeset.valid? do
    #   Repo.insert!(changeset)

    case Repo.insert( %Reflection{date: reflection["date"], markdown: reflection["markdown"], author: reflection["author"], published: reflection["published"]}) do
      {:ok, reflection} ->
        { :reply, {:reply, %{resp: "yadda yadda"}}, socket }
        # proper example -> {:reply, {:ok, %{kind: "private", from: "server", body: user_list}}, socket}
        # needs to return a response formatted like this: {:reply, {status :: atom, response :: map}, Socket.t}
        
        #push socket, "submitted", %{resp: "ok"}
      #{:error, changeset} ->
        #{:reply, :error, socket}
        #push socket, "submitted", %{resp: "error"}
    end
    #{:noreply, socket}
  end

#   def handle_in("submit", {msg, cb_data}, socket) do
#     refl = Repo.get!(msg.id)
#     changeset = Reflection.changeset(refl, %{id: msg.id, date: msg.date, markdown: msg.markdown, author: msg.author, published: msg.published})
#     case Repo.update(changeset) do
#       {:ok, user} -> 
#         push socket, "submitted", %{resp: "ok"}
#       {:error, changeset} ->
#         push socket, "submitted", %{resp: "error"}
#     end
#     {:noreply, socket}
#   end


  defp authorized?(_payload) do
    true
  end
  
end