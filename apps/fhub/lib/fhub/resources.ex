defmodule Fhub.Resources do
  @moduledoc """
  The Resources context.
  """

  import Ecto.Query, warn: false

  alias Fhub.Repo
  alias Fhub.Resources.Resource

  alias Fhub.Resources.Path

  def list_resources do
    Repo.all(Resource)
  end

  def get_resource!(id), do: Repo.get!(Resource, id)

  def get_resource_by(attrs) do
    Repo.get_by(Resource, attrs)
  end

  @spec get_resource_by_path(Path.t()) :: {:ok, any()} | {:error, :does_not_exists}
  def get_resource_by_path(path) do
    Repo.transaction(fn repo ->
      case Path.reduce_to_names(path) do
        {nil, p} ->
          Resource.roots()
          |> repo.all()
          |> do_get_resource_by_path(p, repo)

        {id, p} ->
          %Resource{id: id}
          |> Resource.children()
          |> repo.all()
          |> do_get_resource_by_path(p, repo)
      end
      |> case do
        :error -> repo.rollback(:does_not_exists)
        r -> r
      end
    end)
  end

  def root() do
    get_resource_by(%{name: "root"})
  end

  def create_resource(attrs \\ %{}) do
    %Resource{}
    |> Resource.changeset(attrs)
    |> Repo.insert()
  end

  def update_resource(%Resource{} = resource, attrs) do
    resource
    |> Resource.changeset(attrs)
    |> Repo.update()
  end

  def delete_resource(%Resource{} = resource) do
    Repo.delete(resource)
  end

  def change_resource(%Resource{} = resource, attrs \\ %{}) do
    Resource.changeset(resource, attrs)
  end

  defp do_get_resource_by_path([r], [], _), do: r

  defp do_get_resource_by_path(rs, [p], _rp) do
    rs
    |> Enum.filter(fn %{name: n} -> n == p end)
    |> Enum.at(0)
  end

  defp do_get_resource_by_path(rs, [p | tail] = path, rp) when length(path) > 0 do
    rs
    |> Enum.filter(fn %{name: n} -> n == p end)
    |> Enum.map(fn r ->
      r
      |> Resource.children()
      |> rp.all()
      |> do_get_resource_by_path(tail, rp)
    end)
    |> Enum.at(0)
  end

  defp do_get_resource_by_path(_, _, _), do: :error
end
