defmodule ExpectTest do
  # @related [subject](lib/expect.ex)
  use ExUnit.Case, async: true

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
  end
end
