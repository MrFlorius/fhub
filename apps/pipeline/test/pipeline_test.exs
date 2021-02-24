defmodule PipelineTest do
  use ExUnit.Case

  describe "pipeline" do
    test "handle_error/4 packs error data in struct" do
      assert {:error,
              %Pipeline.Error{
                error: :error,
                pipeline: :pipeline,
                state: %{complex: :state},
                step: :step
              }} = Pipeline.handle_error(:pipeline, :step, %{complex: :state}, :error)
    end

    test "handle_error/4 packs error tuple in struct" do
      assert {:error,
              %Pipeline.Error{
                error: :error,
                pipeline: :pipeline,
                state: %{complex: :state},
                step: :step
              }} = Pipeline.handle_error(:pipeline, :step, %{complex: :state}, {:error, :error})
    end
  end
end
