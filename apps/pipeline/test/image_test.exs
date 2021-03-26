defmodule Pipeline.ImageTest do
  use ExUnit.Case

  def image_fixture, do: File.read!("test/support/resources/test.gif")

  describe "Resize" do
    alias Pipeline.Image.Resize

    test "run/1 works with valid binary and file name" do
      s = Resize.run(%{binary: image_fixture(), filename: "test.gif", dimensions: {128, 128}})

      assert {:ok, %{result: r}} = s
      assert r
    end

    test "run/1 returns error with valid binary and bad file name" do
      s = Resize.run(%{binary: image_fixture(), filename: "test.png", dimensions: {128, 128}})

      assert {:error, %{error: :signature_extension_mismatch}} = s
    end
  end

  describe "Scale" do
    alias Pipeline.Image.Scale

    test "run/1 works with valid binary and file name" do
      s = Scale.run(%{binary: image_fixture(), filename: "test.gif", scale: 0.5})

      assert {:ok, %{result: r}} = s
      assert r
    end

    test "run/1 returns error with valid binary and bad file name" do
      s = Scale.run(%{binary: image_fixture(), filename: "test.png", scale: 0.5})

      assert {:error, %{error: :signature_extension_mismatch}} = s
    end
  end
end
