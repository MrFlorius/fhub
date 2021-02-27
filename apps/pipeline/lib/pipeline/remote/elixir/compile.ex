defmodule Pipeline.Remote.Elixir.Compile do
  @behaviour Pipeline

  @type state :: %{code: bitstring, compiled_function: function}
  @type step :: :check | :compile

  defstruct [:code, :compiled_function]

  @impl Pipeline
  @spec run(state) :: {:ok, state} | {:error, Pipeline.Error.t()}

  # TODO: implement PoW

  def run(%{code: code} = state) when is_bitstring(code) do
    with {:ok, state} <- check(state),
         {:ok, state} <- compile(state),
         state <- struct(__MODULE__, state) do
      {:ok, state}
    else
      {:error, step, state, error} ->
        Pipeline.handle_error(__MODULE__, step, struct(__MODULE__, state), error)
    end
  end

  defp check(%{code: code} = state) do
    with {:ok, ast} <- Code.string_to_quoted(code),
         {:ok, _} <- check_is_fun(ast) do
      {:ok, state}
    else
      {:error, err} -> {:error, :check, state, err}
    end
  end

  defp compile(%{code: code} = state) do
    try do
      {fun, _} = Code.eval_string(code)
      {:ok, Map.put(state, :compiled_function, fun)}
    rescue
      e ->
        {:error, :compile, state, e}
    end
  end

  defp check_is_fun(ast) do
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
