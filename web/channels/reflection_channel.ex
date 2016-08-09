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

#   def handle_in("submit", [0, date, text, author, published], socket) do
#     # refl = Repo.insert!(Reflection, id)
#     # changeset = Reflection.changeset(refl, %{date: date, markdown: text, author: author, published: published})
#     case Repo.insert( %Reflection{date: date, markdown: text, author: author, published: published}) do
#       {:ok, user} -> 
#         push socket, "submitted", %{resp: "ok"}
#       {:error, changeset} ->
#         push socket, "submitted", %{resp: "error"}
#     end
#     {:noreply, socket}
#   end

  def handle_in("submit", [id, date, text, author, published], socket) do
    refl = Repo.get!(Reflection, id)
    changeset = Reflection.changeset(refl, %{id: id, date: date, markdown: text, author: author, published: published})
    case Repo.update(changeset) do
      {:ok, user} -> 
        push socket, "submitted", %{resp: "ok"}
      {:error, changeset} ->
        push socket, "submitted", %{resp: "error"}
    end
    {:noreply, socket}
  end


  defp authorized?(_payload) do
    true
  end
  
end