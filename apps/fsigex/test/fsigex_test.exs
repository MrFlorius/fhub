defmodule FsigexTest do
  use ExUnit.Case

  describe "fsigex" do
    test "by_binary_signature/1 with vallid binary returns {:ok, type}" do
      assert {:ok, Fsigex.Extensions.GIF} = Fsigex.by_binary_signature(<<0x47, 0x49, 0x46, 0x38, 0x37, 0x61>>)
    end

    test "by_binary_signature/1 with invallid binary returns {:error, :not_defined}" do
      assert {:error, :not_defined} = Fsigex.by_binary_signature(<<>>)
    end

    test "by_filename/1 with vallid filename returns {:ok, type}" do
      assert {:ok, Fsigex.Extensions.GIF} = Fsigex.by_filename("img.gif")
    end

    test "by_filename/1 with invallid filename returns {:error, :not_defined}" do
      assert {:error, :not_defined} = Fsigex.by_filename("")
    end

    test "by_extname/1 with vallid extension returns {:ok, type}" do
      assert {:ok, Fsigex.Extensions.GIF} = Fsigex.by_extname(".gif")
    end

    test "by_extname/1 with invallid extension returns {:error, :not_defined}" do
      assert {:error, :not_defined} = Fsigex.by_extname("")
    end

    test "by_mime/1 with vallid mime returns {:ok, type}" do
      assert {:ok, Fsigex.Extensions.GIF} = Fsigex.by_mime("image/gif")
    end

    test "by_mime/1 with invallid mime returns {:error, :not_defined}" do
      assert {:error, :not_defined} = Fsigex.by_mime("")
    end
  end
end
