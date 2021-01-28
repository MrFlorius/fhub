defmodule Fhub.AccessControl.Transactions do
  alias Ecto.Multi
  alias Fhub.AccessControl.Checker

  @spec operation((module, map -> {:error, any} | {:ok, any}), any, any, Ecto.Repo.t()) ::
          {:ok, map} | {:error, atom}
  def operation(fun, actor, action, repo \\ Fhub.Repo) do
    case repo.transaction(transaction(fun, actor, action, false)) do
      {:ok, %{permitted: result}} -> {:ok, result}
      {:error, _step, err, _} -> {:error, err}
    end
  end

  def operation_filter(fun, actor, action, repo \\ Fhub.Repo) do
    case repo.transaction(transaction(fun, actor, action, true)) do
      {:ok, %{permitted: result}} -> {:ok, result}
      {:error, _step, err, _} -> {:error, err}
    end
  end

  @spec transaction((atom, map -> {:error, any} | {:ok, any}), any, any) :: Ecto.Multi.t()
  def transaction(fun, actor, action, filter \\ false) do
    f =
      if filter do
        fn r, o -> filter(r, o, actor, action) end
      else
        fn r, o -> check(r, o, actor, action) end
      end

    Multi.new()
    |> Multi.run(:operation, fun)
    |> Multi.run(:permitted, f)
  end

  defp check(repo, %{operation: op_result}, actor, action) when is_list(op_result) do
    allowed =
      op_result
      |> Enum.map(fn r -> Checker.check?(r, actor, action, repo) end)
      |> Enum.all?()

    if allowed do
      {:ok, op_result}
    else
      {:error, :forbidden}
    end
  end

  defp check(repo, %{operation: op_result}, actor, action) do
    if Checker.check?(op_result, actor, action, repo) do
      {:ok, op_result}
    else
      {:error, :forbidden}
    end
  end

  defp filter(repo, %{operation: op_result}, actor, action) when is_list(op_result) do
    {:ok,
     Enum.filter(op_result, fn r ->
       Checker.check?(r, actor, action, repo)
     end)}
  end

  defp filter(repo, %{operation: op_result}, actor, action) do
    filter(repo, %{operation: [op_result]}, actor, action)
  end
end
