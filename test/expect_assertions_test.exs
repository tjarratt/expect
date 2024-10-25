defmodule ExpectAssertionsTest do
  # @related [subject](lib/expect_assertions.ex)
  use ExUnit.Case

  alias ExpectAssertions.AssertionError

  import ExpectAssertions
  import ExpectAssertions.Matchers

  test "equals matcher" do
    expect(true) |> to_equal(true)
    expect(1234) |> to_equal(1234)
    expect("ok") |> to_equal("ok")
    expect(:ok)  |> to_equal(:ok)
    expect(1)    |> to_equal(1.0)

    assert_raise AssertionError, "Expected 'true' to equal 'false'", fn -> 
      expect(true) |> to_equal(false)
    end

    assert_raise AssertionError, "Expected '1' to strictly equal '1.0'", fn ->
      expect(1) |> to_equal(1.0, :strict)
    end

    assert_raise AssertionError, "Expected '[1, 2, 3]' to equal '[4, 5, 6]'", fn -> 
      expect([1,2,3]) |> to_equal([4,5,6])
    end
  end

  test "to_contain matcher" do
    expect([1, 2, 3]) |> to_contain(1)

    assert_raise AssertionError, "Expected '[1, 2, 3]' to contain '\"bananas\"'", fn ->
      expect([1, 2, 3]) |> to_contain("bananas")
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
end
