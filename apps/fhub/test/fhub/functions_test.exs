defmodule Fhub.FunctionsTest do
  use Fhub.DataCase

  alias Fhub.Functions

  describe "functions" do
    alias Fhub.Functions.Function

    @valid_attrs %{name: "a function"}
    @update_attrs %{name: "updated"}
    @invalid_attrs %{name: ""}

    test "list_functions/1 returns all functions" do
      root = root_fixture()
      app = app_fixture(root)
      %Function{id: id} = function_fixture(app, root)

      assert {:ok, [%Function{id: ^id}]} = Functions.list_functions(root)
    end

    test "get_function!/2 returns the function with given id" do
      root = root_fixture()
      app = app_fixture(root)
      %Function{id: id} = function_fixture(app, root)

      assert Functions.get_function!(id, root).id == id
    end

    test "create_function/3 with valid data creates a function" do
      root = root_fixture()
      app = app_fixture(root)

      assert {:ok, %{name: "a function"}} = Functions.create_function(@valid_attrs, root, app)
    end

    test "create_function/3 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)

      assert {:error, %Ecto.Changeset{}} = Functions.create_function(@invalid_attrs, root, app)
    end

    test "update_function/3 with valid data updates the function" do
      root = root_fixture()
      app = app_fixture(root)
      function = function_fixture(app, root)

      assert {:ok, %{name: "updated"}} = Functions.update_function(function, @update_attrs, root)
    end

    test "update_function/3 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      function = function_fixture(app, root)

      assert {:error, %Ecto.Changeset{}} =
               Functions.update_function(function, @invalid_attrs, root)

      assert function.name == Functions.get_function!(function.id, root).name
    end

    test "delete_function/2 deletes the function" do
      root = root_fixture()
      app = app_fixture(root)
      function = function_fixture(app, root)

      assert {:ok, %Function{}} = Functions.delete_function(function, root)
      assert Functions.get_function!(function.id, root) == nil
    end

    test "change_function/2 returns a function changeset" do
      root = root_fixture()
      app = app_fixture(root)
      function = function_fixture(app, root)

      assert %Ecto.Changeset{} = Functions.change_function(function)
    end
  end

  describe "versions" do
    alias Fhub.Functions.Version

    @valid_attrs %{version: 1, code: "fn x -> x end"}
    @update_attrs %{code: "fn x -> nil end"}
    @invalid_attrs %{code: "fn x -> a end"}

    test "list_versions/2 returns all versions for function" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      %Version{id: id} = version_fixture(fun, root)

      assert {:ok, [%Version{id: ^id}]} = Functions.list_versions(fun, root)
    end

    test "list_versions/1 returns all versions" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      %Version{id: id} = version_fixture(fun, root)

      assert {:ok, [%Version{id: ^id}]} = Functions.list_versions(root)
    end

    test "get_version!/2 returns the version with given id" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      %Version{id: id} = version_fixture(fun, root)

      assert Functions.get_version!(id, root).id == id
    end

    test "create_version/3 with valid data creates a version" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)

      assert {:ok, %{version: 1}} = Functions.create_version(@valid_attrs, root, fun)
    end

    test "create_version/3 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)

      assert {:error, %Ecto.Changeset{}} = Functions.create_version(@invalid_attrs, root, fun)
    end

    test "update_version/3 with valid data updates the version" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)

      assert {:ok, _} = Functions.update_version(version, @update_attrs, root)
    end

    test "update_version/3 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)

      assert {:error, %Ecto.Changeset{}} = Functions.update_version(version, @invalid_attrs, root)
      assert version.code == Functions.get_version!(version.id, root).code
    end

    test "delete_version/2 deletes the version" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)

      assert {:ok, %Version{}} = Functions.delete_version(version, root)
      assert Functions.get_version!(version.id, root) == nil
    end

    test "change_version/2 returns a version changeset" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)

      assert %Ecto.Changeset{} = Functions.change_version(version)
    end
  end

  describe "calls" do
    alias Fhub.Functions.Call

    @valid_attrs %{opts: %{}}
    @update_attrs %{opts: %{smth: 1}}
    @invalid_attrs %{opts: nil}

    test "list_calls/2 returns all calls for funtion" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)
      %Call{id: id} = call_fixture(version, root)

      assert {:ok, [%Call{id: ^id}]} = Functions.list_calls(fun, root)
    end

    test "list_calls/2 returns all calls for version" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)
      %Call{id: id} = call_fixture(version, root)

      assert {:ok, [%Call{id: ^id}]} = Functions.list_calls(version, root)
    end

    test "list_calls/1 returns all calls" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)
      %Call{id: id} = call_fixture(version, root)

      assert {:ok, [%Call{id: ^id}]} = Functions.list_calls(root)
    end

    test "get_call!/2 returns the calll with given id" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)
      %Call{id: id} = call_fixture(version, root)

      assert Functions.get_call!(id, root).id == id
    end

    test "create_call/3 with valid data creates a call" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)

      assert {:ok, %{opts: %{}, result: %{}}} = Functions.create_call(@valid_attrs, root, version)
    end

    test "create_call/3 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)

      assert {:error, %Ecto.Changeset{}} = Functions.create_call(@invalid_attrs, root, version)
    end

    test "create_call/3 with deleted version returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)

      Functions.delete_version(version, root)

      assert {:error, %Ecto.Changeset{}} = Functions.create_call(@valid_attrs, root, version)
    end

    test "create_call/3 with runtime error in version creates a call with error in it" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)

      {:ok, version} =
        Functions.create_version(%{version: 1, code: "fn x -> :a.b(x) end"}, root, fun)

      assert {:ok,
              %{
                result: %{
                  error: %UndefinedFunctionError{
                    arity: 1,
                    function: :b,
                    message: nil,
                    module: :a,
                    reason: nil
                  }
                }
              }} = Functions.create_call(@valid_attrs, root, version)
    end

    test "update_call/3 with valid data updates the call" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)
      call = call_fixture(version, root)

      assert {:ok, %{opts: %{smth: 1}, result: %{smth: 1}}} =
               Functions.update_call(call, @update_attrs, root)
    end

    test "update_call/3 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)
      call = call_fixture(version, root)

      assert {:error, %Ecto.Changeset{}} = Functions.update_call(call, @invalid_attrs, root)
      assert call.opts == Functions.get_call!(call.id, root).opts
    end

    test "delete_call/2 deletes the call" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)
      call = call_fixture(version, root)

      assert {:ok, %Call{}} = Functions.delete_call(call, root)
      assert Functions.get_call!(call.id, root) == nil
    end

    test "change_call/2 returns a call changeset" do
      root = root_fixture()
      app = app_fixture(root)
      fun = function_fixture(app, root)
      version = version_fixture(fun, root)
      call = call_fixture(version, root)

      assert %Ecto.Changeset{} = Functions.change_call(call)
    end
  end
end
