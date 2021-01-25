defmodule Fhub.AccessControl.Transactions do
  alias Ecto.Multi
  alias Fhub.AccessControl.Checker

  @spec operation((module, map -> {:error, any} | {:ok, any}), any, any, Ecto.Repo.t) :: {:ok, map} | {:error, atom}
  def operation(fun, actor, action, repo \\ Fhub.Repo) do
    case repo.transaction(transaction(fun, actor, action)) do
      {:ok, %{permitted: result}} -> {:ok, result}
      {:error, _step, err, _} -> {:error, err}
    end
  end

  @spec transaction((atom, map -> {:error, any} | {:ok, any}), any, any) :: Ecto.Multi.t()
  def transaction(fun, actor, action) do
    Multi.new()
    |> Multi.run(:operation, fun)
    |> Multi.run(:permitted, fn r, o -> check(r, o, actor, action) end)
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

  defp check(repo, %{operation: op_result}, actor, action) when is_list(op_result) do
    if Checker.check?(op_result, actor, action, repo) do
      {:ok, op_result}
    else
      {:error, :forbidden}
    end
  end
end
