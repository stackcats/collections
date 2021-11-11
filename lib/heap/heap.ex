defmodule Collections.Heap do
  defstruct data: nil, size: 0, comparator: nil

  @moduledoc """
  Leftist heap implemention in Elixir

  See also: [Leftist Tree](https://en.wikipedia.org/wiki/Leftist_tree)

  Time complexity

  * `&peek/2`    : O(1)
  * `&push/2`    : O(logn)
  * `&pop/2`     : O(logn)
  * `&size/1`    : O(1)
  * `&member?/2` : O(n)
  * `&empty?/1`  : O(1)
  """

  alias Collections.Heap

  @type data :: {non_neg_integer(), any(), data(), data()} | nil

  @type t :: %__MODULE__{
          data: data(),
          size: non_neg_integer(),
          comparator: (any(), any() -> boolean())
        }

  @leaf nil

  @compile {:min, :max, :new, :size, :peek}

  @doc """
  Create an empty min `heap` with default comparator `&</2`.

  A min heap is a heap tree which always has the smallest value at the top.

  ## Examples

      iex> 1..10
      ...>   |> Enum.shuffle()
      ...>   |> Enum.into(Collections.Heap.min())
      ...>   |> Collections.Heap.peek()
      1
  """
  @spec min() :: t
  def min, do: Heap.new(&</2)

  @doc """
  Create an empty max `heap` with default comparator `&>/2`.

  A max heap is a heap tree which always has the largest value at the top.

  ## Examples

      iex> 1..10
      ...>   |> Enum.shuffle()
      ...>   |> Enum.into(Collections.Heap.max())
      ...>   |> Collections.Heap.peek()
      10
  """
  @spec max() :: t
  def max, do: Heap.new(&>/2)

  @doc """
  Create an empty heap with the default comparator `&</2`.

  Behaves the same as `&Heap.min`
  """
  @spec new() :: t
  def new(), do: %Heap{comparator: &</2}

  @doc """
  Create an empty heap with a specific comparator.

  ## Examples

        iex> 1..10
        ...>   |> Enum.shuffle()
        ...>   |> Enum.into(Collections.Heap.new(&(&1 > &2)))
        ...>   |> Enum.to_list()
        [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

  The given function should compare two arguments, and return true if the first argument precedes the second one.
  """
  @spec new((any, any -> boolean)) :: t
  def new(comparator) when is_function(comparator, 2), do: %Heap{comparator: comparator}

  @doc """
  Test if the `heap` is empty

  ## Examples

      iex> Collections.Heap.new() |> Collections.Heap.empty?()
      true
      
      iex> Collections.Heap.new() |> Collections.Heap.push(10) |> Collections.Heap.empty?()
      false
  """
  @spec empty?(t) :: boolean
  def empty?(t), do: Heap.size(t) == 0

  @doc """
  Returns the number of elements in `heap`.

  ## Examples

      iex> 1..10
      ...>   |> Enum.into(Collections.Heap.new())
      ...>   |> Collections.Heap.size()
      10
  """
  @spec size(t) :: non_neg_integer()
  def size(%Heap{size: size}), do: size

  @doc """
  Push a new element into `heap`.

  ## Examples

      iex> Collections.Heap.new()
      ...>   |> Collections.Heap.push(10)
      ...>   |> Collections.Heap.peek()
      10
  """
  @spec push(t, any()) :: t
  def push(%Heap{data: data, size: size, comparator: cmp}, value) do
    %Heap{data: merge(data, {1, value, @leaf, @leaf}, cmp), size: size + 1, comparator: cmp}
  end

  @doc """
  Returns the element at the top of `heap`.

  If the `heap` is empty, `default` is returned

  If `default` is not provided, nil is used

  ## Examples

      iex> Collections.Heap.new()
      ...>   |> Collections.Heap.peek()
      nil

      iex> Collections.Heap.new()
      ...>   |> Collections.Heap.peek(10)
      10

      iex> 1..10
      ...>   |> Enum.shuffle()
      ...>   |> Enum.into(Collections.Heap.new())
      ...>   |> Collections.Heap.peek()
      1
  """
  @spec peek(t, default) :: any() | default when default: any()
  def peek(heap, default \\ nil)
  def peek(%Heap{data: nil}, default), do: default
  def peek(%Heap{data: {_, v, _, _}}, _default), do: v

  @doc """
  Removes the element at the top of the `heap` and returns the element and the updated heap.

  If the `heap` is empty, `default` is returned

  If `default` is not provided, nil is used

  ## Examples

      iex> {nil, _} = Collections.Heap.new()
      ...>   |> Collections.Heap.pop()

      iex> {10, _} = Collections.Heap.new()
      ...>   |> Collections.Heap.pop(10)

      iex> {1, rest_heap} = 1..10
      ...>   |> Enum.shuffle()
      ...>   |> Enum.into(Collections.Heap.new())
      ...>   |> Collections.Heap.pop()
      ...> {2, _} = Collections.Heap.pop(rest_heap)
      ...> Collections.Heap.size(rest_heap)
      9
  """
  @spec pop(t, default) :: {any(), updated_heap :: t} | {default, t} when default: any()
  def pop(heap, default \\ nil)
  def pop(%Heap{data: nil, size: 0} = heap, default), do: {default, heap}

  def pop(%Heap{data: {_, v, l, r}, size: size, comparator: cmp}, _default),
    do: {v, %Heap{data: merge(l, r, cmp), size: size - 1, comparator: cmp}}

  @doc """
  Test if the `heap` contains the `value`.

  ## Examples

      iex> heap = 1..10
      ...>   |> Enum.into(Collections.Heap.new())
      ...> Collections.Heap.member?(heap, 5)
      true
      ...> Collections.Heap.member?(heap, 20)
      false
  """
  @spec member?(t, any()) :: boolean()
  def member?(%Heap{data: data}, value), do: has_member?(data, value)

  @spec rank(data()) :: non_neg_integer()
  defp rank(@leaf), do: 0
  defp rank({r, _, _, _}), do: r

  @spec merge(data(), data(), (any(), any() -> boolean())) :: data()
  defp merge(@leaf, @leaf, _cmp), do: nil
  defp merge(@leaf, t, _cmp), do: t
  defp merge(t, @leaf, _com), do: t

  defp merge({_, lv, ll, lr} = t1, {_, rv, rl, rr} = t2, cmp) do
    case cmp.(lv, rv) do
      true -> swipe(lv, ll, merge(lr, t2, cmp))
      false -> swipe(rv, rl, merge(t1, rr, cmp))
      err -> raise("Comparator should return boolean, but returned '#{err}'.")
    end
  end

  @spec swipe(any(), data(), data()) :: data()
  defp swipe(v, left, right) do
    if rank(left) >= rank(right) do
      {rank(right) + 1, v, left, right}
    else
      {rank(left) + 1, v, right, left}
    end
  end

  @spec has_member?(data(), any()) :: boolean()
  defp has_member?(nil, _value), do: false

  defp has_member?({_, v, l, r}, value) do
    if v == value do
      true
    else
      has_member?(l, value) || has_member?(r, value)
    end
  end
end
