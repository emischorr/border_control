defmodule BorderControl.Buffer do
  require Logger

  alias :mnesia, as: Mnesia

  @delay 10

  def save(conn) do
    Logger.debug "Buffering new call: #{inspect conn}"
    Mnesia.dirty_write({Calls, id(), conn, timestamp(), not_before()})
    conn
  end

  defp id, do: UUID.uuid4()

  defp timestamp, do: DateTime.to_unix(DateTime.utc_now())

  defp not_before, do: DateTime.to_unix(DateTime.utc_now()) + @delay
end
