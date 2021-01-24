defmodule Fhub.AccessControl.Checker do
  import Ecto.Query, warn: false
  alias Fhub.Repo
  alias Fhub.Resources
  alias Fhub.Resources.Resource
  alias Fhub.AccessControl.Permission

  def check?(resource, actor, action),
    do: do_check?(get_resource(resource), get_resource(actor), action) |> Enum.any?()

  defp do_check?(%Resource{} = resource, %Resource{} = actor, action) do
    a = %{permissions_as_actor: ap} = Repo.preload(actor, :permissions_as_actor)
    r = %{permissions: rp} = Repo.preload(resource, :permissions)

    case do_check_cartesian(rp, ap, action) do
      [] -> do_check?(Resources.get_resource_parent(r), a, action)
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

  defp get_resource(something) do
    case something do
      %Resource{} = r ->
        r

      %{resource: %Resource{} = r} ->
        r

      r ->
        r
        |> Repo.preload(:resource)
        |> Map.get(:resource)
    end
  end
end
