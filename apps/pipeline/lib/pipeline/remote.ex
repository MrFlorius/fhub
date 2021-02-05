defmodule Pipeline.Remote do
  @behaviour Pipeline

  @type state :: %{code: bitstring, fun: function, opts: list, result: any}
  @type step :: :check | :compile | :execute

  @impl Pipeline
  @spec run(state) :: {:ok, any} | {:error, Pipeline.Error.t}
  def run(%{fun: _f, opts: _opts} = state) do
    with {:ok, s} <- execute(state) do
      {:ok, s}
    else
      {:error, step, state, error} ->
        Pipeline.handle_error(__MODULE__, step, state, error)
    end
  end

  def run(%{code: _code} = state) do
    with {:ok, state} <- check(state),
         {:ok, state} <- compile(state),
         {:ok, state} <- execute(state) do
      {:ok, state}
    else
      {:error, step, state, error} ->
        Pipeline.handle_error(__MODULE__, step, state, error)
    end
  end

  defp check(%{code: code} = state) do
    with {:ok, ast} <- Code.string_to_quoted(code),
         {:ok, _} <- fun?(ast) do
      {:ok, state}
    else
      {:error, err} -> {:error, :check, state, err}
    end
  end

  defp compile(%{code: code} = state) do
    try do
      {fun, _} = Code.eval_string(code)
      {:ok, Map.put(state, :fun, fun)}
    rescue
      e ->
        {:error, :compile, state, e}
    end
  end

  defp execute(%{fun: f, opts: opts} = state) do
    try do
      {:ok, Map.put(state, :result, f.(opts))}
    rescue
      e ->
        {:error, :execute, state, e}
    end
  end

  defp fun?(ast) do
    r =
      Macro.prewalk(ast, false, fn
        {:fn, _, _} = t, false -> {t, true}
        {:&, _, _} = t, false -> {t, true}
        t, true -> {t, true}
        t, false -> {t, false}
      end)

    case r do
      {ast, true} -> {:ok, ast}
      {_, false} -> {:error, :not_a_function}
    end
  end
end
