defmodule Fhub.AccessControl do
  @moduledoc """
  The AccessControl context.
  """

  import Ecto.Query, warn: false
  alias Fhub.Repo

  alias Fhub.AccessControl.Permission

  defdelegate permit(resource, actor, action), to: Fhub.AccessControl.Checker

  def list_permissions do
    Permission
    |> Repo.all()
    |> Repo.preload(:resource)
  end

  def get_permission!(id), do: Repo.get!(Permission, id) |> Repo.preload(:resource)

  def create_permission(attrs) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert()
  end

  def update_permission(%Permission{} = permission, attrs) do
    permission
    |> Permission.changeset(attrs)
    |> Repo.update()
  end

  def delete_permission(%Permission{} = permission) do
    Repo.delete(permission)
  end

  def change_permission(%Permission{} = permission, attrs \\ %{}) do
    Permission.changeset(permission, attrs)
  end

  def assign_actors(%Permission{} = permission, actors) do
    permission
    |> Repo.preload(:actors)
    |> change_permission()
    |> Ecto.Changeset.put_assoc(:actors, convert_to_resource(actors))
    |> Repo.update()
  end

  def add_actors(%Permission{} = permission, actors) do
    p = Repo.preload(permission, :actors)
    assign_actors(p, convert_to_resource(actors) ++ p.actors)
  end

  def remove_actors(%Permission{} = permission, actors) do
    p = Repo.preload(permission, :actors)
    assign_actors(p, p.actors -- convert_to_resource(actors))
  end

  defp convert_to_resource(actors) when is_list(actors) do
    Enum.map(actors, &Fhub.Resources.ResourceProtocol.resource/1)
  end

  defp convert_to_resource(actor) do
    Fhub.Resources.ResourceProtocol.resource(actor)
  end
end
