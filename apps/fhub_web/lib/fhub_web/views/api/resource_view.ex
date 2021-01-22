defmodule FhubWeb.Api.ResourceView do
  use FhubWeb, :view
  alias FhubWeb.Api.ResourceView

  def render("index.json", %{resources: resources}) do
    %{data: render_many(resources, ResourceView, "resource.json")}
  end

  def render("show.json", %{resource: resource}) do
    %{data: render_one(resource, ResourceView, "resource.json")}
  end

  def render("resource.json", %{resource: resource}) do
    %{id: resource.id,
      domain: resource.domain}
  end
end
