defmodule Pipeline do
  @moduledoc """
  Define the pipeline behaviour to be used when building pipelines across multiple root-level contexts.
  """

  defmodule Error do
    @moduledoc """
    Error struct for a pipeline
    """
    @type t :: %Error{
            step: atom,
            pipeline: atom,
            state: map,
            error: any
          }
    defstruct step: nil,
              pipeline: nil,
              state: nil,
              error: nil
  end

  @callback run(data :: map) :: {:ok, result :: any} | {:error, Error.t}

  @spec handle_error(pipeline :: atom, step :: atom, state :: map, error :: any) :: {:error, Pipeline.Error.t}
  def handle_error(pipeline, step, state, {:error, error}) do
    handle_error(pipeline, step, state, error)
  end

  def handle_error(pipeline, step, state, error) do
    {:error,
     %Error{
       pipeline: pipeline,
       step: step,
       state: state,
       error: error
     }}
  end
end
