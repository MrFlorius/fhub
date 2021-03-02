defmodule Pipeline.Image.Scale do
  import Pipeline.Image

  @behaviour Pipeline

  @type state :: %__MODULE__{
          :binary => binary(),
          :filename => bitstring(),
          :scale => float(),
          :type => module() | nil,
          :result => iodata() | nil
        }
  defstruct [:binary, :filename, :type, :scale, :result]

  @type step :: :validate_image | :resize

  @impl Pipeline
  @spec run(state) :: {:ok, state} | {:error, Pipeline.Error.t()}
  def run(state) do
    with {:ok, state} <- validate_image(state),
         {:ok, state} <- put_type(state),
         {:ok, state} <- scale(state),
         state <- struct(__MODULE__, state) do
      {:ok, state}
    else
      {:error, step, state, error} ->
        Pipeline.handle_error(__MODULE__, step, state, error)
    end
  end

  # TODO: implement pool of workers
  defp scale(%{binary: b, scale: s, type: t} = state)
       when is_integer(s) and not is_nil(t) do
    {:ok, pid} = Pipeline.Image.CommandServer.start_link()

    :in_progress = Pipeline.Image.CommandServer.execute(pid, "convert #{t.as_atom()}:- -resize #{s*100}% #{t.as_atom()}:-", b)

    rsp =
      receive do
        {:error, error} ->
          {:error, :resize, state, error}

        {:result, result} ->
          {:ok, Map.put(state, :result, result)}
      end

    Process.exit(pid, :normal)

    rsp
  end
end
