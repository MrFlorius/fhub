defmodule Fhub.AccountsTest do
  use Fhub.DataCase

  alias Fhub.Accounts

  describe "users" do
    alias Fhub.Accounts.User

    @valid_attrs %{email: "an email", name: "a user"}
    @update_attrs %{name: "updated"}
    @invalid_attrs %{email: nil, name: nil}

    test "list_users/1 returns all users" do
      root = root_fixture()
      %User{id: id} = user_fixture(root)

      assert {:ok, [%User{id: ^id}]} = Accounts.list_users(root)
    end

    test "get_user!/2 returns the user with given id" do
      root = root_fixture()
      %User{id: id} = user_fixture(root)

      assert Accounts.get_user!(id, root).id == id
    end

    test "create_user/3 with valid data creates a user" do
      root = root_fixture()

      assert {:ok, %{email: "an email", name: "a user"}} = Accounts.create_user(@valid_attrs, root, root)
    end

    test "create_user/3 with invalid data returns error changeset" do
      root = root_fixture()

      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs, root, root)
    end

    test "update_user/3 with valid data updates the user" do
      root = root_fixture()
      user = user_fixture(root)

      assert {:ok, %{name: "updated"}} = Accounts.update_user(user, @update_attrs, root)
    end

    test "update_user/3 with invalid data returns error changeset" do
      root = root_fixture()
      user = user_fixture(root)

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs, root)
      assert user.name == Accounts.get_user!(user.id, root).name
    end

    test "delete_user/2 deletes the user" do
      root = root_fixture()
      user = user_fixture(root)

      assert {:ok, %User{}} = Accounts.delete_user(user, root)
      assert Accounts.get_user!(user.id, root) == nil
    end

    test "change_user/1 returns a user changeset" do
      root = root_fixture()
      user = user_fixture(root)

      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
