defmodule BorderControl.Http do
  require Logger

  alias BorderControl.Utils

  @options [proxy: System.get_env("http_proxy"), follow_redirect: false, max_redirect: 5]

  def call(conn) do
    Logger.debug fn -> "HTTP CALL to #{conn.host}" end


    {:ok, body, conn} = Plug.Conn.read_body(conn)
    conn = Plug.Conn.fetch_cookies(conn)
    c = conn.req_cookies |> Enum.map(fn {k,v} -> "#{k}=#{v}" end) |> Enum.join("; ")
    cookies = [hackney: [cookie: c]]
    headers = conn.req_headers

    case HTTPoison.request(Utils.http_method(conn), "#{conn.host}:3001", body, headers, @options ++ cookies) do
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.puts "GOT RESPONSE: #{status_code}"
        {:ok, status_code}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts "GOT ERROR: #{inspect reason}"
        {:error}

      x -> IO.inspect x
    end
  end

end
