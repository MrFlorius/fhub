defmodule Fhub.ResourcesTest do
  use Fhub.DataCase

  alias Fhub.Resources

  describe "resources" do
    alias Fhub.Resources.Resource

    @valid_attrs %{name: "a resource"}
    @update_attrs %{name: "an updated resource"}
    @invalid_attrs %{name: 1}

    test "list_resources/0 returns all resources" do
      resource = resource_fixture()
      assert Resources.list_resources() == [resource]
    end

    test "get_resource!/1 returns the resource with given id" do
      resource = resource_fixture()
      assert Resources.get_resource!(resource.id) == resource
    end

    test "create_resource/1 with valid data creates a resource" do
      assert {:ok, %Resource{} = resource} = Resources.create_resource(@valid_attrs)
      assert resource.name == @valid_attrs.name
    end

    test "create_resource/1 with inivalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_resource(@invalid_attrs)
    end

    test "update_resource/2 with valid data updates the resource" do
      resource = resource_fixture()
      assert {:ok, %Resource{} = resource} = Resources.update_resource(resource, @update_attrs)
      assert resource.name == @update_attrs.name
    end

    test "update_resource/2 with invalid data returns error changeset" do
      resource = resource_fixture()

      assert {:error, %Ecto.Changeset{}} = Resources.update_resource(resource, @invalid_attrs)
      assert resource.name == Resources.get_resource!(resource.id).name
    end

    test "delete_resource/1 deletes the resource" do
      resource = resource_fixture()
      assert {:ok, %Resource{}} = Resources.delete_resource(resource)
      assert_raise Ecto.NoResultsError, fn -> Resources.get_resource!(resource.id) end
    end

    test "change_resource/1 returns a resource changeset" do
      resource = resource_fixture()
      assert %Ecto.Changeset{} = Resources.change_resource(resource)
    end
  end

  describe "tree" do

  end

  describe "path" do
    alias Fhub.Resources.Path

    test "reduce_to_names/1 returns {nil, names} for names only list" do
      assert {nil, ["1", "2"]} = Path.reduce_to_names([name: "1", name: "2"])
      assert {nil, ["1", "2"]} = Path.reduce_to_names(["1", "2"])
    end

    test "reduce_to_names/1 returns {id, names} for names and ids list" do
      assert {1, ["1", "2"]} = Path.reduce_to_names([id: 1, name: "1", name: "2"])
      assert {1, ["1", "2"]} = Path.reduce_to_names(["smth", id: 1, name: "1", name: "2"])
    end

    test "get_resource_by_path/1 with correct returns resource" do
      %{id: id1} = resource_fixture(%{name: "r1"})
      %{id: id2} = resource_fixture(%{name: "r2", parent_id: id1})
      %{id: id3} = resource_fixture(%{name: "r3", parent_id: id1})
      %{id: id4} = resource_fixture(%{name: "r4", parent_id: id3})

      assert {:ok, %{id: ^id1}} = Resources.get_resource_by_path(["r1"])
      assert {:ok, %{id: ^id2}} = Resources.get_resource_by_path(["r1", "r2"])
      assert {:ok, %{id: ^id3}} = Resources.get_resource_by_path(["r1", "r3"])
      assert {:ok, %{id: ^id4}} = Resources.get_resource_by_path(["r1", "r3", "r4"])

      assert {:ok, %{id: ^id4}} = Resources.get_resource_by_path(name: "r1", name: "r3", name: "r4")

      assert {:ok, %{id: ^id1}} = Resources.get_resource_by_path(id: id1)
      assert {:ok, %{id: ^id2}} = Resources.get_resource_by_path(id: id1, name: "r2")
      assert {:ok, %{id: ^id2}} = Resources.get_resource_by_path(name: "r1", id: id2)
    end

    test "get_resource_by_path/1 with incorrect path returns error" do
      assert {:error, :does_not_exists} = Resources.get_resource_by_path(name: "any")
    end
  end
end
