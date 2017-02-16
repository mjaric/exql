defmodule Exql.Transformer do

  @doc """
  Transforms a Tds.Error into a tuple {:error, msg_text}.
  """
  def transform({:error, %Tds.Error{mssql: %{msg_text: msg_text}}}, _) do
    {:error, msg_text }
  end

  @doc """
  Transforms a Tds.Result into a list of maps representing the resultset.
  """
  def transform({:ok, %Tds.Result{columns: cols, rows: rows}}, :all) do
    Enum.map(rows, fn(row) -> transform(cols, row) end)
  end

  @doc """
  Transforms a Tds.Result into a single map representing the last item in the resultset.
  """
  def transform({:ok, %Tds.Result{columns: cols, rows: rows}}, :last) do
    row = List.last(rows)
    transform(cols, row)
  end

  @doc """
  Transforms a Tds.Result into a single map representing the first item in the resultset.
  """
  def transform({:ok, %Tds.Result{columns: cols, rows: rows}}, rollup) when is_atom(rollup) do
    row = List.first(rows)
    transform(cols, row)
  end

  @doc """
  Transforms a list of column names and a set of row data into a zipped map.
  """
  def transform(cols, row) do
    List.zip([cols,row])
    |> to_map
  end

  @doc """
  Transforms a list of 2-tuples into a Map where element 1 is the key, and element 2 is the value.
  """
  def to_map(list, acc \\ %{})
  def to_map([], acc), do: acc
  def to_map([{key, val}|rest], acc) do
    key = key |> String.downcase |> String.to_atom
    acc = Map.put(acc, key, val)
    to_map(rest, acc)
  end

end
