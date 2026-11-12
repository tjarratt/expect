defmodule Expect.Matchers.Temporal do
  # @related [tests](test/expect/matchers/temporal_test.exs)
  alias Expect.Matchers
  alias Expect.Matchers.CustomMatcher
  alias Expect.Matchers.ErrorResult
  alias Expect.Matchers.Result

  @moduledoc """
    Provides matchers that work with `Date`, `DateTime`, and `NaiveDateTime`.
  """

  # # # Date and DateTime matchers

  @doc """
  Verifies that `expected` occurs on the same calendar day (day, month, year) as the provided date.

  Accepts either `Date` or `DateTime` values.

  ```
  iex> expect(~D[2000-12-30], to: be_same_day(~D[2000-12-30]))
  :ok

  iex> expect(~D[2000-12-30], to_not: be_same_day(~D[2000-01-01]))
  :ok
  ```
  """
  @spec be_same_day(Date.t() | DateTime.t() | NaiveDateTime.t()) :: Matchers.t()
  def be_same_day(%Date{} = date), do: do_be_same_day(date)
  def be_same_day(%DateTime{} = datetime), do: do_be_same_day(datetime)
  def be_same_day(%NaiveDateTime{} = datetime), do: do_be_same_day(datetime)

  defp do_be_same_day(date_to_match) do
    %CustomMatcher{
      name: "be the same day as #{inspect(date_to_match)}",
      fn: fn
        %Date{} = date -> are_same_day(date_to_match, date)
        %NaiveDateTime{} = datetime -> are_same_day(date_to_match, datetime)
        %DateTime{} = datetime -> are_same_day(date_to_match, datetime)
        _otherwise -> %ErrorResult{error: "the given term was neither a Date nor a DateTime"}
      end
    }
  end

  defp are_same_day(given_date, date) do
    is_same =
      given_date.year == date.year &&
        given_date.month == date.month &&
        given_date.day == date.day

    %Result{succeeded?: is_same}
  end

  @doc """
  Verifies that the given `DateTime` or `NaiveDateTime` occurs at the expected time.

  ```
  iex> expect(~U[2000-12-31 23:55:59Z], to: occur_at(hour: 23))
  :ok
  ```

  You can specify any of `:hour`, `:minute`, and or `:second` level precision in the opts

  ```
  iex> expect(~U[2000-12-31 23:55:59Z], to: occur_at(hour: 23))
  :ok

  iex> expect(~U[2000-12-31 23:55:59Z], to: occur_at(minute: 55))
  :ok

  iex> expect(~U[2000-12-31 23:55:59Z], to: occur_at(second: 59))
  :ok
  ```
  """
  @spec occur_at(Keyword.t()) :: Matchers.t()
  def occur_at(opts) when is_list(opts) do
    %CustomMatcher{
      name: "occur at #{inspect(opts)}",
      fn: fn
        %DateTime{} = given -> do_occur_at(given, opts)
        %NaiveDateTime{} = given -> do_occur_at(given, opts)
        _otherwise -> %ErrorResult{error: "it was neither a DateTime nor a NaiveDateTime"}
      end
    }
  end

  defp do_occur_at(datetime, opts) do
    hour = Keyword.get(opts, :hour, :skip_it)
    minute = Keyword.get(opts, :minute, :skip_it)
    second = Keyword.get(opts, :second, :skip_it)

    matched =
      verify_occurs_at(datetime.hour, hour) and
        verify_occurs_at(datetime.minute, minute) and
        verify_occurs_at(datetime.second, second)

    %Result{succeeded?: matched}
  end

  defp verify_occurs_at(_component, :skip_it), do: true
  defp verify_occurs_at(component, expected_value), do: component == expected_value

  @impossible_datetime_comparison "it was neither a Date, DateTime, nor NaiveDateTime"
  @midnight ~T[00:00:00]

  @doc """
  Verifies that the given `Date`, `DateTime` or `NaiveDateTime` occurs strictly after the expected Date or DateTime.

  Works the way you would expect when comparing Dates against DateTimes, which is that a Date is considered to
  be equivalent to midnight at the start of the day. Thus any DateTime at least one millisecond after midnight would
  occur after its equivalent Date.

  Do not compare `DateTime` against `NaiveDateTime`. See notes below.

  ```
  iex> expect(~U[2000-12-31 23:55:59Z], to: occur_after(~D[1999-01-01]))
  :ok

  iex> expect(~N[2000-12-31 23:55:59], to: occur_after(~D[1999-01-01]))
  :ok

  iex> expect(~D[2000-12-31], to: occur_after(~D[1999-01-01]))
  :ok

  iex> expect(~U[2000-12-31 23:55:59Z], to: occur_after(~U[1999-01-01 00:00:00Z]))
  :ok

  iex> expect(~D[2000-12-31], to: occur_after(~U[1999-01-01 00:00:00Z]))
  :ok

  iex> expect(~N[2000-12-31 23:55:59Z], to: occur_after(~N[1999-01-01 00:00:00]))
  :ok

  iex> expect(~D[2000-12-31], to: occur_after(~N[1999-01-01 00:00:00]))
  :ok
  ```

  ## Do not compare DateTime against NaiveDateTime

  For the same reasons of correctness that the elixir standard library doesn't allow you to compare `DateTime` against `NaiveDateTime`, expect's temporal matchers refuse to make such comparisons.

  It's always safe to compare DateTime (with or without timezone) against Dates, but comparing DateTime with timezone against one is not well defined, and can lead to subtle bugs.

  ```
  iex> expect(~U[2000-12-31 23:55:59Z], to: occur_after(~N[1999-01-01 00:00:00]))
  ** (Expect.AssertionError) Expected ~U[2000-12-31 23:55:59Z] to occur after ~N[1999-01-01 00:00:00], but it is dangerous to compare DateTime against NaiveDateTime...
  ```
  """
  @spec occur_after(Date.t() | DateTime.t() | NaiveDateTime.t()) :: Matchers.t()
  def occur_after(%NaiveDateTime{} = expected_datetime) do
    %CustomMatcher{
      name: "occur after #{inspect(expected_datetime)}",
      fn: &compare_datetime(&1, expected_datetime, :gt)
    }
  end

  def occur_after(%DateTime{} = expected_datetime) do
    %CustomMatcher{
      name: "occur after #{inspect(expected_datetime)}",
      fn: &compare_datetime(&1, expected_datetime, :gt)
    }
  end

  def occur_after(%Date{} = expected_date) do
    %CustomMatcher{
      name: "occur after #{inspect(expected_date)}",
      fn: fn
        %NaiveDateTime{} = given ->
          compare_datetime(given, NaiveDateTime.new!(expected_date, @midnight), :gt)

        %DateTime{} = given ->
          compare_datetime(given, DateTime.new!(expected_date, @midnight), :gt)

        %Date{} = given ->
          compare_date(given, expected_date, :gt)

        _otherwise ->
          %ErrorResult{error: @impossible_datetime_comparison}
      end
    }
  end

  defp compare_date(given, expected_date, want) do
    %Result{succeeded?: want == Date.compare(given, expected_date)}
  end

  defp compare_datetime(%NaiveDateTime{} = given, %NaiveDateTime{} = expected, want) do
    %Result{succeeded?: want == NaiveDateTime.compare(given, expected)}
  end

  defp compare_datetime(%Date{} = given, %NaiveDateTime{} = expected, want) do
    given_datetime = NaiveDateTime.new!(given, @midnight)

    %Result{succeeded?: want == NaiveDateTime.compare(given_datetime, expected)}
  end

  @dangerous_datetime_compare """
  it is dangerous to compare DateTime against NaiveDateTime.

  To fix this, always compare datetimes of a given type against the same type.
  """

  defp compare_datetime(%DateTime{}, %NaiveDateTime{}, _want) do
    %ErrorResult{error: @dangerous_datetime_compare}
  end

  defp compare_datetime(%NaiveDateTime{}, %DateTime{}, _want) do
    %ErrorResult{error: @dangerous_datetime_compare}
  end

  defp compare_datetime(_otherwise, %NaiveDateTime{} = _expected, _want),
    do: %ErrorResult{error: @impossible_datetime_comparison}

  defp compare_datetime(%DateTime{} = given, %DateTime{} = expected, want) do
    %Result{succeeded?: want == DateTime.compare(given, expected)}
  end

  defp compare_datetime(%Date{} = given, %DateTime{} = expected, want) do
    given_datetime = DateTime.new!(given, @midnight, expected.time_zone)

    %Result{succeeded?: want == DateTime.compare(given_datetime, expected)}
  end

  defp compare_datetime(_otherwise, %DateTime{} = _expected, _want),
    do: %ErrorResult{error: @impossible_datetime_comparison}

  @doc """
  Verifies that the given `Date`, `DateTime` or `NaiveDateTime` occurs strictly before the expected Date or DateTime.

  Works the way you would expect when comparing Dates against DateTimes, which is that a Date is considered to
  be equivalent to midnight at the start of the day. Thus any DateTime at least one millisecond after midnight would
  occur after its equivalent Date.

  Do not compare `DateTime` against `NaiveDateTime`. See notes below.

  ```
  iex> expect(~U[2000-12-31 23:59:59Z], to: occur_before(~D[2001-01-01]))
  :ok

  iex> expect(~N[2000-12-31 23:59:59], to: occur_before(~D[2001-01-01]))
  :ok

  iex> expect(~D[1998-12-31], to: occur_before(~D[1999-01-01]))
  :ok

  iex> expect(~U[2000-12-31 23:55:59Z], to: occur_before(~U[2001-01-01 00:00:00Z]))
  :ok

  iex> expect(~D[2000-12-31], to: occur_before(~U[2001-01-01 00:00:00Z]))
  :ok

  iex> expect(~N[2000-12-31 23:55:59Z], to: occur_before(~N[2001-01-01 00:00:00]))
  :ok

  iex> expect(~D[2000-12-31], to: occur_before(~N[2001-01-01 00:00:00]))
  :ok
  ```

  ## Do not compare DateTime against NaiveDateTime

  For the same reasons of correctness that the elixir standard library doesn't allow you to compare `DateTime` against `NaiveDateTime`, expect's temporal matchers refuse to make such comparisons.

  It's always safe to compare DateTime (with or without timezone) against Dates, but comparing DateTime with timezone against one is not well defined, and can lead to subtle bugs.

  ```
  iex> expect(~U[2000-12-31 23:55:59Z], to: occur_before(~N[2001-01-01 00:00:00]))
  ** (Expect.AssertionError) Expected ~U[2000-12-31 23:55:59Z] to occur before ~N[2001-01-01 00:00:00], but it is dangerous to compare DateTime against NaiveDateTime...
  ```
  """
  @spec occur_before(Date.t() | DateTime.t() | NaiveDateTime.t()) :: Matchers.t()
  def occur_before(%NaiveDateTime{} = expected_datetime) do
    %CustomMatcher{
      name: "occur before #{inspect(expected_datetime)}",
      fn: &compare_datetime(&1, expected_datetime, :lt)
    }
  end

  def occur_before(%DateTime{} = expected_datetime) do
    %CustomMatcher{
      name: "occur before #{inspect(expected_datetime)}",
      fn: &compare_datetime(&1, expected_datetime, :lt)
    }
  end

  def occur_before(%Date{} = expected_date) do
    %CustomMatcher{
      name: "occur before #{inspect(expected_date)}",
      fn: fn
        %NaiveDateTime{} = given -> compare_date(given, expected_date, :lt)
        %DateTime{} = given -> compare_date(given, expected_date, :lt)
        %Date{} = given -> compare_date(given, expected_date, :lt)
        _otherwise -> %ErrorResult{error: @impossible_datetime_comparison}
      end
    }
  end
end
