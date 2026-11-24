defmodule Expect.Matchers.CompositionTest do
  # @related [subject](lib/expect/matchers/composition.ex)
  use ExUnit.Case, async: true
  use Expect

  doctest Expect.Matchers.Composition

  alias Expect.AssertionError

  describe "combining matchers" do
    test "satisfy_all/1 matches when all matchers succeed" do
      expect(1,
        to:
          satisfy_all([
            be_greater_than(0),
            be_less_than(2)
          ])
      )
    end

    test "satisfy_all/1 fails when any matcher fails" do
      expect(1,
        to_not:
          satisfy_all([
            be_greater_than(1),
            be_less_than(2)
          ])
      )

      expect(1,
        to_not:
          satisfy_all([
            be_greater_than(0),
            be_less_than(1)
          ])
      )
    end

    test "satisfy_all/1 works with matchers that return ErrorResult" do
      assert_raise AssertionError,
                   ~r"it is neither a list nor a string and it's not a list, map, or tuple.",
                   fn ->
                     expect(1, to: satisfy_all([equal(1), have_length(42), be_empty()]))
                   end
    end
  end
end
