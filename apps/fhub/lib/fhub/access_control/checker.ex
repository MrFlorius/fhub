defmodule Fhub.AccessControl.Checker do
  import Ecto.Query, warn: false
  alias Fhub.Resources.Resource
  alias Fhub.AccessControl.Permission
  alias Fhub.Resources.ResourceProtocol
  alias Fhub.Resources.Tree

  def permit(resource, actor, action, repo \\ Fhub.Repo) do
    if check?(resource, actor, action, repo) do
      {:ok, resource}
    else
      {:error, :forbidden}
    end
  end

  def check?(resource, actor, action, repo \\ Fhub.Repo) do
    do_check?(
      ResourceProtocol.resource(resource, repo),
      ResourceProtocol.resource(actor, repo),
      action,
      repo)
    |> Enum.any?()
  end

  defp do_check?(%Resource{} = resource, %Resource{} = actor, action, repo) do
    a = %{permissions_as_actor: ap} = repo.preload(actor, :permissions_as_actor)
    r = %{permissions: rp} = repo.preload(resource, :permissions)

    case do_check_cartesian(rp, ap, action) do
      [] -> do_check?(Tree.parent(r, repo), a, action, repo)
      x -> x
    end
  end

  defp do_check?(_, _, _, _), do: []

  defp do_check_cartesian(resource_permissions, actor_permissions, action) do
    for rp <- resource_permissions, ap <- actor_permissions, check_pair(rp, ap) do
      cond do
        Enum.member?(ap.can, Permission.access_none()) -> false
        Enum.member?(ap.can, Permission.access_any()) -> true
        Enum.member?(rp.can, action) and Enum.member?(ap.can, action) -> true
        true -> false
      end
    end
  end

  defp check_pair(%Permission{resource_id: r_id}, %Permission{resource_id: r_id}), do: true
  defp check_pair(_, _), do: false
end
