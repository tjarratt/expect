defmodule Expect.Matchers.Result do
  @moduledoc """
  Custom matchers should return this in their happy path.
  Use the `succeeded?` field to indicate whether the match was successful or not.
  """
  defstruct succeeded?: false
end

defmodule Expect.Matchers.ErrorResult do
  @moduledoc "Custom matchers should return this when they receive data they cannot handle"
  defstruct error: nil
end

defmodule Expect.AssertionError do
  @moduledoc false
  defexception [:message]
end

defmodule Expect.Matchers do
  # @related [tests](test/expect/matchers_test.exs)
  # @related [temporal](lib/expect/matchers/temporal.ex)

  alias Expect.Matchers.CustomMatcher
  alias Expect.Matchers.ErrorResult
  alias Expect.Matchers.Result

  @moduledoc """
  Matchers are re-usable functions that make complex assertions simple and readable.

  A matcher is responsible for providing `expect/2` three things

  1. the name for the matcher
  2. the value that was matched against (optional)
  3. a function to invoke with the given value to `expect()`

  Expect will invoke the matcher's function, and if it returns `false` or an error tuple, it will
  construct an error message using the name and the value, and fail the test.

  For example, given a matcher that returns `%CustomMatcher{name: "end with", expected: "cool", fn: fn given -> String.ends_with?(given, "cool") end}`,
  we could expect the following result

  ```
  expect("literal fire", to: end_with("cool"))
  # raises an error with message "Expected '"literal fire"' to end with '"cool"', but it did not"
  ```

  Alternatively, a matcher that returns `%CustomMatcher{name: "be greater than", expected: 5, fn: fn given -> given > 5 end}`
  would have the following result

  ```
  expect(0, to: be_greater_than(5))
  # raises an error with message "Expected '0' to be greater than '5'"
  ```

  ## Custom Failure Messages

  By default, when a matcher fails, the error message will use the name of the matcher, and the value matched against.

  eg: given a matcher returns `%CustomMatcher{name: "start with", expected: "gravy", fn: fn given -> String.starts_with?(given, "gravy") end}`
  we could expect the following line to fail

  ```
  expect("groovy train", to: start_with("gravy"))
  # fails with message "Expected '\"groovy train\"' to start with '\"gravy\"'"
  ```

  If you are writing a matcher that doesn't compare the given value against something else, you can omit the `actual` key
  (only the `name` and `fn` keys are required)

  ```
  def start_with_a, do: %CustomMatcher{name: "start with the letter 'A'", fn: fn given -> String.starts_with?(given, "A") end}`

  expect("algebra", to: start_with_a())
  # passes

  expect("monotonic", to: start_with_a())
  # fails with message "Expected '"monotonic"' to start with the letter 'a'"
  ```

  ## Custom error messages

  Sometimes, a matcher might receive input that it is incapable of dealing with. A matcher that wants to
  verify if a string has a certain prefix would be unable to handle input that is not a string. This can be
  handled by returning an error tuple from a matcher

  ```
  def end_with(suffix) do: %CustomMatcher{name: "end with", expected: suffix, fn: &verify_suffix(&1, suffix)}

  defp verify_suffix(given, suffix) when is_binary(given), do: String.ends_with?(given, suffix)
  defp verify_suffix(given, suffix), do: {:error, "end with '#\{suffix}', but it was not a string"}
  ```
  """
  @type t :: %CustomMatcher{
          name: matcher_name :: String.t(),
          expected: matched_against :: any(),
          fn: (given :: any() -> %Result{} | %ErrorResult{})
        }

  @doc """
  Verifies that `expected` is equal to `value`, using `==`.

  If you want to verify strict equality with `===` then use `strict: true`

  ```
  iex> expect(1, to: equal(1.0, strict: true))
  :ok
  ```
  """
  @spec equal(any(), Keyword.t()) :: t()
  def equal(value, opts \\ [])

  def equal(value, :strict) do
    %CustomMatcher{
      name: "strictly equal #{inspect(value)}",
      fn: fn given -> success_result(given === value) end
    }
  end

  def equal(value, _opts) do
    %CustomMatcher{
      name: "equal #{inspect(value)}",
      fn: fn given -> success_result(given == value) end
    }
  end

  @doc """
  Verifies that `expected` is strictly greater than `value`, using `>`.

  ```
  iex> expect(1, to: be_greater_than(0))
  :ok

  iex> expect(1, to_not: be_greater_than(2))
  :ok

  iex> expect("whoops", to: be_greater_than(1))
  ** (Expect.AssertionError) Expected "whoops" to be greater than 1, but matcher expects only integers or floats
  ```
  """
  def be_greater_than(value) do
    %CustomMatcher{
      name: "be greater than #{inspect(value)}",
      fn: &verify_greater_than(&1, value)
    }
  end

  defp verify_greater_than(lhs, rhs)
       when (is_integer(lhs) or is_float(lhs)) and (is_integer(rhs) or is_float(rhs)) do
    success_result(lhs > rhs)
  end

  defp verify_greater_than(_lhs, _rhs),
    do: error_result("matcher expects only integers or floats")

  @doc """
  Verifies that `expected` is strictly less than `value`, using `<`.
  """
  def be_less_than(value) do
    %CustomMatcher{
      name: "be less than #{inspect(value)}",
      fn: &verify_less_than(&1, value)
    }
  end

  defp verify_less_than(lhs, rhs)
       when (is_integer(lhs) or is_float(lhs)) and (is_integer(rhs) or is_float(rhs)) do
    success_result(lhs < rhs)
  end

  defp verify_less_than(_lhs, _rhs),
    do: error_result("matcher expects only integers or floats")

  @doc """
  Verifies that the provided `value` is in the given Enum

  Works with any Enumerable type (eg: Lists, Keyword lists, Ranges, Maps, etc).

  ```
  iex> expect([1,2,3], to: contain(1))
  :ok
  ```

  You can optionally provide the keyword `:only` which verifies that the value
  passed is the one and only value inside the given Enum.

  ```
  # passes
  iex> expect([1], to: contain(only: 1))
  :ok

  # fails
  iex> expect([1, 2, 3], to: contain(only: 1))
  ** (Expect.AssertionError) Expected [1, 2, 3] to only contain 1
  ```

  You can also verify that a given enum only contains a list of values,
  either in order, or regardless of order.

  ```
  # passes
  iex> expect(["hello world"], to: contain(only: "hello world"))
  :ok

  # fails
  iex> expect([1, 2, 3], to: contain(only: [2, 1]))
  ** (Expect.AssertionError) Expected [1, 2, 3] to only contain [2, 1]
  ```
  """

  @spec contain(any()) :: t()
  @spec contain(only: any()) :: t()
  def contain(only: one_value) do
    %CustomMatcher{
      name: "only contain #{inspect(one_value)}",
      fn: fn given when is_list(given) ->
        success_result(length(given) == 1 and one_value in given)
      end
    }
  end

  def contain(value) do
    %CustomMatcher{
      name: "contain #{inspect(value)}",
      fn: fn given -> success_result(value in given) end
    }
  end

  @doc """
  Verifies that the provided list of `values` are in the Enum, regardless of order.

  Unlike contain/1 this allows for verifying more than one element at a time.

  ```
  iex> expect([1, 2, 3], to: contain_in_any_order([3, 2, 1]))
  :ok

  iex> expect([1, 2, 3], to: contain_in_any_order(["whoopsie"]))
  ** (Expect.AssertionError) Expected [1, 2, 3] to contain ["whoopsie"] (regardless of order)
  ```
  """
  @spec contain_in_any_order(values :: list()) :: t()
  def contain_in_any_order(values) do
    %CustomMatcher{
      name: "contain #{inspect(values)} (regardless of order)",
      fn: fn given -> do_contain_in_any_order(given, values) end
    }
  end

  defp do_contain_in_any_order(given, values) when is_list(given) and is_list(values) do
    given
    |> MapSet.new()
    |> MapSet.union(MapSet.new(values))
    |> MapSet.equal?(MapSet.new(given))
    |> success_result()
  end

  defp do_contain_in_any_order(given, _values) when not is_list(given) do
    error_result("#{inspect(given)} is not a list")
  end

  @spec be_in_range(Range.t()) :: t()
  def be_in_range(range) do
    %CustomMatcher{
      name: "be in range #{inspect(range)}",
      fn: fn given -> verify_in_range(range, given) end
    }
  end

  defp verify_in_range(range, given) when is_integer(given) do
    success_result(given in range)
  end

  defp verify_in_range(_range, given),
    do: error_result("#{inspect(given)} is not an integer")

  @doc "Verifies that `expected` is an empty list, map, or tuple"
  @spec be_empty() :: t()
  def be_empty() do
    %CustomMatcher{name: "be empty", fn: &empty?/1}
  end

  defp empty?([]), do: success_result(true)
  defp empty?([_ | _rest] = _list), do: success_result(false)

  defp empty?({}), do: success_result(true)
  defp empty?(tuple) when is_tuple(tuple), do: success_result(false)

  defp empty?(map) when is_map(map) and map_size(map) == 0, do: success_result(true)
  defp empty?(map) when is_map(map), do: success_result(false)

  defp empty?(_otherwise), do: error_result("it's not a list, map, or tuple.")

  @doc """
  Matches `expected` against the provided regular expression using `Regex.match?`

  ```
  iex> expect("good tests are worth their weight in gold", to: match_regex(~r[^good.+gold$]))
  :ok
  ```
  """
  @spec match_regex(Regex.t()) :: t()
  def match_regex(regex) do
    %CustomMatcher{
      name: "match regex #{inspect(regex)}",
      fn: fn given -> Regex.match?(regex, given) |> success_result() end
    }
  end

  @doc "Verifies that `expected` is a falsy value -- either `nil` or `false`"
  @spec be_truthy() :: t()
  def be_truthy() do
    %CustomMatcher{
      name: "be truthy",
      fn: fn given ->
        case given do
          nil -> false
          false -> false
          _ -> true
        end
        |> success_result()
      end
    }
  end

  @doc "Verifies that `expected` is nil"
  @spec be_nil() :: t()
  def be_nil() do
    %CustomMatcher{
      name: "be nil",
      fn: fn
        nil -> success_result(true)
        _otherwise -> success_result(false)
      end
    }
  end

  @doc "Verifies that `expected` is either a List or String with the given length"
  @spec have_length(non_neg_integer()) :: t()
  def have_length(expected_length) do
    %CustomMatcher{
      name: "have length #{expected_length}",
      fn: &verify_length(&1, expected_length)
    }
  end

  defp verify_length(list, expected_length)
       when is_list(list) and is_integer(expected_length) do
    actual_length = length(list)

    success_result(actual_length == expected_length)
  end

  defp verify_length(binary, expected_length)
       when is_binary(binary) and is_integer(expected_length) do
    actual_length = String.length(binary)

    (actual_length == expected_length) |> success_result()
  end

  defp verify_length(_given, expected_length) when not is_integer(expected_length) do
    error_result("the input to have_length/1 is not an integer")
  end

  defp verify_length(_bad_input, _expected_length) do
    error_result("it is neither a list nor a string")
  end

  @doc """
  Verifies that `expected` is either the atom `:error` or an error tuple

  ```
  iex> expect(:error, to: be_an_error())
  :ok

  iex> expect({:error, "whoopsie doodle"}, to: be_an_error())
  :ok

  iex> expect(:ok, to: be_an_error())
  ** (Expect.AssertionError) Expected :ok to be an error tuple

  ## Options

  You can optionally pass `:reason` as an option, which will verify the error tuple includes that reason.

  iex> expect({:error, "critical failure"}, to: be_an_error(reason: "critical failure"))
  :ok

  iex> expect(:ok, to: be_an_error(reason: "spawn more overlords"))
  ** (Expect.AssertionError) Expected :ok to be an error tuple with reason "spawn more overlords"
  ```
  """
  @spec be_an_error() :: t()
  def be_an_error() do
    %CustomMatcher{
      name: "be an error tuple",
      fn: fn
        :error ->
          success_result(true)

        {:error, _anything} ->
          success_result(true)

        tuple when is_tuple(tuple) and tuple_size(tuple) > 2 and elem(tuple, 0) == :error ->
          error_result("it was neither :error or {:error, something}")

        _otherwise ->
          success_result(false)
      end
    }
  end

  @spec be_an_error(reason: term()) :: t()
  def be_an_error(reason: expected_reason) do
    %CustomMatcher{
      name: "be an error tuple with reason #{inspect(expected_reason)}",
      fn: fn
        :error ->
          error_result("it was not a tuple")

        {:error, given_reason} ->
          success_result(given_reason == expected_reason)

        tuple when is_tuple(tuple) and tuple_size(tuple) > 2 and elem(tuple, 0) == :error ->
          error_result("it was not {:error, #{inspect(expected_reason)}}")

        _otherwise ->
          success_result(false)
      end
    }
  end

  # # # Pattern matching

  @doc """
  Verifies that the given value matches against the provided pattern.

  ```
  iex> expect({:ok, _msg}, to: pattern_match({:ok, "this is fine"}))
  {:ok, "this is fine"}

  # raises an error
  iex> expect({:ok, _msg}, to: pattern_match({:error, "this is NOT fine !!!"}))
  ** (Expect.AssertionError) Expected {:ok, _msg} to match pattern {:error, "this is NOT fine !!!"}, but it did not.

  # you can also pass in variables for the pattern
  iex> result = {:error, "oh gods everything is on fire"}
  iex> expect({:error, _reason}, to: pattern_match(result))
  {:error, "oh gods everything is on fire"}

  # nb : you do not want to pass in variables for the given value
  # this test will never fail, as it effectively re-assigns the variable `whoops`
  whoops = :ok
  expect(whoops, to: pattern_match(:error))
  ```

  ## Binding variables

  You can bind variables during a pattern match and use that for later assertions.
  This is frequently helpful when you have some large data structure and assert several
  distinct facts about it

  ```
  my_data = %{large: %{structure: %{containing: %{a_list: ["cool"]}}}}

  expect(%{large: %{structure: %{containing: %{a_list: list}}}}, to: pattern_match(my_data))
  expect(list, to: contain("cool"))
  ```
  """
  defmacro pattern_match(expected) do
    {:pattern_match, expected}
  end

  # # # Private

  defp success_result(successful?) when is_boolean(successful?) do
    %Result{succeeded?: successful?}
  end

  defp error_result(reason) when is_binary(reason) do
    %ErrorResult{error: reason}
  end
end
