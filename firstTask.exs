defmodule FirstTask1 do
  defp max_product(grid), do: iterate(grid, 0, 0, 0)

  defp iterate(grid, i, j, best) do
    cond do
      i >= length(grid) -> best
      j >= length(Enum.at(grid, i)) -> iterate(grid, i + 1, 0, best)
      true ->
        val = Enum.max([
          right(grid, i, j),
          down(grid, i, j),
          diag_dr(grid, i, j),
          diag_dl(grid, i, j)
        ])
        iterate(grid, i, j + 1, max(best, val))
    end
  end

  defp val(g, i, j), do: Enum.at(Enum.at(g, i, []), j, 0)
  defp right(g,i,j), do: Enum.reduce(0..3, 1, &(&2 * val(g,i,j+&1)))
  defp down(g,i,j), do: Enum.reduce(0..3, 1, &(&2 * val(g,i+&1,j)))
  defp diag_dr(g,i,j), do: Enum.reduce(0..3, 1, &(&2 * val(g,i+&1,j+&1)))
  defp diag_dl(g,i,j), do: Enum.reduce(0..3, 1, &(&2 * val(g,i+&1,j-&1)))

  def main(grid) do
        IO.puts("Grid problem:")
        result = max_product(grid)
        IO.puts("Максимальное произведение из 4 подряд идущих чисел: #{result} \n")
  end
end

defmodule EulerTailRec do
  def max_product(grid), do: loop(grid, 0, 0, 0)

  defp loop(grid, i, j, acc) when i == 20, do: acc
  defp loop(grid, i, j, acc) when j == 20, do: loop(grid, i + 1, 0, acc)
  defp loop(grid, i, j, acc) do
    val = Enum.max([
      right(grid,i,j), down(grid,i,j), diag_dr(grid,i,j), diag_dl(grid,i,j)
    ])
    loop(grid, i, j + 1, max(acc, val))
  end

  defp val(g,i,j), do: Enum.at(Enum.at(g,i,[]), j, 0)
  defp right(g,i,j), do: Enum.reduce(0..3, 1, &(&2 * val(g,i,j+&1)))
  defp down(g,i,j), do: Enum.reduce(0..3, 1, &(&2 * val(g,i+&1,j)))
  defp diag_dr(g,i,j), do: Enum.reduce(0..3, 1, &(&2 * val(g,i+&1,j+&1)))
  defp diag_dl(g,i,j), do: Enum.reduce(0..3, 1, &(&2 * val(g,i+&1,j-&1)))

    def main(grid) do
        result = max_product(grid)
        IO.puts("Максимальное произведение из 4 подряд идущих чисел: #{result} \n")
    end
end

defmodule EulerModular do
  def max_product(grid) do
    generate_coords(20, 20)
    |> Enum.map(&products(grid, &1))
    |> List.flatten()
    |> Enum.max()
  end

  defp generate_coords(w, h) do
    for i <- 0..(w-1), j <- 0..(h-1), do: {i, j}
  end

  defp products(grid, {i, j}) do
    [:right, :down, :diag_dr, :diag_dl]
    |> Enum.map(fn dir -> product(grid, i, j, dir) end)
  end

  defp product(g, i, j, dir) do
    vals =
      case dir do
        :right   -> for k <- 0..3, do: val(g,i,j+k)
        :down    -> for k <- 0..3, do: val(g,i+k,j)
        :diag_dr -> for k <- 0..3, do: val(g,i+k,j+k)
        :diag_dl -> for k <- 0..3, do: val(g,i+k,j-k)
      end
    Enum.reduce(vals, 1, &(&1 * &2))
  end

  defp val(g,i,j), do: Enum.at(Enum.at(g,i,[]), j, 0)

    def main(grid) do
        result = max_product(grid)
        IO.puts("Максимальное произведение из 4 подряд идущих чисел: #{result} \n")
    end
end

defmodule EulerMap do
  def max_product(grid,w,h) do
    coords = for i <- 0..(w-1), j <- 0..(h-1), do: {i, j}
    coords
    |> Enum.map(&directions(grid, &1))
    |> List.flatten()
    |> Enum.max()
  end

  defp directions(grid, {i, j}) do
    Enum.map([:r, :d, :dr, :dl], fn dir ->
      product(grid, i, j, dir)
    end)
  end

  defp val(g,i,j), do: Enum.at(Enum.at(g,i,[]), j, 0)
  defp product(g,i,j,:r), do: val(g,i,j)*val(g,i,j+1)*val(g,i,j+2)*val(g,i,j+3)
  defp product(g,i,j,:d), do: val(g,i,j)*val(g,i+1,j)*val(g,i+2,j)*val(g,i+3,j)
  defp product(g,i,j,:dr), do: val(g,i,j)*val(g,i+1,j+1)*val(g,i+2,j+2)*val(g,i+3,j+3)
  defp product(g,i,j,:dl), do: val(g,i,j)*val(g,i+1,j-1)*val(g,i+2,j-2)*val(g,i+3,j-3)

  def main(grid,w \\ 20, h \\ 20) do
        result = max_product(grid,w,h)
        IO.puts("Максимальное произведение из 4 подряд идущих чисел: #{result} \n")
  end
