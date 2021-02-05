defmodule Pipeline.Remote.Elixir.Execute do
  @behaviour Pipeline

  @type state :: %{compiled_function: function, opts: map, result: any}
  @type step :: :execute

  @impl Pipeline
  @spec run(state) :: {:ok, any} | {:error, Pipeline.Error.t}
  def run(%{compiled_function: _f, opts: _opts} = state) do
    with {:ok, s} <- execute(state) do
      {:ok, s}
    else
      {:error, step, state, error} ->
        Pipeline.handle_error(__MODULE__, step, state, error)
    end
  end

  defp execute(%{compiled_function: f, opts: opts} = state) do
    try do
      {:ok, Map.put(state, :result, f.(opts))}
    rescue
      e ->
        {:error, :execute, state, e}
    end
  end
end
