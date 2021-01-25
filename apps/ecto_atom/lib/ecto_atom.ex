defmodule EctoAtom do
  use Ecto.Type

  def type, do: :string

  def cast(atom) when is_atom(atom), do: {:ok, atom}

  def cast(str) when is_bitstring(str), do: {:ok, String.to_existing_atom(str)}

  def dump(atom) when is_atom(atom), do: {:ok, Atom.to_string(atom)}

  def load(str), do: {:ok, String.to_existing_atom(str)}

  def equal?(term1, term2), do: term1 == term2

  def autogenerate(), do: nil
end
