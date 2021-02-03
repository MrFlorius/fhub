defmodule Remote.ElixirFun do
  @behaviour Remote

  def check(code) do
    with {:ok, ast} <- Code.string_to_quoted(code),
         true <- fun?(ast) do
      {:ok, code}
    else
      _ ->
        {:error, :something_wrong}
    end
  end

  def run(code, opts) do
    {fun, _} = Code.eval_string(code)

    fun.(opts)
  end

  defp fun?(ast) do
    {_ast, result} = Macro.prewalk(ast, false, fn
      {:fn, _, _} = t, false -> {t, true}
      {:&, _, _} = t, false -> {t, true}
      t, true -> {t, true}
      t, false -> {t, false}
    end)

    result
  end
end
