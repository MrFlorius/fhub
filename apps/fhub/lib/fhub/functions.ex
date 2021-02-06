defmodule Fhub.Functions do
  alias Fhub.Repo
  alias Fhub.Functions.Function
  alias Fhub.Functions.Versions
  alias Fhub.Functions.Calls

  import Ecto.Query

  use Fhub.AccessControl.Context, for: Fhub.Functions.Function, resource_parent: "functions"

  def get_version(version_id, _actor) do
    Repo.get(Versions, version_id)
  end

  def list_versions(_actor) do
    Repo.all(Versions)
  end

  def list_versions(%Function{} = f, _actor) do
    Repo.all(from v in Versions, where: v.function_id == ^f.id)
  end

  def load_versions(%Function{} = f, _actor) do
    Repo.preload(f, [:versions])
  end

  def create_version(%Function{} = f, attrs, _actor) do
    %Versions{}
    |> change_version(attrs)
    |> Ecto.Changeset.put_assoc(:function, f)
    |> Repo.insert()
  end

  def update_version(%Versions{} = v, attrs, _actor) do
    v
    |> change_version(attrs)
    |> Repo.update()
  end

  def delete_version(%Versions{} = v, _actor) do
    Repo.delete(v)
  end

  def change_version(v, attrs) do
    c = Versions.changeset(v, attrs)

    if c.valid? do
      compile_version(c)
    else
      c
    end
  end

  def compile_version(%Ecto.Changeset{} = c) do
    with {:ok, %{compiled_function: f}} <-
           c
           |> Ecto.Changeset.apply_changes()
           |> Pipeline.Remote.Elixir.Compile.run() do
      Versions.changeset(c, %{compiled_function: f})
      else
        {:error, %Pipeline.Error{error: _e} = err} ->
          Ecto.Changeset.add_error(c, :code, "compilation error", error: err)
    end
  end
end
