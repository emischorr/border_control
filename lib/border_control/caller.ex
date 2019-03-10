defmodule BorderControl.Caller do
  use GenServer
  require Logger

  alias :mnesia, as: Mnesia
  alias BorderControl.Http


  # API #

  def start(id, conn) do
    name = String.to_atom("Caller-"<>id)
    GenServer.start(__MODULE__, %{id: id, conn: conn}, name: name)
  end


  # Callbacks #

  def init(state) do
    Logger.debug "Started new caller process for call #{state.id}"
    Process.flag(:trap_exit, true)
    {:ok, state, 0}
  end

  def handle_info(:timeout, %{id: id, conn: conn} = state) do
    # timeout of 0 on init on purpose to defer actions
    case Http.call(conn) do
      {:ok, 200} ->
        Mnesia.dirty_delete({Calls, id})
        {:stop, :normal, state}
      x ->
        Logger.debug "Response from call is not 200, trying again later..."
        Process.send_after(self(), :timeout, 1000)
        # TODO: increase tries counter or stop if too many tries
        {:noreply, state}
    end

  end

  def terminate(reason, state) do
    # Do Shutdown Stuff
    Logger.debug "Closing caller #{state.id}"
    :normal
  end
end
