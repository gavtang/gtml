defmodule Gtml.ZipperMerge do
  def merge(enum1, enum2) do
    do_merge(enum1, enum2, [])
  end

  defp do_merge([], [], acc), do: Enum.reverse(acc)
  defp do_merge([h1 | t1], [], acc), do: do_merge(t1, [], [h1 | acc])
  defp do_merge([], [h2 | t2], acc), do: do_merge([], t2, [h2 | acc])
  defp do_merge([h1 | t1], [h2 | t2], acc), do: do_merge(t1, t2, [h2, h1 | acc])
end
