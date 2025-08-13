defmodule Expect.MatchersTest do
  # @related [subject](lib/expect/matchers.ex)
  use ExUnit.Case, async: true

  alias Expect.AssertionError

  import Expect
  import Expect.Matchers

  test "equals matcher" do
    expect(true, to: be_equal_to(true))
    expect(1234, to: be_equal_to(1234))
    expect("ok", to: be_equal_to("ok"))
    expect(:ok, to: be_equal_to(:ok))
    expect(1, to: be_equal_to(1.0))

    assert_raise AssertionError, "Expected 'true' to equal 'false'", fn ->
      expect(true, to: be_equal_to(false))
    end

    assert_raise AssertionError, "Expected '1' to strictly equal '1.0'", fn ->
      expect(1, to: be_equal_to(1.0, :strict))
    end

    assert_raise AssertionError, "Expected '[1, 2, 3]' to equal '[4, 5, 6]'", fn ->
      expect([1, 2, 3], to: be_equal_to([4, 5, 6]))
    end
  end

  describe "to_contain matcher" do
    test "verifies that the value is in the list" do
      expect([1, 2, 3], to: contain(1))

      assert_raise AssertionError, "Expected '[1, 2, 3]' to contain '\"bananas\"'", fn ->
        expect([1, 2, 3], to: contain("bananas"))
      end
    end

    test "verifies that the value is the only one present" do
      expect([1], to: contain(only: 1))

      # nb: keyword lists are actually just syntactic sugar for a list of tuples of size 2 {:key, value}
      #     (this is why a keyword list can contain the same key multiple times, unlike a map)
      expect([only: 1], to: contain({:only, 1}))

      assert_raise AssertionError, "Expected '[1, 2, 3]' to only contain '1'", fn ->
        expect([1, 2, 3], to: contain(only: 1))
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
    expect([], to: be_empty())
    expect(%{}, to: be_empty())
    expect({}, to: be_empty())

    expect([1], to_not: be_empty())
    expect(%{key: "value"}, to_not: be_empty())
    expect({1}, to_not: be_empty())

    assert_raise AssertionError, "Expected '[1]' to be empty", fn ->
      expect([1], to: be_empty())
    end

    assert_raise AssertionError, "Expected '{1}' to be empty", fn ->
      expect({1}, to: be_empty())
    end

    assert_raise AssertionError, "Expected '%{key: \"value\"}' to be empty", fn ->
      expect(%{key: "value"}, to: be_empty())
    end

    assert_raise AssertionError,
                 ~s[Expected '"WHOOPS"' to be empty, but it's not a list, map, or tuple.],
                 fn -> expect("WHOOPS", to: be_empty()) end

    assert_raise AssertionError,
                 ~s[Expected '"WHOOPS"' to not be empty, but it's not a list, map, or tuple.],
                 fn -> expect("WHOOPS", to_not: be_empty()) end
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

  test "to_be_nil matcher" do
    expect(nil) |> to_be_nil()

    assert_raise AssertionError, ~s[Expected '"not nil"' to be nil], fn ->
      expect("not nil") |> to_be_nil()
    end
  end

  test "length matcher" do
    expect([]) |> to_have_length(0)
    expect([:madness]) |> to_have_length(1)
    expect(hello: :world) |> to_have_length(1)

    expect("hello") |> to_have_length(5)

    assert_raise AssertionError, ~s<Expected '[]' to have length 99, but it is actually 0>, fn ->
      expect([]) |> to_have_length(99)
    end

    assert_raise AssertionError,
                 ~s[Expected 'nil' to have length 99, but it is neither a list nor a string],
                 fn ->
                   expect(nil) |> to_have_length(99)
                 end
  end

  describe "to_match matcher" do
    test "can pattern match maps, lists, tuples, and structs" do
      expect(%{hello: _whom}, to_match: %{hello: "world"})
    end

    test "shows an informative error when the pattern match fails" do
      assert_raise AssertionError,
                   ~s[Expected '%{hello: "whoopsie"}' to match pattern '%{hello: "world"}', but it did not.],
                   fn -> expect(%{hello: "whoopsie"}, to_match: %{hello: "world"}) end

      assert_raise AssertionError,
                   ~s[Expected '%{goodbye: _cruel_world}' to match pattern '%{hello: "world"}', but it did not.],
                   fn -> expect(%{goodbye: _cruel_world}, to_match: %{hello: "world"}) end

      wont_match = %{hello: "world"}

      assert_raise AssertionError,
                   ~s[Expected '%{goodbye: _cruel_world}' to match pattern 'wont_match', but it did not.],
                   fn -> expect(%{goodbye: _cruel_world}, to_match: wont_match) end
    end
  end
end
