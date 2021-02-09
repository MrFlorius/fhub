defmodule Fhub.Apps do
  use Fhub.AccessControl.Context, for: Fhub.Apps.App, resource_parent: "apps"
end
