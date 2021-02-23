defmodule Fhub.Resources do
  @moduledoc """
  The Resources context.
  """

  import Ecto.Query, warn: false

  alias Fhub.Repo
  alias Fhub.Resources.Resource
  alias Fhub.Resources.Path
  alias Fhub.Resources.Tree

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
          Tree.roots(repo)
          |> do_get_resource_by_path(p, repo)

        {id, []} -> repo.get!(Resource, id)

        {id, p} ->
          %Resource{id: id}
          |> Tree.children(repo)
          |> do_get_resource_by_path(p, repo)
      end
      |> case do
        nil -> repo.rollback(:does_not_exists)
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

  def do_get_resource_by_path(%{name: p} = r, [p], _repo), do: r

  def do_get_resource_by_path(%{name: p} = r, [p | tail], repo) do
    r
    |> Tree.children(repo)
    |> do_get_resource_by_path(tail, repo)
  end

  def do_get_resource_by_path(r, p, repo) when is_list(r) do
    r
    |> Enum.map(fn r -> do_get_resource_by_path(r, p, repo) end)
    |> Enum.filter(fn x -> x end)
    |> Enum.at(0)
  end

  def do_get_resource_by_path(_, _, _), do: nil
end
