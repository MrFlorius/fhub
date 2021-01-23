defmodule Fhub.AccessControl.Checker do
  import Ecto.Query, warn: false
  alias Fhub.Repo
  alias Fhub.Resources
  alias Fhub.Resources.Resource

  def check?(%Resource{} = resource, %Resource{} = actor, action), do: do_check?(resource, actor, action) |> Enum.any?()

  defp do_check?(%Resource{} = resource, %Resource{} = actor, action) do
    a = %{permissions_as_actor: ap} = Repo.preload(actor, :permissions_as_actor)
    r = %{permissions: rp} = Repo.preload(resource, :permissions)

    case do_check_cartesian(rp, ap, action) do
      [] -> do_check?(Resources.get_resource_parent(r), a, action)
      x -> x
    end
  end

  defp do_check_cartesian(resource_permissions, actor_permissions, action) do
    for rp <- resource_permissions, ap <- actor_permissions do
      cond do
        rp.id == ap.id and Enum.member?(ap.can, action) -> true
        Enum.member?(rp.can, action) and Enum.member?(ap.can, action) -> true
        true -> false
      end
    end
  end
end
