defmodule Fhub.DocumentsTest do
  use Fhub.DataCase

  alias Fhub.Documents

  describe "documents" do
    alias Fhub.Documents.Document

    @valid_attrs %{name: "a document"}
    @update_attrs %{name: "updated"}
    @invalid_attrs %{name: ""}

    test "list_documents/2 returns all documents for app" do
      root = root_fixture()
      app = app_fixture(root)
      %Document{id: id} = document_fixture(app, root)

      assert {:ok, [%Document{id: ^id}]} = Documents.list_documents(app, root)
    end

    test "list_documents/2 returns all documents for document" do
      root = root_fixture()
      app = %{id: _app_id} = app_fixture(root)
      doc = %{id: _doc_id} = document_fixture(app, root)
      doc2 = %{id: doc2_id} = document_fixture(doc, root)

      assert {:ok, [%Document{id: ^doc2_id}]} = Documents.list_documents(doc, root)
      assert {:ok, []} = Documents.list_documents(doc2, root)
    end

    test "documents_schema/2 returns valid document schema for app" do
      root = root_fixture()
      app = %{id: app_id} = app_fixture(root)
      doc = %{id: doc_id} = document_fixture(app, root)
      _doc2 = %{id: doc2_id} = document_fixture(doc, root)

      assert {:ok,
              %{
                parent: %{id: ^app_id},
                children: [
                  %{
                    parent: %{id: ^doc_id},
                    children: [%{id: ^doc2_id}]
                  }
                ]
              }} = Documents.document_schema(app, root)
    end

    test "list_documents/1 returns all documents" do
      root = root_fixture()
      app = app_fixture(root)
      %Document{id: id} = document_fixture(app, root)

      assert {:ok, [%Document{id: ^id}]} = Documents.list_documents(root)
    end

    test "get_document!/1 returns the document with given id" do
      root = root_fixture()
      app = app_fixture(root)
      %Document{id: id} = document_fixture(app, root)

      assert Documents.get_document!(id, root).id == id
    end

    test "create_document/1 with valid data creates a document" do
      root = root_fixture()
      app = app_fixture(root)

      assert {:ok, %{name: "a document"}} = Documents.create_document(@valid_attrs, root, app)
    end

    test "create_document/1 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)

      assert {:error, %Ecto.Changeset{}} = Documents.create_document(@invalid_attrs, root, app)
    end

    test "update_document/2 with valid data updates the document" do
      root = root_fixture()
      app = app_fixture(root)
      document = document_fixture(app, root)

      assert {:ok, %{name: "updated"}} = Documents.update_document(document, @update_attrs, root)
    end

    test "update_document/2 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      document = document_fixture(app, root)

      assert {:error, %Ecto.Changeset{}} =
               Documents.update_document(document, @invalid_attrs, root)

      assert document.name == Documents.get_document!(document.id, root).name
    end

    test "delete_document/1 deletes the document" do
      root = root_fixture()
      app = app_fixture(root)
      document = document_fixture(app, root)

      assert {:ok, %Document{}} = Documents.delete_document(document, root)
      assert Documents.get_document!(document.id, root) == nil
    end

    test "change_document/1 returns a document changeset" do
      root = root_fixture()
      app = app_fixture(root)
      document = document_fixture(app, root)

      assert %Ecto.Changeset{} = Documents.change_document(document)
    end
  end

  describe "decimals" do
    alias Fhub.Documents.Decimal

    @valid_attrs %{name: "a decimal", value: 5}
    @update_attrs %{name: "updated"}
    @invalid_attrs %{name: ""}

    test "list_decimals/2 returns all decimals for document" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      %Decimal{id: id} = decimal_fixture(doc, root)

      assert {:ok, [%Decimal{id: ^id}]} = Documents.list_decimals(doc, root)
    end

    test "list_decimals/1 returns all decimals" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      %Decimal{id: id} = decimal_fixture(doc, root)

      assert {:ok, [%Decimal{id: ^id}]} = Documents.list_decimals(root)
    end

    test "get_decimal!/1 returns the decimal with given id" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      %Decimal{id: id} = decimal_fixture(doc, root)

      assert Documents.get_decimal!(id, root).id == id
    end

    test "create_decimal/1 with valid data creates a decimal" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)

      assert {:ok, %{name: "a decimal"}} = Documents.create_decimal(@valid_attrs, root, doc)
    end

    test "create_decimal/1 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)

      assert {:error, %Ecto.Changeset{}} = Documents.create_decimal(@invalid_attrs, root, doc)
    end

    test "update_decimal/2 with valid data updates the decimal" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      decimal = decimal_fixture(doc, root)

      assert {:ok, %{name: "updated"}} = Documents.update_decimal(decimal, @update_attrs, root)
    end

    test "update_decimal/2 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      decimal = decimal_fixture(doc, root)

      assert {:error, %Ecto.Changeset{}} =
               Documents.update_decimal(decimal, @invalid_attrs, root)

      assert decimal.name == Documents.get_decimal!(decimal.id, root).name
    end

    test "delete_decimal/1 deletes the decimal" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      decimal = decimal_fixture(doc, root)

      assert {:ok, %Decimal{}} = Documents.delete_decimal(decimal, root)
      assert Documents.get_decimal!(decimal.id, root) == nil
    end

    test "change_decimal/1 returns a decimal changeset" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      decimal = decimal_fixture(doc, root)

      assert %Ecto.Changeset{} = Documents.change_decimal(decimal)
    end
  end

  describe "jsons" do
    alias Fhub.Documents.Json

    @valid_attrs %{name: "a json", value: %{}}
    @update_attrs %{name: "updated"}
    @invalid_attrs %{name: ""}

    test "list_jsons/2 returns all jsons for document" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      %Json{id: id} = json_fixture(doc, root)

      assert {:ok, [%Json{id: ^id}]} = Documents.list_jsons(doc, root)
    end

    test "list_jsons/1 returns all jsons" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      %Json{id: id} = json_fixture(doc, root)

      assert {:ok, [%Json{id: ^id}]} = Documents.list_jsons(root)
    end

    test "get_json!/1 returns the json with given id" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      %Json{id: id} = json_fixture(doc, root)

      assert Documents.get_json!(id, root).id == id
    end

    test "create_json/1 with valid data creates a json" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)

      assert {:ok, %{name: "a json"}} = Documents.create_json(@valid_attrs, root, doc)
    end

    test "create_json/1 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)

      assert {:error, %Ecto.Changeset{}} = Documents.create_json(@invalid_attrs, root, doc)
    end

    test "update_json/2 with valid data updates the json" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      json = json_fixture(doc, root)

      assert {:ok, %{name: "updated"}} = Documents.update_json(json, @update_attrs, root)
    end

    test "update_json/2 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      json = json_fixture(doc, root)

      assert {:error, %Ecto.Changeset{}} =
               Documents.update_json(json, @invalid_attrs, root)

      assert json.name == Documents.get_json!(json.id, root).name
    end

    test "delete_json/1 deletes the json" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      json = json_fixture(doc, root)

      assert {:ok, %Json{}} = Documents.delete_json(json, root)
      assert Documents.get_json!(json.id, root) == nil
    end

    test "change_json/1 returns a json changeset" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      json = json_fixture(doc, root)

      assert %Ecto.Changeset{} = Documents.change_json(json)
    end
  end

  describe "strings" do
    alias Fhub.Documents.String

    @valid_attrs %{name: "a string", value: "smth"}
    @update_attrs %{name: "updated"}
    @invalid_attrs %{name: ""}

    test "list_strings/2 returns all strings for document" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      %String{id: id} = string_fixture(doc, root)

      assert {:ok, [%String{id: ^id}]} = Documents.list_strings(doc, root)
    end

    test "list_strings/1 returns all strings" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      %String{id: id} = string_fixture(doc, root)

      assert {:ok, [%String{id: ^id}]} = Documents.list_strings(root)
    end

    test "get_string!/1 returns the string with given id" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      %String{id: id} = string_fixture(doc, root)

      assert Documents.get_string!(id, root).id == id
    end

    test "create_string/1 with valid data creates a string" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)

      assert {:ok, %{name: "a string"}} = Documents.create_string(@valid_attrs, root, doc)
    end

    test "create_string/1 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)

      assert {:error, %Ecto.Changeset{}} = Documents.create_string(@invalid_attrs, root, doc)
    end

    test "update_string/2 with valid data updates the string" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      string = string_fixture(doc, root)

      assert {:ok, %{name: "updated"}} = Documents.update_string(string, @update_attrs, root)
    end

    test "update_string/2 with invalid data returns error changeset" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      string = string_fixture(doc, root)

      assert {:error, %Ecto.Changeset{}} =
               Documents.update_string(string, @invalid_attrs, root)

      assert string.name == Documents.get_string!(string.id, root).name
    end

    test "delete_string/1 deletes the string" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      string = string_fixture(doc, root)

      assert {:ok, %String{}} = Documents.delete_string(string, root)
      assert Documents.get_string!(string.id, root) == nil
    end

    test "change_string/1 returns a string changeset" do
      root = root_fixture()
      app = app_fixture(root)
      doc = document_fixture(app, root)
      string = string_fixture(doc, root)

      assert %Ecto.Changeset{} = Documents.change_string(string)
    end
  end
end
