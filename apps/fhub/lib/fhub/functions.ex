defmodule Fhub.Functions do
  alias Fhub.Resources
  alias Fhub.Functions.Function
  alias Fhub.Functions.Version
  alias Fhub.Functions.Call
  alias Fhub.AccessControl.Transactions

  import Ecto.Query

  use Fhub.AccessControl.Context, for: Function
  use Fhub.AccessControl.Context, for: Version
  use Fhub.AccessControl.Context, for: Call

  def list_versions(%Function{} = f, actor) do
    q =
      from v in Version,
        join: r in Resources.Resource,
        on: v.id == r.id,
        where: r.parent_id == ^f.id,
        select: v

    Transactions.operation_filter(fn repo, _ -> {:ok, repo.all(q)} end, actor, :read)
  end

  def change_version(v, attrs \\ %{}) do
    c = super(v, attrs)

    if c.valid?, do: compile_version(c), else: c
  end

  def list_calls(%Version{} = v, actor) do
    q =
      from c in Call,
        join: r in Resources.Resource,
        on: c.id == r.id,
        where: r.parent_id == ^v.id,
        select: c

    Transactions.operation_filter(fn repo, _ -> {:ok, repo.all(q)} end, actor, :read)
  end

  def list_calls(%Function{} = f, actor) do
    q =
      from c in Call,
        join: r1 in Resources.Resource,
        on: c.id == r1.id,
        join: r2 in Resources.Resource,
        on: r2.id == r1.parent_id,
        where: r2.parent_id == ^f.id,
        select: c

    Transactions.operation_filter(fn repo, _ -> {:ok, repo.all(q)} end, actor, :read)
  end

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

      IO.inspect(result)

      Call.changeset(c, %{result: result})
      |> IO.inspect()
    else
      x ->
        IO.inspect(x)
        Ecto.Changeset.add_error(c, :resource, "failed to resolve version")
    end
  end
end
