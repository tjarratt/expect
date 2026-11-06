defmodule Expect.MatchersTest do
  # @related [subject](lib/expect/matchers.ex)
  use ExUnit.Case, async: true
  use Expect

  doctest Expect.Matchers

  alias Expect.AssertionError

  test "equal matcher" do
    expect(true, to: equal(true))
    expect(1234, to: equal(1234))
    expect("ok", to: equal("ok"))
    expect(:ok, to: equal(:ok))
    expect(1, to: equal(1.0))
    expect(1, to_not: equal(0))

    assert_raise AssertionError, "Expected true to equal false", fn ->
      expect(true, to: equal(false))
    end

    assert_raise AssertionError, "Expected 1 to not equal 1", fn ->
      expect(1, to_not: equal(1))
    end

    assert_raise AssertionError, "Expected 1 to strictly equal 1.0", fn ->
      expect(1, to: equal(1.0, :strict))
    end

    assert_raise AssertionError, "Expected [1, 2, 3] to equal [4, 5, 6]", fn ->
      expect([1, 2, 3], to: equal([4, 5, 6]))
    end

    assert_raise AssertionError, "Expected :ok to equal nil", fn ->
      expect(:ok, to: equal(nil))
    end
  end

  test "be greater than matcher" do
    expect(2, to: be_greater_than(1))
    expect(2.0, to: be_greater_than(1.0))

    expect(2, to: be_greater_than(1.0))
    expect(2.0, to: be_greater_than(1))

    expect(1, to_not: be_greater_than(2))

    assert_raise AssertionError, "Expected 1 to be greater than 2", fn ->
      expect(1, to: be_greater_than(2))
    end

    assert_raise AssertionError,
                 "Expected nil to be greater than 2, but matcher expects only integers or floats",
                 fn ->
                   expect(nil, to: be_greater_than(2))
                 end

    assert_raise AssertionError,
                 "Expected 1 to be greater than nil, but matcher expects only integers or floats",
                 fn ->
                   expect(1, to: be_greater_than(nil))
                 end

    assert_raise AssertionError,
                 ~s[Expected "abc" to be greater than "def", but matcher expects only integers or floats],
                 fn ->
                   expect("abc", to: be_greater_than("def"))
                 end
  end

  test "be less than matcher" do
    expect(1, to: be_less_than(2))
    expect(1.0, to: be_less_than(2.0))

    expect(1, to: be_less_than(2.0))
    expect(1.0, to: be_less_than(2))

    expect(1, to_not: be_less_than(0))

    assert_raise AssertionError, "Expected 2 to be less than 1", fn ->
      expect(2, to: be_less_than(1))
    end

    assert_raise AssertionError,
                 "Expected nil to be less than 2, but matcher expects only integers or floats",
                 fn ->
                   expect(nil, to: be_less_than(2))
                 end

    assert_raise AssertionError,
                 "Expected 1 to be less than nil, but matcher expects only integers or floats",
                 fn ->
                   expect(1, to: be_less_than(nil))
                 end

    assert_raise AssertionError,
                 ~s[Expected "abc" to be less than "def", but matcher expects only integers or floats],
                 fn ->
                   expect("abc", to: be_less_than("def"))
                 end
  end

  test "be in range matcher" do
    expect(1, to: be_in_range(1..10))
    expect(0, to_not: be_in_range(1..10))

    assert_raise AssertionError, ~s[Expected 0 to be in range 1..2], fn ->
      expect(0, to: be_in_range(1..2))
    end

    assert_raise AssertionError, ~s[Expected 1 to not be in range 1..2], fn ->
      expect(1, to_not: be_in_range(1..2))
    end

    assert_raise AssertionError,
                 ~s[Expected "wat" to be in range 1..2, but "wat" is not an integer],
                 fn -> expect("wat", to: be_in_range(1..2)) end
  end

  describe "to_contain matcher" do
    test "verifies that the value is in the enum" do
      expect([1, 2, 3], to: contain(1))
      expect(1..10, to: contain(1))
      expect([player: 1], to: contain({:player, 1}))
      expect(%{name: "bob"}, to: contain({:name, "bob"}))

      expect(1..10, to_not: contain(0))

      assert_raise AssertionError, "Expected [1, 2, 3] to contain \"bananas\"", fn ->
        expect([1, 2, 3], to: contain("bananas"))
      end

      assert_raise AssertionError, "Expected [1, 2, 3] to not contain 1", fn ->
        expect([1, 2, 3], to_not: contain(1))
      end
    end

    test "works with any enumerable, eg: list, range, keyword list, map" do
      expect([1, 2, 3], to: contain(1))
      expect(1..3, to: contain(1))
      expect([keyword: 1], to: contain({:keyword, 1}))
      expect(%{key: "value"}, to: contain({:key, "value"}))

      assert_raise AssertionError, "Expected [1, 2, 3] to contain 4", fn ->
        expect([1, 2, 3], to: contain(4))
      end

      assert_raise AssertionError, "Expected 1..3 to contain 4", fn ->
        expect(1..3, to: contain(4))
      end

      assert_raise AssertionError, "Expected [keyword: :lists] to contain 4", fn ->
        expect([keyword: :lists], to: contain(4))
      end

      assert_raise AssertionError, "Expected %{key: :value} to contain 4", fn ->
        expect(%{key: :value}, to: contain(4))
      end
    end

    test "can verify that the value is the only one present" do
      expect([1], to: contain(only: 1))
      expect([], to_not: contain(:anything))
      expect([1], to_not: contain(2))

      assert_raise AssertionError, "Expected [1] to only contain 2", fn ->
        expect([1], to: contain(only: 2))
      end

      assert_raise AssertionError, "Expected [1, 2, 3] to only contain 1", fn ->
        expect([1, 2, 3], to: contain(only: 1))
      end
    end
  end

  describe "contain_in_any_order matcher" do
    test "verifies that the list only contains the provided values, regardless of order" do
      expect([1, 2, 3], to: contain_in_any_order([3, 2, 1]))
      expect([1, 2, 3], to: contain_in_any_order([1]))
      expect([1, 2, 3, 4], to: contain_in_any_order([3, 2, 1]))

      expect([1, 2, 3], to_not: contain_in_any_order([4, 3, 2, 1]))

      assert_raise AssertionError,
                   "Expected [1, 2, 3] to contain [4, 5, 6] (regardless of order)",
                   fn ->
                     expect([1, 2, 3], to: contain_in_any_order([4, 5, 6]))
                   end
    end

    test "returns a nice error when not called with a list" do
      assert_raise AssertionError,
                   "Expected :whoopsie to contain [1, 2, 3] (regardless of order), but :whoopsie is not a list",
                   fn ->
                     expect(:whoopsie, to: contain_in_any_order([1, 2, 3]))
                   end
    end
  end

  test "match_regex matcher" do
    expect("hello", to: match_regex(~r[^h]))
    expect("hello", to_not: match_regex(~r[bye]))

    assert_raise AssertionError, "Expected \"hello world\" to match regex ~r/NOPE/", fn ->
      expect("hello world", to: match_regex(~r[NOPE]))
    end
  end

  test "be_empty matcher" do
    expect([], to: be_empty())
    expect(%{}, to: be_empty())
    expect({}, to: be_empty())

    expect([1], to_not: be_empty())
    expect(%{key: "value"}, to_not: be_empty())
    expect({1}, to_not: be_empty())

    assert_raise AssertionError, "Expected [1] to be empty", fn ->
      expect([1], to: be_empty())
    end

    assert_raise AssertionError, "Expected {1} to be empty", fn ->
      expect({1}, to: be_empty())
    end

    assert_raise AssertionError, "Expected %{key: \"value\"} to be empty", fn ->
      expect(%{key: "value"}, to: be_empty())
    end

    assert_raise AssertionError,
                 ~s[Expected "WHOOPS" to be empty, but it's not a list, map, or tuple.],
                 fn -> expect("WHOOPS", to: be_empty()) end

    assert_raise AssertionError,
                 ~s[Expected "WHOOPS" to not be empty, but it's not a list, map, or tuple.],
                 fn -> expect("WHOOPS", to_not: be_empty()) end
  end

  test "to_be_truthy matcher" do
    expect(true, to: be_truthy())
    expect(false, to_not: be_truthy())
    expect("anything besides literal nil or false", to: be_truthy())

    assert_raise AssertionError, "Expected nil to be truthy", fn ->
      expect(nil, to: be_truthy())
    end

    assert_raise AssertionError, "Expected false to be truthy", fn ->
      expect(false, to: be_truthy())
    end
  end

  test "to_be_nil matcher" do
    expect(nil, to: be_nil())
    expect(123, to_not: be_nil())

    assert_raise AssertionError, ~s[Expected "not nil" to be nil], fn ->
      expect("not nil", to: be_nil())
    end
  end

  test "have_length matcher" do
    expect([], to: have_length(0))
    expect([], to_not: have_length(1))
    expect([:madness], to: have_length(1))
    expect([hello: :world], to: have_length(1))

    expect("hello", to: have_length(5))

    assert_raise AssertionError, ~s<Expected [] to have length 99>, fn ->
      expect([], to: have_length(99))
    end

    assert_raise AssertionError,
                 ~s<Expected [] to have length abc, but the input to have_length/1 is not an integer>,
                 fn ->
                   expect([], to: have_length("abc"))
                 end

    assert_raise AssertionError,
                 ~s[Expected nil to have length 99, but it is neither a list nor a string],
                 fn ->
                   expect(nil, to: have_length(99))
                 end
  end

  describe "pattern_match matcher" do
    test "can pattern match maps, lists, tuples, and structs" do
      expect(%{hello: _whom}, to: pattern_match(%{hello: "world"}))
      expect([_, _, _], to: pattern_match([1, 2, 3]))
      expect({_a, _b}, to: pattern_match({:a, :b}))
      expect(%{year: 1999}, to: pattern_match(%Date{year: 1999, month: 12, day: 31}))

      expect(%{hello: _whom}, to_not: pattern_match(%{goodbye: "sweet world"}))
      expect([_not_enough], to_not: pattern_match([1, 2, 3]))
      expect({_not_enough}, to_not: pattern_match({:a, :b}))
      expect(%{whoops: _my_bad}, to_not: pattern_match(%Date{year: 1999, month: 12, day: 31}))
    end

    test "makes variables bound in the pattern match available for later assertions" do
      expect(%{hello: whom}, to: pattern_match(%{hello: "world"}))

      expect(whom, to: equal("world"))
    end

    test "shows an informative error when the pattern match fails" do
      assert_raise AssertionError,
                   ~s[Expected %{hello: "whoopsie"} to match pattern %{hello: "world"}, but it did not.],
                   fn -> expect(%{hello: "whoopsie"}, to: pattern_match(%{hello: "world"})) end

      assert_raise AssertionError,
                   ~s[Expected %{hello: "world"} to not match pattern %{hello: "world"}, but it did.],
                   fn -> expect(%{hello: "world"}, to_not: pattern_match(%{hello: "world"})) end

      assert_raise AssertionError,
                   ~s[Expected %{goodbye: _cruel_world} to match pattern %{hello: "world"}, but it did not.],
                   fn ->
                     expect(%{goodbye: _cruel_world}, to: pattern_match(%{hello: "world"}))
                   end

      assert_raise AssertionError,
                   ~s[Expected %{goodbye: _cruel_world} to match pattern %{hello: "world"}, but it did not.],
                   fn ->
                     expect(%{goodbye: _cruel_world}, to: pattern_match(%{hello: "world"}))
                   end
    end
  end

  describe "avoiding warnings with pattern_match/1" do
    # due to how pattern_match/1 is implemented, it has historically consistently raised warnings
    # when run with the new set-theoretic compiler in elixir 1.19+. Since I dislike
    # seeing warnings in my test suits , it was deeply bothering to me to see these warnings
    #
    # sidebar : notice how expect has a regular suite and a separate one for tests that raise warnings
    #           some of these warnings may be useful to users, but only in rare scenarios
    #
    # under the hood `expect` will perform two matches (one to see if it passes or fails)
    # and then a second one. The first one is surrounded by a try/rescue which is necessary
    # to recover from any raised errors.
    # The second pattern match then serves to capture bindings for later assertions
    # For the first pattern match we mangle the AST and underscore any bound variables
    #
    # anyway, this test serves to verify we haven't done anything terribly dumb when we're
    # mangling variable names inside of maps
    test "when called with a map" do
      a_given_map = %{hello: "everyone", goodbye: "noone"}
      expect(%{hello: whom, goodbye: "noone"}, to: pattern_match(a_given_map))
      expect(whom, to: equal("everyone"))

      expect(%{hello: _whom}, to: pattern_match(%{hello: "everyone"}))

      correct = "world"
      expect(%{hello: ^correct}, to: pattern_match(%{hello: "world"}))
    end

    test "when called with a list" do
      expect([], to: pattern_match([]))

      expect([_], to: pattern_match(["abc"]))

      # first bind, then assert on them
      expect([a, b, c], to: pattern_match(["a", "b", "c"]))
      expect([a, b, c], to: equal(["a", "b", "c"]))

      # use pins
      expect([_a, ^b, _c], to: pattern_match(["a", "b", "c"]))

      # list construction
      expect([something | _], to: pattern_match(["abc"]))
      expect(something, to: equal("abc"))

      expect([_something | _], to: pattern_match(["abc"]))
    end

    test "when called with a tuple" do
      expect({a}, to: pattern_match({"heyo"}))
      expect(a, to: equal("heyo"))

      expect({^a, _}, to: pattern_match({"heyo", "boyo"}))
    end
  end

  describe "be_an_error matcher" do
    test "succeeds when the actual is just the atom :error" do
      expect(:error, to: be_an_error())
    end

    test "succeeds when the actual is an error tuple of size 2" do
      expect({:error, "oh noes"}, to: be_an_error())
    end

    test "fails when the actual is not an error tuple" do
      assert_raise AssertionError, ~s[Expected {:ok, "s'all good"} to be an error tuple], fn ->
        expect({:ok, "s'all good"}, to: be_an_error())
      end
    end

    test "fails when the actual is an error tuple of size > 2" do
      assert_raise AssertionError,
                   ~s[Expected {:error, "whoops", nil} to be an error tuple, but it was neither :error or {:error, something}],
                   fn ->
                     expect({:error, "whoops", nil}, to: be_an_error())
                   end
    end
  end

  describe "be_same_day matcher" do
    test "succeeds only when both occur on the same day" do
      expect(~D[2026-12-30], to: be_same_day(~D[2026-12-30]))

      expect(~D[2026-12-30], to_not: be_same_day(~D[2026-12-29]))
      expect(~D[2026-12-30], to_not: be_same_day(~D[2026-11-30]))
      expect(~D[2026-12-30], to_not: be_same_day(~D[2027-12-30]))
    end

    test "works with Dates and DateTimes" do
      expect(~D[2026-12-30], to: be_same_day(~N[2026-12-30 10:00:00]))
      expect(~D[2026-12-30], to: be_same_day(~U[2026-12-30 00:00:00Z]))
    end

    test "fails with a useful message when the given term is not a Date or DateTime" do
      assert_raise AssertionError,
                   ~s<Expected :whoops to be the same day as ~D[2000-01-01], but the given term was neither a Date nor a DateTime>,
                   fn ->
                     expect(:whoops, to: be_same_day(~D[2000-01-01]))
                   end
    end

    test "fails with a useful message when the matcher term is not a Date or DateTime" do
      assert_raise AssertionError,
                   ~s<Expected ~D[2000-01-01] to be the same day as :oh_noes, but the matcher term was neither a Date nor a DateTime>,
                   fn ->
                     expect(~D[2000-01-01], to: be_same_day(:oh_noes))
                   end
    end
  end

  describe "occur_at matcher" do
    test "succeeds when the provided date occurs at the provided time" do
      expect(~N[2026-01-01 16:20:00], to: occur_at(hour: 16))
      expect(~U[2026-01-01 16:20:00Z], to: occur_at(hour: 16))

      expect(~N[2026-01-01 16:20:00], to_not: occur_at(hour: 23))
      expect(~U[2026-01-01 16:20:00Z], to_not: occur_at(hour: 23))
    end

    test "permits hour, minute, and second level precision" do
      expect(~N[2026-01-01 16:20:44], to: occur_at(hour: 16))
      expect(~N[2026-01-01 16:20:44], to_not: occur_at(hour: 17))

      expect(~N[2026-01-01 16:20:44], to: occur_at(minute: 20))
      expect(~N[2026-01-01 16:20:44], to_not: occur_at(minute: 21))

      expect(~N[2026-01-01 16:20:44], to: occur_at(second: 44))
      expect(~N[2026-01-01 16:20:44], to_not: occur_at(second: 45))

      expect(~N[2026-01-01 16:20:44], to: occur_at(hour: 16, minute: 20, second: 44))
      expect(~N[2026-01-01 16:20:44], to_not: occur_at(hour: 16, minute: 19, second: 43))
    end

    test "fails with a useful message when it does not match" do
      assert_raise AssertionError,
                   "Expected ~N[2000-01-30 23:44:55] to occur at [hour: 1, minute: 1, second: 1]",
                   fn ->
                     expect(~N[2000-01-30 23:44:55], to: occur_at(hour: 1, minute: 1, second: 1))
                   end
    end

    test "fails with a useful message when the given term is not a DateTime" do
      assert_raise AssertionError,
                   ~s"Expected :whoops to occur at [hour: 1], but it was neither a DateTime nor a NaiveDateTime",
                   fn ->
                     expect(:whoops, to: occur_at(hour: 1))
                   end
    end
  end
end
