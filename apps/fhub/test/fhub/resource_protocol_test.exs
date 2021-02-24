defmodule ResourceProtocol.AnyTest do
  use Fhub.DataCase
  alias Fhub.Resources.ResourceProtocol

  describe "ResourceProtocol" do
    test "resource/2 returns resource" do
      resource = resource_fixture()

      assert resource == ResourceProtocol.resource(resource)
    end

    test "preload/2 returns resource" do
      resource = resource_fixture()

      assert resource == ResourceProtocol.preload(resource)
    end

    test "convert/2 returns resource" do
      resource = resource_fixture()

      assert resource == ResourceProtocol.convert(resource)
    end

    test "convert/2 converts resource to user" do
      root = root_fixture()
      user = %{id: user_id} = user_fixture(root)

      user_resource = ResourceProtocol.resource(user)
      assert %Fhub.Accounts.User{id: ^user_id} = ResourceProtocol.convert(user_resource)
    end
  end
end
