defmodule FhubWeb.Api.PermissionController do
  use FhubWeb, :controller

  alias Fhub.AccessControl
  alias Fhub.AccessControl.Permission

  action_fallback FhubWeb.FallbackController

  def index(conn, _params) do
    permissions = AccessControl.list_permissions()
    render(conn, "index.json", permissions: permissions)
  end

  def create(conn, %{"permission" => permission_params}) do
    with {:ok, %Permission{} = permission} <- AccessControl.create_permission(permission_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_permission_path(conn, :show, permission))
      |> render("show.json", permission: permission)
    end
  end

  def show(conn, %{"id" => id}) do
    permission = AccessControl.get_permission!(id)
    render(conn, "show.json", permission: permission)
  end

  def update(conn, %{"id" => id, "permission" => permission_params}) do
    permission = AccessControl.get_permission!(id)

    with {:ok, %Permission{} = permission} <- AccessControl.update_permission(permission, permission_params) do
      render(conn, "show.json", permission: permission)
    end
  end

  def delete(conn, %{"id" => id}) do
    permission = AccessControl.get_permission!(id)

    with {:ok, %Permission{}} <- AccessControl.delete_permission(permission) do
      send_resp(conn, :no_content, "")
    end
  end
end
