defmodule Fhub.Functions do
  alias Fhub.Resources
  alias Fhub.Apps.App
  alias Fhub.Functions.Function
  alias Fhub.Functions.Version
  alias Fhub.Functions.Call
  alias Fhub.AccessControl.Transactions

  import Ecto.Query

  use Fhub.AccessControl.Context, for: Function
  use Fhub.AccessControl.Context, for: Version
  use Fhub.AccessControl.Context, for: Call

  # Functions
  def build_resource_for_function(parent, _actor, changeset) do
    %{name: name} = Ecto.Changeset.apply_changes(changeset)
    r = Fhub.Resources.ResourceProtocol.resource(parent)

    %{parent_id: r.id, name: name}
  end

  def create_function(attrs, actor, %App{} = parent), do: super(attrs, actor, parent)

  def update_function(%Function{} = s, attrs, actor),
    do: update_for(s, attrs, actor, &change_function_update/2, &cast_resource_for_function/2, fn s -> Map.fetch!(s, :name) end)

  # Versions
  def build_resource_for_version(parent, _actor, changeset) do
    %{version: v} = Ecto.Changeset.apply_changes(changeset)
    r = Fhub.Resources.ResourceProtocol.resource(parent)

    %{parent_id: r.id, name: "v#{v}"}
  end

  def create_version(attrs, actor, %Function{} = parent), do: super(attrs, actor, parent)

  def update_version(%Version{} = s, attrs, actor),
    do: update_for(s, attrs, actor, &change_version_update/2, &cast_resource_for_version/2, fn s -> "v#{Map.fetch!(s, :version)}" end)
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

  # Calls
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

  def create_call(attrs, actor, %Version{} = parent) do
    t = fn repo, _ ->
      %Call{}
      |> change_call_create(attrs)
      |> (fn c ->
            cast_resource_for_call(
              c,
              build_resource_for_call(parent, actor, c)
            )
          end).()
      |> execute_call()
      |> repo.insert()
    end

    Fhub.AccessControl.Transactions.operation(t, actor, :create)
  end

  def update_call(%Call{} = s, attrs, actor) do
    t = fn repo, _ ->
      s
      |> change_call_update(attrs)
      |> execute_call()
      |> repo.update()
    end

    Fhub.AccessControl.Transactions.operation(t, actor, :update)
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
         parent <- Resources.Tree.parent(call),
         {:ok, %{compiled_function: f}} <- get_version(parent.id, Resources.root()) do
      result =
        case Pipeline.Remote.Elixir.Execute.run(%{compiled_function: f, opts: opts}) do
          {:ok, %{result: r}} -> r
          {:error, e} -> e
        end

      Call.changeset(c, %{result: result})
    else
      _ -> Ecto.Changeset.add_error(c, :resource, "failed to resolve version")
    end
  end

  defp update_for(s, attrs, actor, change, cast_resource, get_resource_name) do
    transaction = fn repo, _ ->
      s
      |> repo.preload([:resource])
      |> change.(attrs)
      |> (fn c ->
            name = get_resource_name.(Ecto.Changeset.apply_changes(c))
            %{resource: %{id: id, parent_id: parent_id}} = s

            cast_resource.(c, %{id: id, parent_id: parent_id, name: name})
          end).()
      |> repo.update()
    end

    Fhub.AccessControl.Transactions.operation(transaction, actor, :update)
  end
end
