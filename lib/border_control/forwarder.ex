defmodule BorderControl.Forwarder do
  require Logger
  use GenServer

  alias :mnesia, as: Mnesia

  @timedelay 5000


  # API #

  def start_link(args) do
    GenServer.start_link(__MODULE__, %{}, name: :forwarder)
  end


  # Callbacks #

  def init(state) do
    Logger.info "Forwarder Process started"
    Process.send_after(self(), :check, 500)
    {:ok, state}
  end

  def handle_info(:check, state) do
    Logger.debug "[Forwarder] checking for calls..."

    Logger.debug fn -> "[Forwarder] #{Mnesia.dirty_all_keys(Calls) |> Enum.count} calls waiting" end

    # Mnesia.dirty_read({Calls, id})
    case find_calls() do
      nil -> Logger.debug "[Forwarder] No calls matching"
      list ->
        list |> Enum.map(fn [id, conn, ts, nb] -> BorderControl.Caller.start(id, conn) end)
      x -> Logger.warn "[Forwarder] Got unknown response while trying to find calls: #{inspect x}"
    end

    Process.send_after(self(), :check, @timedelay)
    {:noreply, state}
  end

  def find_calls do
    case Mnesia.transaction(fn ->
      Mnesia.select(Calls, [
        {
          {Calls, :"$1", :"$2", :"$3", :"$4"},
          [{ :<, :"$4", DateTime.to_unix(DateTime.utc_now()) }],
          [:"$$"]
        }
      ])
    end) do
      {:atomic, result} -> result
      x -> Logger.warn "[Forwarder] Got unknown search result: #{inspect x}"
    end
  end
end
