defmodule Expect.Matchers.RaisesWarningsTest do
  # @related [subject](lib/expect/matchers.ex)
  use ExUnit.Case, async: true

  alias Expect.AssertionError

  import Expect
  import Expect.Matchers

  describe "pattern_match matcher" do
    test "can verify a given value does not pattern match" do
      expect(%{hello: _whom}, to_not: pattern_match(%{goodbye: "sweet world"}))

      assert_raise AssertionError,
                   ~s[Expected '%{hello: "world"}' to not match pattern '%{hello: "world"}', but it did.],
                   fn -> expect(%{hello: "world"}, to_not: pattern_match(%{hello: "world"})) end
    end

    test "shows an informative error when the pattern match fails" do
      assert_raise AssertionError,
                   ~s[Expected '%{hello: "whoopsie"}' to match pattern '%{hello: "world"}', but it did not.],
                   fn -> expect(%{hello: "whoopsie"}, to: pattern_match(%{hello: "world"})) end

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
