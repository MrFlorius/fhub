defmodule Fhub.AccessControl.Checker do
  import Ecto.Query, warn: false
  alias Fhub.Repo
  alias Fhub.Resources.Resource
  alias Fhub.AccessControl.Permission
  alias Fhub.Resources.ResourceProtocol
  alias Fhub.Resources.TreeProtocol

  def check?(resource, actor, action) do
    do_check?(
      ResourceProtocol.resource(resource),
      ResourceProtocol.resource(actor),
      action)
    |> Enum.any?()
  end

  defp do_check?(%Resource{} = resource, %Resource{} = actor, action) do
    a = %{permissions_as_actor: ap} = Repo.preload(actor, :permissions_as_actor)
    r = %{permissions: rp} = Repo.preload(resource, :permissions)

    case do_check_cartesian(rp, ap, action) do
      [] -> do_check?(TreeProtocol.parent(r), a, action)
      x -> x
    end
  end

  defp do_check?(_, _, _), do: []

  defp do_check_cartesian(resource_permissions, actor_permissions, action) do
    for rp <- resource_permissions, ap <- actor_permissions, check_pair(rp, ap) do
      cond do
        ap.can == Permission.access_none() -> false
        ap.can == Permission.access_any() -> true
        rp.id == ap.id -> true
        Enum.member?(rp.can, action) and Enum.member?(ap.can, action) -> true
        true -> false
      end
    end
  end

  defp check_pair(%Permission{resource_id: r_id}, %Permission{resource_id: r_id}), do: true
  defp check_pair(_, _), do: false
end
