defmodule Fhub.Functions do
  alias Fhub.Repo
  alias Fhub.Functions.Function
  alias Fhub.Functions.Versions
  alias Fhub.Functions.Calls

  import Ecto.Query

  use Fhub.AccessControl.Context, for: Fhub.Functions.Function, resource_parent: "functions"

  # Preloads
  def load_versions(%Function{} = f, _actor) do
    Repo.preload(f, [:versions])
  end

  def load_calls(%Versions{} = v, _actor) do
    Repo.preload(v, [:calls])
  end

  def load_versions_and_calls(%Function{} = f, _actor) do
    Repo.preload(f, [versions: [:calls]])
  end

  # Versions
  def get_version(version_id, _actor) do
    Repo.get(Versions, version_id)
  end

  def list_versions(_actor) do
    Repo.all(Versions)
  end

  def list_versions(%Function{} = f, _actor) do
    Repo.all(from v in Versions, where: v.function_id == ^f.id)
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

  defp compile_version(%Ecto.Changeset{} = c) do
    with {:ok, %{compiled_function: f}} <-
           c
           |> Ecto.Changeset.apply_changes()
           |> Pipeline.Remote.Elixir.Compile.run() do
      Versions.changeset(c, %{compiled_function: f})
      else
        {:error, err} ->
          Ecto.Changeset.add_error(c, :code, "compilation error", error: err)
    end
  end

  # Calls
  def get_call(call_id, _actor) do
    Repo.get(Calls, call_id)
  end

  def list_calls(_actor) do
    Repo.all(Calls)
  end

  def list_calls(%Versions{} = v, _actor) do
    Repo.all(from c in Calls, where: c.function_version_id == ^v.id)
  end

  def list_calls(%Function{} = f, _actor) do
    Repo.all(from c in Calls, join: v in Versions, on: c.function_version_id == v.id, where: v.function_id == ^f.id, select: c)
  end

  def create_call(%Versions{} = v, attrs, _actor) do
    %Calls{}
    |> change_call(attrs)
    |> Ecto.Changeset.put_assoc(:version, v)
    |> execute_call()
    |> Repo.insert()
  end

  def update_call(%Calls{} = c, attrs, _actor) do
    c
    |> change_call(attrs)
    |> Repo.update()
  end

  def delete_call(%Calls{} = c, _actor) do
    Repo.delete(c)
  end

  def change_call(c, attrs) do
    Calls.changeset(c, attrs)
  end

  defp execute_call(%Ecto.Changeset{} = c) do
    case Ecto.Changeset.apply_changes(c) do
      %{opts: opts, version: %{compiled_function: f}} ->
        result =
          case Pipeline.Remote.Elixir.Execute.run(%{compiled_function: f, opts: opts}) do
            {:ok, %{result: r}} -> r
            {:error, e} -> e
          end

        Calls.changeset(c, %{result: result})
      _ ->
        Ecto.Changeset.add_error(c, :version, "has to be set to execute the call")
    end
  end
end
