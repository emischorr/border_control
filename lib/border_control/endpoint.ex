defmodule BorderControl.Endpoint do
  use Plug.Router
  require Logger

  alias BorderControl.Buffer

  plug :match
  plug :dispatch

  match "/*glob" do
    conn
    |> Buffer.save
    |> respond
  end

  match _ do
    conn
    # TODO: add a small description / some help
    |> send_resp(404, "Nothing here")
    |> halt
  end

  defp respond(conn) do
    conn
    |> send_resp(200, "DONE")
    |> halt
  end

end