end

defmodule EulerFor do
  def max_product(grid,w,h) do
    (
    for i <- 0..(w-1),
        j <- 0..(h-1),
        dir <- [:r, :d, :dr, :dl],
        do: product(grid, i, j, dir)
    )
    |> Enum.max()
  end

  defp val(g,i,j), do: Enum.at(Enum.at(g,i,[]), j, 0)
  defp product(g,i,j,:r), do: val(g,i,j)*val(g,i,j+1)*val(g,i,j+2)*val(g,i,j+3)
  defp product(g,i,j,:d), do: val(g,i,j)*val(g,i+1,j)*val(g,i+2,j)*val(g,i+3,j)
  defp product(g,i,j,:dr), do: val(g,i,j)*val(g,i+1,j+1)*val(g,i+2,j+2)*val(g,i+3,j+3)
  defp product(g,i,j,:dl), do: val(g,i,j)*val(g,i+1,j-1)*val(g,i+2,j-2)*val(g,i+3,j-3)

  def main(grid,w \\ 20,h \\ 20) do
        result = max_product(grid, w,h)
        IO.puts("Максимальное произведение из 4 подряд идущих чисел: #{result} \n")
  end
end

defmodule EulerStream do
  def max_product(grid,w,h) do
    Stream.flat_map(0..(w-1), fn i ->
      Stream.map(0..(h-1), fn j -> {i, j} end)
    end)
    |> Stream.flat_map(fn {i, j} ->
      [
        right(grid, i, j),
        down(grid, i, j),
        diag_dr(grid, i, j),
        diag_dl(grid, i, j)
      ]
    end)
    |> Enum.max()
  end

  defp val(g,i,j), do: Enum.at(Enum.at(g,i,[]), j, 0)
  defp right(g,i,j), do: Enum.reduce(0..3, 1, &(&2 * val(g,i,j+&1)))
  defp down(g,i,j), do: Enum.reduce(0..3, 1, &(&2 * val(g,i+&1,j)))
  defp diag_dr(g,i,j), do: Enum.reduce(0..3, 1, &(&2 * val(g,i+&1,j+&1)))
  defp diag_dl(g,i,j), do: Enum.reduce(0..3, 1, &(&2 * val(g,i+&1,j-&1)))

  def main(grid,w \\ 20,h \\ 20) do
        result = max_product(grid,w,h)
        IO.puts("Максимальное произведение из 4 подряд идущих чисел: #{result} \n")
  end
end



grid = [
    [8,2,22,97,38,15,0,40,0,75,4,5,7,78,52,12,50,77,91,8],
    [49,49,99,40,17,81,18,57,60,87,17,40,98,43,69,48,4,56,62,0],
    [81,49,31,73,55,79,14,29,93,71,40,67,53,88,30,3,49,13,36,65],
    [52,70,95,23,4,60,11,42,69,24,68,56,1,32,56,71,37,2,36,91],
    [22,31,16,71,51,67,63,89,41,92,36,54,22,40,40,28,66,33,13,80],
    [24,47,32,60,99,3,45,2,44,75,33,53,78,36,84,20,35,17,12,50],
    [32,98,81,28,64,23,67,10,26,38,40,67,59,54,70,66,18,38,64,70],
    [67,26,20,68,2,62,12,20,95,63,94,39,63,8,40,91,66,49,94,21],
    [24,55,58,5,66,73,99,26,97,17,78,78,96,83,14,88,34,89,63,72],
    [21,36,23,9,75,0,76,44,20,45,35,14,0,61,33,97,34,31,33,95],
    [78,17,53,28,22,75,31,67,15,94,3,80,4,62,16,14,9,53,56,92],
    [16,39,5,42,96,35,31,47,55,58,88,24,0,17,54,24,36,29,85,57],
    [86,56,0,48,35,71,89,7,5,44,44,37,44,60,21,58,51,54,17,58],
    [19,80,81,68,5,94,47,69,28,73,92,13,86,52,17,77,4,89,55,40],
    [4,52,8,83,97,35,99,16,7,97,57,32,16,26,26,79,33,27,98,66],
    [88,36,68,87,57,62,20,72,3,46,33,67,46,55,12,32,63,93,53,69],
    [4,42,16,73,38,25,39,11,24,94,72,18,8,46,29,32,40,62,76,36],
    [20,69,36,41,72,30,23,88,34,62,99,69,82,67,59,85,74,4,36,16],
    [20,73,35,29,78,31,90,1,74,31,49,71,48,86,81,16,23,57,5,54],
    [1,70,54,71,83,51,54,69,16,92,33,48,61,43,52,1,89,19,67,48]
]

FirstTask1.main(grid)
EulerTailRec.main(grid)
EulerModular.main(grid)
EulerMap.main(grid)
EulerFor.main(grid)
EulerStream.main(grid)
