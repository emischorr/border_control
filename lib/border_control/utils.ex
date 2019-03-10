defmodule BorderControl.Utils do

  def http_method(conn), do: String.to_atom(String.downcase(conn.method))

end
