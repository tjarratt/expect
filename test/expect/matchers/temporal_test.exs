defmodule Expect.Matchers.TemporalTest do
  # @related [subject](lib/expect/matchers/temporal.ex)
  use ExUnit.Case, async: true
  use Expect

  doctest Expect.Matchers.Temporal

  alias Expect.AssertionError

  describe "be_same_day matcher" do
    test "succeeds only when both occur on the same day" do
      expect(~D[2026-12-30], to: be_same_day(~D[2026-12-30]))

      expect(~D[2026-12-30], to_not: be_same_day(~D[2026-12-29]))
      expect(~D[2026-12-30], to_not: be_same_day(~D[2026-11-30]))
      expect(~D[2026-12-30], to_not: be_same_day(~D[2027-12-30]))
    end

    test "works with Dates, DateTimes, and NaiveDateTimes" do
      expect(~D[2026-12-31], to: be_same_day(~N[2026-12-31 10:00:00]))
      expect(~D[2026-12-31], to: be_same_day(~U[2026-12-31 13:00:00Z]))

      expect(~N[1999-12-31 10:00:00], to: be_same_day(~D[1999-12-31]))
      expect(~U[1999-12-31 10:00:00Z], to: be_same_day(~D[1999-12-31]))
    end

    test "fails with a useful message when the given term is not a Date or DateTime" do
      assert_raise AssertionError,
                   ~s<Expected :whoops to be the same day as ~D[2000-01-01], but the given term was neither a Date nor a DateTime>,
                   fn ->
                     expect(:whoops, to: be_same_day(~D[2000-01-01]))
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

  describe "occur_after matcher" do
    test "succeeds only when the given date is after the provided one" do
      expect(~D[2000-01-01], to: occur_after(~D[1999-12-31]))

      expect(~D[2000-01-01], to_not: occur_after(~D[2000-01-01]))
      expect(~D[2000-01-01], to_not: occur_after(~D[2000-01-02]))
    end

    test "works with both dates and datetimes" do
      expect(~U[2000-01-01 10:00:00Z], to: occur_after(~U[2000-01-01 00:00:00Z]))
      expect(~U[2000-01-01 00:00:00Z], to: occur_after(~U[1999-12-31 23:59:59Z]))
      expect(~U[2000-01-01 00:00:00Z], to_not: occur_after(~U[2000-01-01 00:00:00Z]))
      expect(~U[2000-01-01 00:00:00Z], to_not: occur_after(~U[2000-01-02 00:00:00Z]))
      expect(~U[2000-01-01 00:00:00Z], to_not: occur_after(~U[2000-01-01 10:00:00Z]))

      expect(~N[2000-01-01 10:00:00], to: occur_after(~N[2000-01-01 00:00:00]))
      expect(~N[2000-01-01 00:00:00], to: occur_after(~N[1999-12-31 23:59:59]))
      expect(~N[2000-01-01 00:00:00], to_not: occur_after(~N[2000-01-01 10:00:00]))
      expect(~N[2000-01-01 00:00:00], to_not: occur_after(~N[2000-01-01 00:00:00]))
      expect(~N[2000-01-01 00:00:00], to_not: occur_after(~N[2000-01-02 00:00:00]))
    end

    test "can compare dates against datetimes" do
      expect(~D[2000-01-01], to: occur_after(~U[1999-01-01 23:59:59Z]))
      expect(~D[2000-01-01], to: occur_after(~N[1999-01-01 23:59:59]))

      expect(~D[2000-01-01], to_not: occur_after(~U[2000-01-01 00:00:00Z]))
      expect(~D[2000-01-01], to_not: occur_after(~N[2000-01-01 00:00:00]))

      expect(~D[2000-01-01], to_not: occur_after(~U[2000-01-02 00:00:00Z]))
      expect(~D[2000-01-01], to_not: occur_after(~N[2000-01-02 00:00:00]))
    end

    test "can compare datetimes against dates" do
      expect(~U[2000-01-02 00:00:00Z], to: occur_after(~D[2000-01-01]))
      expect(~U[2000-01-01 11:22:33Z], to: occur_after(~D[2000-01-01]))

      expect(~N[2000-01-02 00:00:00], to: occur_after(~D[2000-01-01]))
      expect(~N[2000-01-01 11:22:33], to: occur_after(~D[2000-01-01]))

      expect(~U[1999-01-01 23:59:59Z], to_not: occur_after(~D[2000-01-01]))
      expect(~N[2000-01-01 00:00:00Z], to_not: occur_after(~D[2000-01-01]))

      expect(~N[1999-01-01 23:59:59], to_not: occur_after(~D[2000-01-01]))
      expect(~N[2000-01-01 00:00:00], to_not: occur_after(~D[2000-01-01]))
    end

    test "fails with a useful message when trying to compare DateTime against NaiveDateTime" do
      assert_raise AssertionError,
                   ~s<Expected ~U[2000-01-01 11:22:33Z] to occur after ~N[1999-01-01 00:00:00], but it is dangerous to compare DateTime against NaiveDateTime.

To fix this, always compare datetimes of a given type against the same type.
>,
                   fn ->
                     expect(~U[2000-01-01 11:22:33Z], to: occur_after(~N[1999-01-01 00:00:00]))
                   end

      assert_raise AssertionError,
                   ~s<Expected ~N[2000-01-01 11:22:33] to occur after ~U[1999-01-01 00:00:00Z], but it is dangerous to compare DateTime against NaiveDateTime.

