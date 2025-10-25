defmodule ExpectTest do
  # @related [subject](lib/expect.ex)
  use ExUnit.Case, async: true

  alias Expect.AssertionError
  alias Expect.ProgrammerError

  import Expect

  describe "using the expect/2 function" do
    test "works if you pass it built-in types" do
      assert expect(nil, to: equal(nil))
      assert expect(true, to: equal(true))
      assert expect(1, to: equal(1))
      assert expect(1.0, to: equal(1.0))
      assert expect("yup", to: equal("yup"))
      assert expect([1, 2, 3], to: equal([1, 2, 3]))
      assert expect(<<123>>, to: equal(<<123>>))
      assert expect(%{key: "value"}, to: equal(%{key: "value"}))
      assert expect({1, 2, 3}, to: equal({1, 2, 3}))
      assert expect(~c'charstring', to: equal(~c'charstring'))
    end

    test "can test for positive conditions" do
      expect(true, to: equal(true))

      assert_raise AssertionError, "Expected 'false' to equal 'true'", fn ->
        expect(false, to: equal(true))
      end
    end

    test "can test for negative conditions" do
      expect(true, to_not: equal(false))

      assert_raise AssertionError, "Expected 'false' to not equal 'false'", fn ->
        expect(false, to_not: equal(false))
      end
    end
  end

  describe "calling expect/2 with bad arguments" do
    test "with too many args; raises a meaningful error so you know not to do that again" do
      error =
        assert_raise ProgrammerError, fn ->
          expect(false, to: equal("whoops"), to_not: equal("oh no i accidentally all the args"))
        end

      assert error.message =~
               "expect/2 should only be called with one arg, but you provided 2 :: [:to, :to_not]"
    end

    test "with too few args; raises an error so you know your test has no side effect" do
      error =
        assert_raise ProgrammerError, fn ->
          expect("whoops")
        end

      assert error.message =~ "expect/2 should only be called with one arg, but you provided none"
    end

    test "with unknown args; raises an error so you know you done goofed" do
      error =
        assert_raise ProgrammerError, fn ->
          expect("whoops", holy_carp: "sixte-tuberously")
        end

      assert error.message =~
               "expect/2 should only be called with :to or :to_not, but you provided :holy_carp"
    end
  end

  # # #

  defp equal(expected_value) do
    %Expect.Matchers.CustomMatcher{
      name: "equal",
      actual: expected_value,
      fn: fn given -> given == expected_value end
    }
  end
end
