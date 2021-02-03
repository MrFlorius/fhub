defmodule Remote do
  @moduledoc """
  Module for runnig custom remote functions
  """
  @callback check(bitstring()) :: {:ok, bitstring()} | {:error, atom()}

  @callback run(bitstring(), list()) :: any()

  @spec run(module(), bitstring(), list()) :: any
  def run(module, code, opts) do
    with {:ok, code} <- module.check(code) do
      module.run(code, opts)
    end
  end
end
