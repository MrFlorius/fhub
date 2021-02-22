defmodule Fhub.AppsTest do
  use Fhub.DataCase

  alias Fhub.Apps

  describe "apps" do
    alias Fhub.Apps.App

    @valid_attrs %{name: "an app"}
    @update_attrs %{name: "updated"}
    @invalid_attrs %{name: ""}

    def app_fixture(root) do
      {:ok, app} = Apps.create_app(@valid_attrs, root, root)

      app
    end

    test "list_funtions/2 returns nothing" do
      root = root_fixture()
      app = app_fixture(root)

      assert {:ok, []} = Apps.list_functions(app, root)
    end

    test "list_documents/2 returns nothing" do
      root = root_fixture()
      app = app_fixture(root)

      assert {:ok, []} = Apps.list_documents(app, root)
    end

    test "list_apps/1 returns all apps" do
      root = root_fixture()
      %App{id: id} = app_fixture(root)

      assert {:ok, [%App{id: ^id}]} = Apps.list_apps(root)
    end

    test "get_app!/1 returns the app with given id" do
      root = root_fixture()
      %App{id: id} = app_fixture(root)

      assert Apps.get_app!(id, root).id == id
    end

    test "create_app/1 with valid data creates a app" do
      root = root_fixture()

      assert {:ok, %{name: "an app"}} = Apps.create_app(@valid_attrs, root, root)
    end

    test "create_app/1 with invalid data returns error changeset" do
      root = root_fixture()

      assert {:error, %Ecto.Changeset{}} = Apps.create_app(@invalid_attrs, root, root)
    end

    test "update_app/2 with valid data updates the app" do
      root = root_fixture()
      app = app_fixture(root)

      assert {:ok, %{name: "updated"}} = Apps.update_app(app, @update_attrs, root)
    end

    test "update_app/2 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)

      assert {:error, %Ecto.Changeset{}} = Apps.update_app(app, @invalid_attrs, root)
      assert app.name == Apps.get_app!(app.id, root).name
    end

    test "delete_app/1 deletes the app" do
      root = root_fixture()
      app = app_fixture(root)

      assert {:ok, %App{}} = Apps.delete_app(app, root)
      assert Apps.get_app!(app.id, root) == nil
    end

    test "change_app/1 returns a app changeset" do
      root = root_fixture()
      app = app_fixture(root)

      assert %Ecto.Changeset{} = Apps.change_app(app)
    end
  end
end
