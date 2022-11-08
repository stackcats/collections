defimpl Enumerable, for: Collections.Heap do
  @moduledoc """
  Implements `Enumerable` for `Heap`.
  """

  alias Collections.Heap

  @doc """
  Returns the number of elements in the `heap`.

  ## Examples

      iex> 1..500
      ...>  |> Enum.into(Heap.new())
      ...>  |> Enum.count()
      500
  """
  @spec count(Heap.t()) :: {:ok, non_neg_integer}
  def count(heap), do: {:ok, Heap.size(heap)}

  @doc """
  Returns true if the element is a contained in the `heap`.

  ## Examples

      iex> heap = 1..10
      ...>   |> Enum.into(Heap.new())
      ...> Heap.member?(heap, 5)
      true
      ...> Heap.member?(heap, 20)
      false
  """
  @spec member?(Heap.t(), term) :: {:ok, boolean()}
  def member?(heap, value), do: {:ok, Heap.member?(heap, value)}

  @doc """
  Allows reduction to be applied to Heaps.

  ## Examples

      iex> 1..500
      ...>  |> Enum.shuffle()
      ...>  |> Enum.into(Heap.new())
      ...>  |> Enum.filter(&(Integer.mod(&1, 2) == 0))
      ...>  |> Enum.count()
      250
  """
  @spec reduce(Heap.t(), Enumerable.acc(), Enumerable.reducer()) :: Enumerable.result()
  def reduce(_, {:halt, acc}, _fun), do: {:halted, acc}
  def reduce(heap, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(heap, &1, fun)}

  def reduce(heap, {:cont, acc}, fun) do
    case Heap.pop(heap) do
      {nil, _} ->
        {:done, acc}

      {top, rest_heap} ->
        reduce(rest_heap, fun.(top, acc), fun)
    end
  end

  @spec slice(Heap.t()) :: {:error, __MODULE__}
  def slice(_heap), do: {:error, __MODULE__}
end
