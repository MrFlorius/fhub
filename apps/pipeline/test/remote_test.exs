defmodule Pipeline.Remote.ElixirTest do
  use ExUnit.Case

  describe "Compile" do
    alias Pipeline.Remote.Elixir.Compile

    test "can't define module in remote" do
      assert {:error, %{error: :not_a_function}} = Compile.run(%{code: "defmodule A do end"})
    end

    test "can define anonymus function" do
      assert {:ok, _} = Compile.run(%{code: "fn x -> x end"})
    end

    test "syntax error is reported" do
      assert {:error, _} = Compile.run(%{code: "fn x ->"})
    end
  end

  describe "Execute" do
    alias Pipeline.Remote.Elixir.Execute

    test "{:ok, state} on sucessful execution" do
      assert {:ok, %{result: %{a: :b}}} =
               Execute.run(%{compiled_function: fn x -> x end, opts: %{a: :b}})
    end

    test "{:error, err} on runtime error execution" do
      assert {:error,
              %{error: %ArithmeticError{message: "bad argument in arithmetic expression"}}} =
               Execute.run(%{compiled_function: fn x -> x + 1 end, opts: %{a: :b}})
    end
  end
end
