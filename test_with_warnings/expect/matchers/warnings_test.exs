defmodule Expect.Matchers.RaisesWarningsTest do
  # @related [subject](lib/expect/matchers.ex)
  use ExUnit.Case, async: true
  use Expect

  alias Expect.AssertionError

  describe "negative assertions with pattern_match/1" do
    test "can pattern match maps, lists, tuples, and structs" do
      expect(%{hello: _whom}, to_not: pattern_match(%{goodbye: "sweet world"}))
      expect([_not_enough], to_not: pattern_match([1, 2, 3]))
      expect({_not_enough}, to_not: pattern_match({:a, :b}))
      expect(%{whoops: _my_bad}, to_not: pattern_match(%Date{year: 1999, month: 12, day: 31}))
    end

    test "shows an informative error when it does match" do
      assert_raise AssertionError,
                   ~s[Expected '%{hello: "world"}' to not match pattern '%{hello: "world"}', but it did.],
                   fn -> expect(%{hello: "world"}, to_not: pattern_match(%{hello: "world"})) end

      assert_raise AssertionError,
                   ~s[Expected '%{goodbye: _cruel_world}' to match pattern '%{hello: "world"}', but it did not.],
                   fn ->
                     expect(%{goodbye: _cruel_world}, to: pattern_match(%{hello: "world"}))
                   end

      wont_match = %{hello: "world"}

      assert_raise AssertionError,
                   ~s[Expected '%{goodbye: _cruel_world}' to match pattern 'wont_match', but it did not.],
                   fn -> expect(%{goodbye: _cruel_world}, to: pattern_match(wont_match)) end
    end
  end
end
