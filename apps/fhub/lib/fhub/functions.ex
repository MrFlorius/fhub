defmodule Fhub.Functions do
  # alias Fhub.Repo
  alias Fhub.Functions.Function
  alias Fhub.Functions.Version
  alias Fhub.Functions.Call
  alias Fhub.Resources

  # import Ecto.Query

  use Fhub.AccessControl.Context, for: Function, resource_parent: "functions"
  use Fhub.AccessControl.Context, for: Version
  use Fhub.AccessControl.Context, for: Call

  def change_version(v, attrs \\ %{}) do
    c = super(v, attrs)

    if c.valid?, do: compile_version(c), else: c
  end

  # def list_calls(%Version{} = v, _actor) do
  #   Repo.all(from c in Call, where: c.function_version_id == ^v.id)
  # end

  # def list_calls(%Function{} = f, _actor) do
  #   Repo.all(from c in Call, join: v in Version, on: c.function_version_id == v.id, where: v.function_id == ^f.id, select: c)
  # end

  def change_call_create(c, attrs \\ %{}) do
    c = super(c, attrs)
    if c.valid?, do: execute_call(c), else: c
  end

  defp compile_version(%Ecto.Changeset{} = c) do
    with {:ok, %{compiled_function: f}} <-
           c
           |> Ecto.Changeset.apply_changes()
           |> Pipeline.Remote.Elixir.Compile.run() do
      Version.changeset(c, %{compiled_function: f})
    else
      {:error, err} ->
        Ecto.Changeset.add_error(c, :code, "compilation error", error: err)
    end
  end

  defp execute_call(%Ecto.Changeset{} = c) do
    with %{opts: opts} = call <- Ecto.Changeset.apply_changes(c),
         parent <- Resources.TreeProtocol.parent(call),
         {:ok, %{compiled_function: f}} <- get_version(parent.id, Resources.root()) do
      result =
        case Pipeline.Remote.Elixir.Execute.run(%{compiled_function: f, opts: opts}) do
          {:ok, %{result: r}} -> r
          {:error, e} -> e
        end

      Call.changeset(c, %{result: result})
    else
      x ->
        IO.inspect(x)
        Ecto.Changeset.add_error(c, :resource, "failed to resolve version")
    end
  end
end