To fix this, always compare datetimes of a given type against the same type.
>,
                   fn ->
                     expect(~N[2000-01-01 11:22:33], to: occur_after(~U[1999-01-01 00:00:00Z]))
                   end
    end

    test "fails with a useful message when the given term is not a date" do
      assert_raise AssertionError,
                   "Expected :whoopsie to occur after ~D[2000-01-01], but it was neither a Date, DateTime, nor NaiveDateTime",
                   fn ->
                     expect(:whoopsie, to: occur_after(~D[2000-01-01]))
                   end

      assert_raise AssertionError,
                   "Expected :whoopsie to occur after ~U[2000-01-01 00:00:00Z], but it was neither a Date, DateTime, nor NaiveDateTime",
                   fn ->
                     expect(:whoopsie, to: occur_after(~U[2000-01-01 00:00:00Z]))
                   end

      assert_raise AssertionError,
                   "Expected :whoopsie to occur after ~N[2000-01-01 00:00:00], but it was neither a Date, DateTime, nor NaiveDateTime",
                   fn ->
                     expect(:whoopsie, to: occur_after(~N[2000-01-01 00:00:00]))
                   end
    end
  end

  describe "occur_before matcher" do
    test "succeeds only when the given date is before the provided one" do
      expect(~D[2000-01-01], to: occur_before(~D[2000-01-02]))

      expect(~D[2000-01-01], to_not: occur_before(~D[2000-01-01]))
      expect(~D[2000-01-01], to_not: occur_before(~D[1999-12-31]))
    end

    test "works with both dates and datetimes" do
      expect(~U[2000-01-01 00:00:00Z], to: occur_before(~U[2000-01-01 10:00:00Z]))
      expect(~U[2000-01-01 00:00:00Z], to: occur_before(~U[2000-01-02 00:00:00Z]))
      expect(~U[2000-01-01 00:00:00Z], to_not: occur_before(~U[2000-01-01 00:00:00Z]))
      expect(~U[2000-01-01 10:00:00Z], to_not: occur_before(~U[2000-01-01 09:00:00Z]))
      expect(~U[2000-01-01 00:00:00Z], to_not: occur_before(~U[1999-12-31 23:59:55Z]))

      expect(~N[2000-01-01 00:00:00], to: occur_before(~N[2000-01-01 10:00:00]))
      expect(~N[2000-01-01 00:00:00], to: occur_before(~N[2000-01-02 00:00:00]))
      expect(~N[2000-01-01 00:00:00], to_not: occur_before(~N[2000-01-01 00:00:00]))
      expect(~N[2000-01-01 10:00:00], to_not: occur_before(~N[2000-01-01 09:00:00]))
      expect(~N[2000-01-01 00:00:00], to_not: occur_before(~N[1999-12-31 23:59:55]))
    end

    test "can compare dates against datetimes" do
      expect(~D[2000-01-01], to: occur_before(~U[2000-01-01 00:00:01Z]))
      expect(~D[2000-01-01], to: occur_before(~N[2000-01-01 00:00:01]))

      expect(~D[2000-01-01], to_not: occur_before(~U[2000-01-01 00:00:00Z]))
      expect(~D[2000-01-01], to_not: occur_before(~N[2000-01-01 00:00:00]))

      expect(~D[2000-01-01], to_not: occur_before(~U[1999-12-31 23:59:59Z]))
      expect(~D[2000-01-01], to_not: occur_before(~N[1999-12-31 23:59:59]))
    end

    test "can compare datetimes against dates" do
      expect(~U[2000-01-01 00:00:00Z], to: occur_before(~D[2000-01-02]))
      expect(~N[2000-01-01 00:00:00], to: occur_before(~D[2000-01-02]))

      expect(~U[2000-01-01 00:00:00Z], to_not: occur_before(~D[2000-01-01]))
      expect(~N[2000-01-01 00:00:00], to_not: occur_before(~D[2000-01-01]))

      expect(~U[2000-01-01 00:00:00Z], to_not: occur_before(~D[1999-12-31]))
      expect(~N[2000-01-01 00:00:00], to_not: occur_before(~D[1999-12-31]))
    end

    test "fails with a useful message when trying to compare DateTime against NaiveDateTime" do
      assert_raise AssertionError,
                   ~s<Expected ~U[2000-01-01 11:22:33Z] to occur before ~N[2000-01-02 00:00:00], but it is dangerous to compare DateTime against NaiveDateTime.

To fix this, always compare datetimes of a given type against the same type.
>,
                   fn ->
                     expect(~U[2000-01-01 11:22:33Z], to: occur_before(~N[2000-01-02 00:00:00]))
                   end

      assert_raise AssertionError,
                   ~s<Expected ~N[2000-01-01 11:22:33] to occur before ~U[2000-01-02 00:00:00Z], but it is dangerous to compare DateTime against NaiveDateTime.

To fix this, always compare datetimes of a given type against the same type.
>,
                   fn ->
                     expect(~N[2000-01-01 11:22:33], to: occur_before(~U[2000-01-02 00:00:00Z]))
                   end
    end

    test "fails with a useful message when the given term is not a date" do
      assert_raise AssertionError,
                   "Expected :whoopsie to occur before ~D[2000-01-01], but it was neither a Date, DateTime, nor NaiveDateTime",
                   fn ->
                     expect(:whoopsie, to: occur_before(~D[2000-01-01]))
                   end

      assert_raise AssertionError,
                   "Expected :whoopsie to occur before ~U[2000-01-01 00:00:00Z], but it was neither a Date, DateTime, nor NaiveDateTime",
                   fn ->
                     expect(:whoopsie, to: occur_before(~U[2000-01-01 00:00:00Z]))
                   end

      assert_raise AssertionError,
                   "Expected :whoopsie to occur before ~N[2000-01-01 00:00:00], but it was neither a Date, DateTime, nor NaiveDateTime",
                   fn ->
                     expect(:whoopsie, to: occur_before(~N[2000-01-01 00:00:00]))
                   end
    end
  end
end
