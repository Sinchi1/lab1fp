defmodule Lab2 do
  defstruct buckets: [], size: 0

  @default_buckets 16

  def new(), do: %Lab2{buckets: (for _ <- 1..@default_buckets, do: []), size: 0}

  def with_buckets(n) when is_integer(n) and n > 0 do
    %Lab2{buckets: (for _ <- 1..n, do: []), size: 0}
  end

  defp bucket_index(%Lab2{buckets: buckets}, key) do
    :erlang.phash2(key, length(buckets))
  end

  def put(key, value, %Lab2{} = m) do
    idx = bucket_index(m, key)
    {new_bucket, replaced?} = put_in_bucket(Enum.at(m.buckets, idx), key, value)
    new_buckets = List.replace_at(m.buckets, idx, new_bucket)
    new_size = if replaced?, do: m.size, else: m.size + 1
    %Lab2{m | buckets: new_buckets, size: new_size}
  end

  defp put_in_bucket(bucket, key, value) do
    case Enum.split_with(bucket, fn {k, _v} -> k != key end) do
      {left, [{_k, _old_v} | right]} ->
        {left ++ [{key, value} | right], true}

      {left, []} ->
        {[{key, value} | left], false}
    end
  end

  def delete(key, %Lab2{} = m) do
    idx = bucket_index(m, key)
    {removed?, new_bucket} = remove_from_bucket(Enum.at(m.buckets, idx), key)
    new_buckets = List.replace_at(m.buckets, idx, new_bucket)
    new_size = if removed?, do: m.size - 1, else: m.size
    %Lab2{m | buckets: new_buckets, size: new_size}
  end

  defp remove_from_bucket(bucket, key) do
    case Enum.split_with(bucket, fn {k, _v} -> k != key end) do
      {left, [{_k, _v} | right]} -> {true, left ++ right}
      {_left, []} -> {false, bucket}
    end
  end

  def get(key, %Lab2{} = m) do
    idx = bucket_index(m, key)
    Enum.find_value(Enum.at(m.buckets, idx), fn
      {k, v} when k == key -> v
      _ -> nil
    end)
  end

  def fetch(key, %Lab2{} = m) do
    case get(key, m) do
      nil -> :error
      v -> {:ok, v}
    end
  end

  def to_list(%Lab2{} = m), do: Enum.flat_map(m.buckets, fn b -> b end)

  def from_list(pairs) when is_list(pairs) do
    Enum.reduce(pairs, new(), fn {k, v}, acc -> put(k, v, acc) end)
  end

  def filter(%Lab2{} = m, fun) when is_function(fun, 2) do
    new_buckets = Enum.map(m.buckets, fn bucket -> Enum.filter(bucket, fn {k, v} -> fun.(k, v) end) end)
    new_size = Enum.reduce(new_buckets, 0, fn b, s -> s + length(b) end)
    %Lab2{m | buckets: new_buckets, size: new_size}
  end

  def map_values(%Lab2{} = m, fun) when is_function(fun, 1) do
    new_buckets = Enum.map(m.buckets, fn bucket -> Enum.map(bucket, fn {k, v} -> {k, fun.(v)} end) end)
    %Lab2{m | buckets: new_buckets}
  end

  def foldl(%Lab2{} = m, acc, fun) when is_function(fun, 3) do
    to_list(m) |> Enum.reduce(acc, fn {k, v}, a -> fun.(a, k, v) end)
  end

  def foldr(%Lab2{} = m, acc, fun) when is_function(fun, 3) do
    to_list(m) |> Enum.reverse() |> Enum.reduce(acc, fn {k, v}, a -> fun.(k, v, a) end)
  end

  def size(%Lab2{size: s}), do: s

  def union(%Lab2{} = a, %Lab2{} = b) do
    foldl(b, a, fn acc, k, v -> put(k, v, acc) end)
  end

  def equal?(%Lab2{} = a, %Lab2{} = b) do
    if size(a) != size(b) do
      false
    else
      Enum.all?(to_list(a), fn {k, v} ->
        case fetch(k, b) do
          {:ok, vb} -> vb == v
          :error -> false
        end
      end)
    end
  end
end
