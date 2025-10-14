defmodule SundaysTail do
  def count do
    loop(1901, 1, 2, 0)
  end

  defp loop(2001, _m, _dow, count), do: count
  defp loop(year, month, dow, count) do
    count = if dow == 0, do: count + 1, else: count
    days = days_in_month(year, month)
    next_dow = rem(dow + rem(days, 7), 7)
    {ny, nm} = next_month(year, month)
    loop(ny, nm, next_dow, count)
  end

  defp next_month(year, 12), do: {year + 1, 1}
  defp next_month(year, m),  do: {year, m + 1}

  defp days_in_month(y, 2), do: if(leap?(y), do: 29, else: 28)
  defp days_in_month(_y, m) when m in [4,6,9,11], do: 30
  defp days_in_month(_y, _m), do: 31

  defp leap?(y), do: (rem(y,4)==0 and rem(y,100)!=0) or rem(y,400)==0
end

defmodule SundaysRec do
  def count do
    rec(1901, 1, 2)
  end

  defp rec(2001, _m, _dow), do: 0
  defp rec(year, month, dow) do
    this = if dow == 0, do: 1, else: 0
    days = days_in_month(year, month)
    next_dow = rem(dow + rem(days,7), 7)
    {ny, nm} = next_month(year, month)
    this + rec(ny, nm, next_dow)
  end

  defp next_month(year, 12), do: {year+1, 1}
  defp next_month(year, m),  do: {year, m+1}
  defp days_in_month(y,2), do: if(leap?(y), do: 29, else: 28)
  defp days_in_month(_y,m) when m in [4,6,9,11], do: 30
  defp days_in_month(_, _), do: 31

  defp leap?(y), do: (rem(y,4)==0 and rem(y,100)!=0) or rem(y,400)==0
end


defmodule SundaysModular do
  def count do
    months = generate_months(1901, 2000)
    months
    |> Enum.map(&first_dow(&1))
    |> Enum.filter(fn dow -> dow == 0 end)
    |> Enum.count()
  end

  defp generate_months(start_y, end_y) do
    months = for y <- start_y..end_y, m <- 1..12, do: {y, m}
    {_, res} =
      Enum.reduce(months, {2, []}, fn {y,m}, {dow, acc} ->
        days = days_in_month(y,m)
        next_dow = rem(dow + rem(days,7), 7)
        {next_dow, acc ++ [{y, m, dow}]}
      end)

    res
  end

  defp first_dow({_y, _m, dow}), do: dow

  defp days_in_month(y,2), do: if(leap?(y), do: 29, else: 28)
  defp days_in_month(_y,m) when m in [4,6,9,11], do: 30
  defp days_in_month(_, _), do: 31
  defp leap?(y), do: (rem(y,4)==0 and rem(y,100)!=0) or rem(y,400)==0
end


defmodule SundaysMap do
  def count do
    months = for y <- 1901..2000, m <- 1..12, do: {y, m}
    dows = Enum.map_reduce(months, 2, fn {y,m}, dow ->
      days = days_in_month(y,m)
      next_dow = rem(dow + rem(days,7), 7)
      {{y,m,dow}, next_dow}
    end)
    |> elem(0)
    |> Enum.map(fn {_y,_m,dow} -> dow end)

    Enum.count(dows, fn d -> d == 0 end)
  end

  defp days_in_month(y,2), do: if(leap?(y), do: 29, else: 28)
  defp days_in_month(_y,m) when m in [4,6,9,11], do: 30
  defp days_in_month(_, _), do: 31
  defp leap?(y), do: (rem(y,4)==0 and rem(y,100)!=0) or rem(y,400)==0
end


defmodule SundaysFor do
  def count do
    list =
      for {y,m,dow} <- build_with_for(), do: {y,m,dow}

    Enum.count(list, fn {_y,_m,dow} -> dow == 0 end)
  end

  defp build_with_for do
    months = for y <- 1901..2000, m <- 1..12, do: {y,m}
    {dows, _} =
      Enum.map_reduce(months, 2, fn {y,m}, dow ->
        days = days_in_month(y,m)
        next_dow = rem(dow + rem(days,7), 7)
        {{y,m,dow}, next_dow}
      end)

    dows
  end

  defp days_in_month(y,2), do: if(leap?(y), do: 29, else: 28)
  defp days_in_month(_y,m) when m in [4,6,9,11], do: 30
  defp days_in_month(_, _), do: 31
  defp leap?(y), do: (rem(y,4)==0 and rem(y,100)!=0) or rem(y,400)==0
end

defmodule SundaysStream do
  def count do
    Stream.unfold({1901,1,2}, fn
      {year, month, dow} = state ->
        if year > 2000 do
          nil
        else
          days = days_in_month(year, month)
          next_dow = rem(dow + rem(days,7), 7)
          next_state = next_month_state(year, month, next_dow)
          {{year, month, dow}, next_state}
        end
    end)
    |> Stream.filter(fn {_y,_m,dow} -> dow == 0 end)
    |> Enum.count()
  end

  defp next_month_state(2000, 12, _), do: {2001, 1, 0}
  defp next_month_state(y, 12, next_dow), do: {y+1, 1, next_dow}
  defp next_month_state(y, m, next_dow), do: {y, m+1, next_dow}

  defp days_in_month(y,2), do: if(leap?(y), do: 29, else: 28)
  defp days_in_month(_y,m) when m in [4,6,9,11], do: 30
  defp days_in_month(_, _), do: 31
  defp leap?(y), do: (rem(y,4)==0 and rem(y,100)!=0) or rem(y,400)==0
end



IO.puts("Результат полученный с помощью рекурсии" <> SundaysTail.count())
IO.puts("Результат полученный с помощью хвостовой рекурсии" <> SundaysRec.count())
IO.puts("Результат полученный с помощью модульной реализации" <> SundaysModular.count())
IO.puts("Результат полученный с помощью map" <> SundaysMap.count())
IO.puts("Результат полученный с помощью цикла for" <> SundaysFor.count())
IO.puts("Результат полученный с помощью потока" <> SundaysStream.count())
