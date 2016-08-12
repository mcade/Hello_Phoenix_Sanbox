require IEx
require Poison
require Ecto.Query
alias HelloPhoenix.Repo
alias HelloPhoenix.Reflection

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

#   def handle_in("reset", id, socket) do
#     {id, date, author, markdown, published} = 
#       Repo.one( from r in Reflection, 
#                 where: ^id == r.id, 
#                 select: {r.id, r.date, r.author, r.markdown, r.published})
#       push socket, "reflection", %{id: id, date: date, author: author, text: markdown, published: published}
#     {:noreply, socket}
#   end

  def handle_in("submit", reflection, socket) do
    # refl = Repo.insert!(Reflection, id)
    # changeset = Reflection.changeset(refl, %{date: date, markdown: text, author: author, published: published})
    #changeset = Reflection.changeset(%Reflection{}, :empty)

    # if changeset.valid? do
    #   Repo.insert!(changeset)

    case Repo.insert( %Reflection{date: reflection["date"], markdown: reflection["markdown"], author: reflection["author"], published: reflection["published"]}) do
      {:ok, reflection} ->
        { :reply, :ok, socket }
        #{ :reply, %{resp: "ok"}, socket}
        #{:reply, :ok, socket}
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