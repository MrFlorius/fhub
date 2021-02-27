defmodule Pipeline.Image.CommandServer do
  use GenServer
  @timeout 500

  defmodule State, do: defstruct [:sender, :port, :timer, output: []]

  alias __MODULE__.State

  def start_link(default \\ []) when is_list(default), do: GenServer.start_link(__MODULE__, default)

  def execute(pid, command, input), do: GenServer.call(pid, {:execute, command, input})

  def init(_), do: {:ok, %State{}}

  def handle_call({:execute, c, i}, {s, _}, %State{output: [], port: nil, sender: nil, timer: nil}) do
    port = Port.open({:spawn, c}, [:binary])
    Port.monitor(port)
    Port.command(port, i)

    timer = Process.send_after(self(), :timeout, @timeout)

    {:reply, :in_progress, %State{output: [], sender: s, port: port, timer: timer}}
  end

  def handle_call({:execute, _, _}, _, %State{} = state) do
    {:reply, :busy, state}
  end

  def handle_info({port, {:data, d}}, %State{output: o, port: port} = state), do: {:noreply, Map.put(state, :output, [d | o])}
  def handle_info({:DOWN, _ref, :port, port, :normal}, %State{port: port} = state), do: {:noreply, success(state)}
  def handle_info({:DOWN, _ref, :port, port, reason}, %State{port: port} = state), do: {:noreply, faliure(state, reason)}
  def handle_info(:timeout, state), do: {:noreply, faliure(state, :timeout)}

  def handle_info(msg, state) do
    IO.inspect("random msg: #{inspect(msg)}")
    {:noreply, state}
  end

  defp faliure(%State{sender: pid} = s, error) do
    send(pid, {:error, error})

    s
    |> cancel_timer()
    |> close_port()
  end

  defp success(%State{sender: pid, output: o} = s) do
    send(pid, {:result, Enum.reverse(o)})

    s
    |> cancel_timer()
    |> close_port()
  end

  defp close_port(%State{port: p}) do
    send(p, :close)
    %State{}
  end

  defp cancel_timer(%State{timer: t} = s) do
    Process.cancel_timer(t)
    Map.put(s, :timer, nil)
  end
end
