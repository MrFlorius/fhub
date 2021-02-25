defmodule Fhub.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use Fhub.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Fhub.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Fhub.DataCase

      def resource_fixture(attrs \\ %{}) do
        {:ok, resource} =
          attrs
          |> Enum.into(%{name: "a resource"})
          |> Fhub.Resources.create_resource()

        resource
      end

      def root_fixture() do
        {:ok, root} = Fhub.Resources.create_resource(%{name: "root"})

        {:ok, root_permission} =
          Fhub.AccessControl.create_permission(%{
            can: [Fhub.AccessControl.Permission.access_any()],
            resource_id: root.id
          })

        {:ok, _} = Fhub.AccessControl.add_actors(root_permission, [root])

        root
      end

      def app_fixture(root) do
        {:ok, app} = Fhub.Apps.create_app(%{name: "an app"}, root, root)

        app
      end

      def document_fixture(app_or_doc, root) do
        {:ok, document} = Fhub.Documents.create_document(%{name: "a document"}, root, app_or_doc)

        document
      end

      def decimal_fixture(document, root) do
        {:ok, decimal} =
          Fhub.Documents.create_decimal(%{name: "a decimal", value: 5}, root, document)

        decimal
      end

      def file_fixture(document, root) do
        {:ok, file} =
          Fhub.Documents.create_file(
            %{
              name: "a file",
              file: %Plug.Upload{
                content_type: "image/gif",
                filename: "test.gif",
                path: "test/support/resources/test.gif"
              }
            },
            root,
            document
          )

        file
      end

      def json_fixture(document, root) do
        {:ok, decimal} = Fhub.Documents.create_json(%{name: "a json", value: %{}}, root, document)

        decimal
      end

      def string_fixture(document, root) do
        {:ok, decimal} =
          Fhub.Documents.create_string(%{name: "a string", value: "smth"}, root, document)

        decimal
      end

      def function_fixture(app, root) do
        {:ok, function} = Fhub.Functions.create_function(%{name: "a function"}, root, app)

        function
      end

      def version_fixture(function, root) do
        {:ok, version} =
          Fhub.Functions.create_version(%{version: 1, code: "fn x -> x end"}, root, function)

        version
      end

      def call_fixture(version, root) do
        {:ok, call} = Fhub.Functions.create_call(%{opts: %{}}, root, version)

        call
      end

      def user_fixture(root) do
        {:ok, user} = Fhub.Accounts.create_user(%{email: "an email", name: "a user"}, root, root)

        user
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fhub.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Fhub.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
