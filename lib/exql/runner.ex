defmodule Exql.Runner do

  @doc """
  Establishes a connection to the configures MSSQL server and returns a PID representing the connection.
  """
  def connect! do
    {:ok, pid} = connect
    pid
  end

  @doc """
  Establishes a connection to the configured MSSQL server and returns a 2-tuple containing a PID representing the connection.
  """
  def connect do
    Application.get_env(:exql, :connection)
    |> Tds.Connection.start_link
  end

  @doc """
  Sends the constructed query to the server and transforms the output into a list of maps representing the resultset.
  """
  def send_query(conn, query) do
    result =
      Tds.Connection.query(conn, query.sql, query.params |> create_params)
    result = result |> Exql.Transformer.transform(query.rollup)

    spawn fn ->
      conn |> Tds.Connection.stop
    end
    
    result
  end

  def send_raw_query(conn, query) do
    result =
      Tds.Connection.query(conn, query.sql, query.params)
    result = result |> Exql.Transformer.transform(query.rollup)

    spawn fn ->
      conn |> Tds.Connection.stop
    end

    result
  end


  defp create_params(params) do
    Enum.map(params, fn({k, v}) ->
      k = if is_atom(k), do: Atom.to_string(k), else: k
      %Tds.Parameter{name: "@#{k}", value: v}
    end)
  end

end
