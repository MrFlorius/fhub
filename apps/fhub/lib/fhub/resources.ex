defmodule Fhub.Resources do
  @moduledoc """
  The Resources context.
  """

  import Ecto.Query, warn: false
  alias Fhub.Repo
  alias Fhub.Resources.Resource

  @doc """
  Returns the list of resources.

  ## Examples

      iex> list_resources()
      [%Resource{}, ...]

  """
  def list_resources do
    Repo.all(Resource)
  end

  @doc """
  Gets a single resource.

  Raises `Ecto.NoResultsError` if the Resource does not exist.

  ## Examples

      iex> get_resource!(123)
      %Resource{}

      iex> get_resource!(456)
      ** (Ecto.NoResultsError)

  """
  def get_resource!(id), do: Repo.get!(Resource, id)

  def get_resource_by(attrs) do
    Repo.get_by(Resource, attrs)
  end

  def get_resource_by_path(path) do
    Repo.transaction(fn repo ->
      do_get_resource_by_path(repo.all(Resource.roots()), path, repo)
    end)
  end

  defp do_get_resource_by_path(rs, [p], _rp) do
    rs
    |> Enum.filter(fn %{name: n} -> n == p end)
    |> Enum.at(0)
  end

  defp do_get_resource_by_path(rs, [p | tail] = path , rp) when length(path) > 0 do
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

  def root() do
    get_resource_by(%{name: "root"})
  end

  @doc """
  Creates a resource.

  ## Examples

      iex> create_resource(%{field: value})
      {:ok, %Resource{}}

      iex> create_resource(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_resource(attrs \\ %{}) do
    %Resource{}
    |> Resource.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a resource.

  ## Examples

      iex> update_resource(resource, %{field: new_value})
      {:ok, %Resource{}}

      iex> update_resource(resource, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_resource(%Resource{} = resource, attrs) do
    resource
    |> Resource.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a resource.

  ## Examples

      iex> delete_resource(resource)
      {:ok, %Resource{}}

      iex> delete_resource(resource)
      {:error, %Ecto.Changeset{}}

  """
  def delete_resource(%Resource{} = resource) do
    Repo.delete(resource)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking resource changes.

  ## Examples

      iex> change_resource(resource)
      %Ecto.Changeset{data: %Resource{}}

  """
  def change_resource(%Resource{} = resource, attrs \\ %{}) do
    Resource.changeset(resource, attrs)
  end
end
