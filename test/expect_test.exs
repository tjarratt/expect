defmodule ExpectTest do
  # @related [subject](lib/expect.ex)
  use ExUnit.Case, async: true

  alias Expect.AssertionError

  import Expect

  describe "using the expect/1 function" do
    test "works if you pass it built-in types" do
      assert expect(nil)
      assert expect(true)
      assert expect(1)
      assert expect(1.0)
      assert expect("yup")
      assert expect([1, 2, 3])
      assert expect(<<123>>)
      assert expect(%{key: "value"})
      assert expect({1, 2, 3})
      assert expect(~c'charstring')
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

  # # #

  defp equal(expected_value) do
    {"equal", expected_value, fn given -> given == expected_value end}
  end
end
