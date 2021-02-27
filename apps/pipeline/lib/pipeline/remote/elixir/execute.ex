defmodule Pipeline.Remote.Elixir.Execute do
  @behaviour Pipeline

  @type state ::
          %{compiled_function: function, opts: map, result: any}
          | %{compiled_function: function, opts: map}
  @type step :: :execute

  @impl Pipeline

  # TODO: implement PoW

  def run(%{compiled_function: _f, opts: _opts} = state) do
    with {:ok, state} <- execute(state),
         state <- struct(__MODULE__, state) do
      {:ok, state}
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
