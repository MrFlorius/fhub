defmodule EctoTermTest do
  use ExUnit.Case
  doctest EctoTerm

  @valid_data %{a: [{:a, "b"}, :c, 1.1, e: 1]}

  test "type/0 is correct" do
    assert EctoTerm.type() == :binary
  end

  test "dump/1 and load/1 are working" do
    {:ok, d} = EctoTerm.dump(@valid_data)
    {:ok, l} = EctoTerm.load(d)
    assert l == @valid_data
  end

  test "cast/1 returns {:ok, term} on valid data" do
    assert match?({:ok, @valid_data}, EctoTerm.cast(@valid_data))
  end

  test "equal?/2 works" do
    {:ok, d} = EctoTerm.dump(@valid_data)

    assert EctoTerm.equal?(@valid_data, @valid_data)
    assert EctoTerm.equal?(d, d)
  end
end
