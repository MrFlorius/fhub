defmodule Fhub.AccessControlTest do
  use Fhub.DataCase

  alias Fhub.Resources
  alias Fhub.Accounts
  alias Fhub.AccessControl
  alias Fhub.AccessControl.Checker

  describe "permissions" do
    alias Fhub.AccessControl.Permission

    @valid_attrs %{resource: %{}, can: [:some]}
    @update_attrs %{can: [:other]}
    @invalid_attrs %{resource_id: %{}, can: nil}

    def permission_fixture(attrs \\ %{}) do
      {:ok, permission} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AccessControl.create_permission()

      permission
    end

    def context_resource_fixture() do
      {:ok, resource} = Resources.create_resource()
      resource
    end

    test "list_permissions/0 returns all permissions" do
      permission = permission_fixture()
      assert AccessControl.list_permissions() == [permission]
    end

    test "get_permission!/1 returns the permission with given id" do
      permission = permission_fixture()
      assert AccessControl.get_permission!(permission.id) == permission
    end

    test "create_permission/1 with valid data creates a permission" do
      assert {:ok, %Permission{} = permission} = AccessControl.create_permission(@valid_attrs)
      assert permission.can == @valid_attrs.can
    end

    test "create_permission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AccessControl.create_permission(@invalid_attrs)
    end

    test "update_permission/2 with valid data updates the permission" do
      permission = permission_fixture()

      assert {:ok, %Permission{} = permission} =
               AccessControl.update_permission(permission, @update_attrs)

      assert permission.can == @update_attrs.can
    end

    test "update_permission/2 with invalid data returns error changeset" do
      permission = permission_fixture()

      assert {:error, %Ecto.Changeset{}} =
               AccessControl.update_permission(permission, @invalid_attrs)

      assert permission == AccessControl.get_permission!(permission.id)
    end

    test "delete_permission/1 deletes the permission" do
      permission = permission_fixture()
      assert {:ok, %Permission{}} = AccessControl.delete_permission(permission)
      assert_raise Ecto.NoResultsError, fn -> AccessControl.get_permission!(permission.id) end
    end

    test "change_permission/1 returns a permission changeset" do
      permission = permission_fixture()
      assert %Ecto.Changeset{} = AccessControl.change_permission(permission, %{can: [:read]})
    end

    test "change_permission/0 returns a permission changeset" do
      permission = permission_fixture()
      assert %Ecto.Changeset{} = AccessControl.change_permission(permission)
    end

    test "add_actors/2 actually adds actors" do
      permission = permission_fixture()
      actor = context_resource_fixture()
      {:ok, %{actors: a}} = AccessControl.add_actors(permission, [actor])

      assert length(a) == 1
    end

    test "remove_actors/2 actually removes actors" do
      permission = permission_fixture()
      actor = context_resource_fixture()

      {:ok, %{actors: a}} = AccessControl.remove_actors(permission, [actor])
      assert length(a) == 0

      AccessControl.add_actors(permission, [actor])

      {:ok, %{actors: b}} = AccessControl.remove_actors(permission, [actor])
      assert length(b) == 0
    end

    test "assign_actors/2 actually assigns actors" do
      permission = permission_fixture()
      actor = context_resource_fixture()

      {:ok, %{actors: a}} = AccessControl.assign_actors(permission, [actor])
      assert length(a) == 1

      {:ok, %{actors: a}} = AccessControl.assign_actors(permission, [])
      assert length(a) == 0
    end
  end

  describe "checker" do
    def fixture() do
      # creating resources
      {:ok, root} = Resources.create_resource(%{name: "root"})
      {:ok, accounts} = Resources.create_resource(%{name: "accounts", parent_id: root.id})

      # creating permissions

      {:ok, root_permission} =
        AccessControl.create_permission(%{
          can: [AccessControl.Permission.access_any()],
          resource_id: root.id
        })

      {:ok, user_permission} =
        AccessControl.create_permission(%{
          can: [:read],
          resource_id: root.id
        })

      {:ok, _} = AccessControl.add_actors(root_permission, [root])

      # creating users
      {:ok, user} =
        Accounts.create_user(
          %{
            resource: %{parent_id: accounts.id},
            name: "florius",
            email: "vadim.tsvetkov80@gmail.com"
          },
          root
        )

      {:ok, _} = AccessControl.add_actors(user_permission, [user])

      %{resources: %{root: root, accounts: accounts}, actors: [user, root]}
    end

    test "check?/3 returns valid results" do
      %{resources: %{root: root, accounts: accounts}, actors: [user, root]} = fixture()

      assert Checker.check?(root, root, :read)
      assert Checker.check?(accounts, root, :read)

      assert not Checker.check?(root, user, :delete)
      assert Checker.check?(root, user, :read)
    end

    test "permit/3 works" do
      %{resources: %{root: root, accounts: accounts}, actors: [user, root]} = fixture()

      assert Checker.permit(root, root, :read) == {:ok, root}
      assert Checker.permit(accounts, root, :read) == {:ok, accounts}

      assert Checker.permit(root, user, :delete) == {:error, :forbidden}
      assert Checker.permit(root, user, :read) == {:ok, root}
    end
  end

  describe "context exports" do
    test "TestContext case #1 got all functions defined" do
      defmodule TestContext1 do
        use Elixir.Fhub.AccessControl.Context,
          for: Elixir.Fhub.Resources.Resource,
          resource_parent: "some"
      end

      assert TestContext1.__info__(:functions) == [
               {:build_resource_for_resource, 3},
               {:cast_resource_for_resource, 2},
               {:change_resource, 1},
               {:change_resource, 2},
               {:change_resource_create, 1},
               {:change_resource_create, 2},
               {:change_resource_update, 1},
               {:change_resource_update, 2},
               {:create_resource, 1},
               {:create_resource, 2},
               {:create_resource, 3},
               {:delete_resource, 2},
               {:get_resource, 2},
               {:get_resource!, 2},
               {:list_resources, 1},
               {:update_resource, 3}
             ]
    end

    test "TestContext case #2 got all functions defined" do
      defmodule TestContext2 do
        use Elixir.Fhub.AccessControl.Context,
          for: Elixir.Fhub.Resources.Resource,
          resource_parent: "some",
          single: "some_resource",
          plural: "resourceces"
      end

      assert TestContext2.__info__(:functions) == [
               {:build_resource_for_some_resource, 3},
               {:cast_resource_for_some_resource, 2},
               {:change_some_resource, 1},
               {:change_some_resource, 2},
               {:change_some_resource_create, 1},
               {:change_some_resource_create, 2},
               {:change_some_resource_update, 1},
               {:change_some_resource_update, 2},
               {:create_some_resource, 1},
               {:create_some_resource, 2},
               {:create_some_resource, 3},
               {:delete_some_resource, 2},
               {:get_some_resource, 2},
               {:get_some_resource!, 2},
               {:list_resourceces, 1},
               {:update_some_resource, 3}
             ]
    end

    test "TestContext case #3 got all functions defined" do
      defmodule TestContext3 do
        use Elixir.Fhub.AccessControl.Context,
          for: Elixir.Fhub.Resources.Resource
      end

      assert TestContext3.__info__(:functions) == [
               {:build_resource_for_resource, 3},
               {:cast_resource_for_resource, 2},
               {:change_resource, 1},
               {:change_resource, 2},
               {:change_resource_create, 1},
               {:change_resource_create, 2},
               {:change_resource_update, 1},
               {:change_resource_update, 2},
               {:create_resource, 3},
               {:delete_resource, 2},
               {:get_resource, 2},
               {:get_resource!, 2},
               {:list_resources, 1},
               {:update_resource, 3}
             ]
    end
  end

  # Not sure about tests' structure
  describe "context logic" do
    @valid_attrs %{email: "email", name: "name"}
    @update_attrs %{email: "new"}

    defmodule TestContext do
      use Elixir.Fhub.AccessControl.Context,
        for: Elixir.Fhub.Accounts.User,
        single: "resource",
        resource_parent: "root"
    end

    def context_resource_fixture(root) do
      {:ok, resource} = TestContext.create_resource(@valid_attrs, root)
      resource
    end

    test "build_resource_for_resource/3 returns proper resource" do
      root = root_fixture()
      root_id = root.id

      assert match?(
               %{parent_id: ^root_id},
               TestContext.build_resource_for_resource(root, nil, nil)
             )
    end

    test "change_resource/2 returns changeset" do
      assert match?(%Ecto.Changeset{}, TestContext.change_resource(%Accounts.User{}, %{}))
    end

    test "create_resource/2 creates resource if actor has permission" do
      root = root_fixture()

      assert match?({:ok, _}, TestContext.create_resource(@valid_attrs, root))
    end

    test "delete_resource/2 deletes resource if actor has permission" do
      root = root_fixture()
      resource = context_resource_fixture(root)

      assert match?({:ok, _}, TestContext.delete_resource(resource, root))
    end

    test "get_resource/2 returns resource if actor has access to" do
      root = root_fixture()
      resource = context_resource_fixture(root)

      assert match?({:ok, _}, TestContext.get_resource(resource.id, root))
    end

    test "get_resource!/2 returns nil if resource does not exsists" do
      root = root_fixture()

      assert TestContext.get_resource!("e1d42ed2-9b1d-4145-8d3a-c601dedeb797", root) == nil
    end

    test "list_resources/1 returns all resources to which actor has access" do
      root = root_fixture()
      resource = context_resource_fixture(root)

      {:ok, [r]} = TestContext.list_resources(root)

      assert r.id == resource.id
    end

    test "update_resource/3 updates a resource to which actor has access" do
      root = root_fixture()
      resource = context_resource_fixture(root)

      assert match?(
               {:ok, @update_attrs},
               TestContext.update_resource(resource, @update_attrs, root)
             )
    end
  end

  describe "transactions" do
  end
end
