defmodule EctoAtomTest do
  use ExUnit.Case
  doctest EctoAtom

  @valid_data :atom

  test "type/0 is correct" do
    assert EctoAtom.type() == :string
  end

  test "dump/1 and load/1 are working" do
    {:ok, d} = EctoAtom.dump(@valid_data)
    {:ok, l} = EctoAtom.load(d)
    assert l == @valid_data
  end

  test "cast/1 returns {:ok, term} on valid data" do
    assert match?({:ok, @valid_data}, EctoAtom.cast(@valid_data))
  end

  test "equal?/2 works" do
    {:ok, d} = EctoAtom.dump(@valid_data)

    assert EctoAtom.equal?(@valid_data, @valid_data)
    assert EctoAtom.equal?(d, d)
  end
end
