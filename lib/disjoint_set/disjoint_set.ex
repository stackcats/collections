defmodule Collections.DisjointSet do
  @moduledoc """
  Disjoint set implementation in Elixir

  See also: [Disjoint Set](https://en.wikipedia.org/wiki/Disjoint-set_data_structure)

  Time complexity

  * `&find/2`  : O(ma(n))
  * `&union/2` : O(ma(n))

  `ma` is inverse Ackermann function.

  ## Examples

        iex> ds = DisjointSet.new()
        iex> {x, ds} = DisjointSet.find(ds, 10)
        iex> x
        10
        iex> ds = ds |> DisjointSet.union(10, 20) |> DisjointSet.union(20, 30)
        iex> x = DisjointSet.find(ds, 10) |> elem(0)
        iex> y = DisjointSet.find(ds, 30) |> elem(0)
        iex> x == y
        true
  """

  @type t :: %__MODULE__{
          root: map(),
          rank: %{optional(any) => integer()}
        }

  defstruct root: %{}, rank: %{}

  alias Collections.DisjointSet

  @doc """
  Create an empty disjoint set.

  ## Examples

      iex> DisjointSet.new()
      %DisjointSet{root: Map.new([]), rank: Map.new([])}
  """
  @spec new() :: t
  def new(), do: %DisjointSet{}

  @doc """
  The `Find` operation follows the chain of parent from a specified query node x until it reaches a root element.
  This root element represents the set to which x belongs and may be x itself.
  `Find` returns the root element it reaches.

  ## Examples

      iex> DisjointSet.new()
      ...>   |> DisjointSet.find(10)
      ...>   |> elem(0)
      10
  """

  @spec find(t, any()) :: {any(), t}
  def find(%DisjointSet{root: root, rank: rank} = disjoint_set, x) do
    case root[x] do
      nil ->
        {x, %DisjointSet{root: Map.put(root, x, x), rank: Map.put(rank, x, 1)}}

      ^x ->
        {x, disjoint_set}

      x ->
        {r, disjoint_set} = find(disjoint_set, x)
        {r, %{disjoint_set | root: Map.put(disjoint_set.root, x, r)}}
    end
  end

  @doc """
  The `Union` replaces the set containing x and the set containing y with their union.

  ## Examples

      iex> ds = DisjointSet.new() |> DisjointSet.union(20, 30)
      iex> x = ds |> DisjointSet.find(20) |> elem(0)
      iex> y = ds |> DisjointSet.find(30) |> elem(0)
      iex> x == y
      true
      iex> ds = DisjointSet.union(ds, 40, 50)
      iex> x = ds |> DisjointSet.find(20) |> elem(0)
      iex> y = ds |> DisjointSet.find(40) |> elem(0)
      iex> x == y
      false
      iex> ds = DisjointSet.union(ds, 30, 50)
      iex> x = ds |> DisjointSet.find(20) |> elem(0)
      iex> y = ds |> DisjointSet.find(40) |> elem(0)
      iex> x == y
      true
  """
  @spec union(t, any(), any()) :: t
  def union(disjoint_set, x, y) do
    {root_x, disjoint_set} = find(disjoint_set, x)
    {root_y, disjoint_set} = find(disjoint_set, y)
    rank_x = disjoint_set.rank[root_x]
    rank_y = disjoint_set.rank[root_y]

    cond do
      root_x == root_y ->
        disjoint_set

      rank_x > rank_y ->
        %{disjoint_set | root: Map.put(disjoint_set.root, root_y, root_x)}

      rank_x < rank_y ->
        %{disjoint_set | root: Map.put(disjoint_set.root, root_x, root_y)}

      true ->
        %DisjointSet{
          root: Map.put(disjoint_set.root, root_x, root_y),
          rank: Map.update!(disjoint_set.rank, root_x, &(&1 + 1))
        }
    end
  end
end
