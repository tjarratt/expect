defmodule ExpectAssertionsTest do
  use ExUnit.Case

  alias ExpectAssertions.AssertionError

  import ExpectAssertions
  import ExpectAssertions.Matchers

  test "equals matcher" do
    expect(true) |> to_equal(true)
    expect(1234) |> to_equal(1234)
    expect("ok") |> to_equal("ok")
    expect(:ok)  |> to_equal(:ok)

    assert_raise AssertionError, "Expected 'true' to equal 'false'", fn -> 
      expect(true) |> to_equal(false)
    end

    assert_raise AssertionError, "Expected '[1, 2, 3]' to equal '[4, 5, 6]'", fn -> 
      expect([1,2,3]) |> to_equal([4,5,6])
    end
  end

  test "to_contain matcher" do
    expect([1,2,3]) |> to_contain(1)

    assert_raise AssertionError, "Expected '[1, 2, 3]' to contain '\"bananas\"'", fn -> 
      expect([1,2,3]) |> to_contain("bananas")
    end
  end

  test "to_match_regex matcher" do
    expect("hello") |> to_match_regex(~r[^h])

    assert_raise AssertionError, "Expected '\"hello world\"' to match regex '~r/NOPE/'", fn -> 
      expect("hello world") |> to_match_regex(~r[NOPE])
    end
  end
end
