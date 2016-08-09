defmodule HelloPhoenix.ReflectionTest do
  use HelloPhoenix.ModelCase

  alias HelloPhoenix.Reflection

  @valid_attrs %{author: "some content", date: "some content", markdown: "some content", published: true, read_cnt: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Reflection.changeset(%Reflection{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Reflection.changeset(%Reflection{}, @invalid_attrs)
    refute changeset.valid?
  end
end
