defmodule Fhub.Accounts do
  use Fhub.AccessControl.Context, for: Fhub.Accounts.User, resource_parent: "accounts"
end
