defmodule Expect.MatchersTest do
  # @related [subject](lib/expect/matchers.ex)
  use ExUnit.Case

  alias Expect.AssertionError

  import Expect
  import Expect.Matchers

  test "equals matcher" do
    expect(true) |> to_equal(true)
    expect(1234) |> to_equal(1234)
    expect("ok") |> to_equal("ok")
    expect(:ok) |> to_equal(:ok)
    expect(1) |> to_equal(1.0)

    assert_raise AssertionError, "Expected 'true' to equal 'false'", fn ->
      expect(true) |> to_equal(false)
    end

    assert_raise AssertionError, "Expected '1' to strictly equal '1.0'", fn ->
      expect(1) |> to_equal(1.0, :strict)
    end

    assert_raise AssertionError, "Expected '[1, 2, 3]' to equal '[4, 5, 6]'", fn ->
      expect([1, 2, 3]) |> to_equal([4, 5, 6])
    end
  end

  describe "to_contain matcher" do
    test "verifies that the value is in the list" do
      expect([1, 2, 3]) |> to_contain(1)

      assert_raise AssertionError, "Expected '[1, 2, 3]' to contain '\"bananas\"'", fn ->
        expect([1, 2, 3]) |> to_contain("bananas")
      end
    end

    test "verifies that the value is the only one present" do
      expect([1]) |> to_contain(only: 1)

      # keyword lists are actually a list of tuples of size 2 {:key, value}
      expect(only: 1) |> to_contain({:only, 1})

      assert_raise AssertionError, "Expected '[1, 2, 3]' to only contain '1'", fn ->
        expect([1, 2, 3]) |> to_contain(only: 1)
      end
    end
  end

  test "to_match_regex matcher" do
    expect("hello") |> to_match_regex(~r[^h])

    assert_raise AssertionError, "Expected '\"hello world\"' to match regex '~r/NOPE/'", fn ->
      expect("hello world") |> to_match_regex(~r[NOPE])
    end
  end

  test "to_be_empty matcher" do
    expect([]) |> to_be_empty()
    expect(%{}) |> to_be_empty()
    expect({}) |> to_be_empty()

    assert_raise AssertionError, "Expected list '[1]' to be empty", fn ->
      expect([1]) |> to_be_empty()
    end

    assert_raise AssertionError, "Expected tuple '{1}' to be empty", fn ->
      expect({1}) |> to_be_empty()
    end

    assert_raise AssertionError, "Expected map '%{key: \"value\"}' to be empty", fn ->
      expect(%{key: "value"}) |> to_be_empty()
    end

    assert_raise AssertionError,
                 "Expected '\"WHOOPS\"' to be empty, but it's not a list, map, or tuple.",
                 fn ->
                   expect("WHOOPS") |> to_be_empty()
                 end
  end

  test "to_be_truthy matcher" do
    expect(true) |> to_be_truthy()
    expect("anything besides literal nil or false") |> to_be_truthy()

    assert_raise AssertionError, "Expected 'nil' to be truthy", fn ->
      expect(nil) |> to_be_truthy()
    end

    assert_raise AssertionError, "Expected 'false' to be truthy", fn ->
      expect(false) |> to_be_truthy()
    end
  end
end
