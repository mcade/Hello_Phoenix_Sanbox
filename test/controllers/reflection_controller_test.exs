defmodule HelloPhoenix.ReflectionControllerTest do
  use HelloPhoenix.ConnCase

  alias HelloPhoenix.Reflection
  @valid_attrs %{author: "some content", date: "some content", markdown: "some content", published: true, read_cnt: 42}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, reflection_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing reflections"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, reflection_path(conn, :new)
    assert html_response(conn, 200) =~ "New reflection"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, reflection_path(conn, :create), reflection: @valid_attrs
    assert redirected_to(conn) == reflection_path(conn, :index)
    assert Repo.get_by(Reflection, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, reflection_path(conn, :create), reflection: @invalid_attrs
    assert html_response(conn, 200) =~ "New reflection"
  end

  test "shows chosen resource", %{conn: conn} do
    reflection = Repo.insert! %Reflection{}
    conn = get conn, reflection_path(conn, :show, reflection)
    assert html_response(conn, 200) =~ "Show reflection"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, reflection_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    reflection = Repo.insert! %Reflection{}
    conn = get conn, reflection_path(conn, :edit, reflection)
    assert html_response(conn, 200) =~ "Edit reflection"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    reflection = Repo.insert! %Reflection{}
    conn = put conn, reflection_path(conn, :update, reflection), reflection: @valid_attrs
    assert redirected_to(conn) == reflection_path(conn, :show, reflection)
    assert Repo.get_by(Reflection, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    reflection = Repo.insert! %Reflection{}
    conn = put conn, reflection_path(conn, :update, reflection), reflection: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit reflection"
  end

  test "deletes chosen resource", %{conn: conn} do
    reflection = Repo.insert! %Reflection{}
    conn = delete conn, reflection_path(conn, :delete, reflection)
    assert redirected_to(conn) == reflection_path(conn, :index)
    refute Repo.get(Reflection, reflection.id)
  end
end
