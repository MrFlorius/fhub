defmodule EctoTerm do
  @moduledoc """
  Ecto Type for erlang's terms
  """
  use Ecto.Type

  def type, do: :binary

  def cast(term), do: {:ok, term}

  def dump(term), do: {:ok, :erlang.term_to_binary(term)}

  def load(binary), do: {:ok, :erlang.binary_to_term(binary)}

  def equal?(term1, term2), do: term1 == term2

  def autogenerate(), do: nil
end
