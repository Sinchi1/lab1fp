ExUnit.start()

defmodule ScDictTest do
  use ExUnit.Case
  use ExUnitProperties
  alias Lab2

  test "insert and get" do
    m = Lab2.new()
    m = Lab2.put(:a, 1, m)
    m = Lab2.put(:b, 2, m)
    assert Lab2.get(:a, m) == 1
    assert Lab2.get(:b, m) == 2
    assert Lab2.size(m) == 2
  end

  test "delete" do
    m = Lab2.from_list([{:x, 10}, {:y, 20}, {:z, 30}])
    m2 = Lab2.delete(:y, m)
    assert Lab2.size(m2) == 2
    assert Lab2.get(:y, m2) == nil
  end

  test "filter and map_values" do
    m = Lab2.from_list([{:a, 1}, {:b, 2}, {:c, 3}])
    m2 = Lab2.filter(m, fn _k, v -> v > 1 end)
    assert Lab2.size(m2) == 2
    m3 = Lab2.map_values(m2, fn v -> v * 10 end)
    assert Lab2.get(:b, m3) == 20
  end

  test "equality ignores bucket order" do
    a = Lab2.from_list([{:k1, "x"}, {:k2, "y"}])
    b = Lab2.from_list([{:k2, "y"}, {:k1, "x"}])
    assert Lab2.equal?(a, b)
  end

  property "lookup after put" do
    check all pairs <- list_of(tuple({term(), integer()})) do
      m = Lab2.from_list(pairs)
      k = make_ref()
      v = Enum.random(-1000..1000)
      m2 = Lab2.put(k, v, m)
      assert Lab2.get(k, m2) == v
    end
  end

  property "monoid left identity" do
    check all pairs <- list_of(tuple({term(), integer()})) do
      m = Lab2.from_list(pairs)
      assert Lab2.equal?(Lab2.union(Lab2.new(), m), m)
    end
  end

  property "monoid right identity" do
    check all pairs <- list_of(tuple({term(), integer()})) do
      m = Lab2.from_list(pairs)
      assert Lab2.equal?(Lab2.union(m, Lab2.new()), m)
    end
  end

  property "monoid associativity" do
    check all a_pairs <- list_of(tuple({term(), integer()}), max_length: 5),
              b_pairs <- list_of(tuple({term(), integer()}), max_length: 5),
              c_pairs <- list_of(tuple({term(), integer()}), max_length: 5) do
      a = Lab2.from_list(a_pairs)
      b = Lab2.from_list(b_pairs)
      c = Lab2.from_list(c_pairs)
      left = Lab2.union(Lab2.union(a, b), c)
      right = Lab2.union(a, Lab2.union(b, c))
      assert Lab2.equal?(left, right)
    end
  end

  property "union size bounds" do
    check all a_pairs <- list_of(tuple({term(), integer()}), max_length: 6),
              b_pairs <- list_of(tuple({term(), integer()}), max_length: 6) do
      a = Lab2.from_list(a_pairs)
      b = Lab2.from_list(b_pairs)
      u = Lab2.union(a, b)
      s_u = Lab2.size(u)
      s_a = Lab2.size(a)
      s_b = Lab2.size(b)
      assert s_u >= max(s_a, s_b)
      assert s_u <= s_a + s_b
    end
  end
end
