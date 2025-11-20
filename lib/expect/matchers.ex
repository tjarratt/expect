defmodule Expect.Matchers do
  # @related [tests](test/expect/matchers_test.exs)
  # @related [tests with warnings](test_with_warnings/expect/matchers/warnings_test.exs)

  alias Expect.Matchers.CustomMatcher

  @moduledoc """
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
          fn: (given :: any() -> bool() | {:error, any()})
        }

  @doc """
  Verifies that `expected` is equal to `value`, using `==`.

  If you want to verify strict equality with `===` then use `strict: true`

  `expect(1, to: equal(1.0, strict: true))`
  """
  @spec equal(any(), Keyword.t()) :: t()
  def equal(value, opts \\ [])

  def equal(value, :strict) do
    %CustomMatcher{name: "strictly equal", expected: value, fn: fn given -> given === value end}
  end

  def equal(value, _opts) do
    %CustomMatcher{name: "equal", expected: value, fn: fn given -> given == value end}
  end

  @doc """
  Verifies that the provided `value` is in the list `expected`

  If you want to verify that the list ONLY contains the one value then use `:only`

  `expect([1], to: contain(only: 1))`
  """
  @spec contain(any()) :: t()
  @spec contain(only: any()) :: t()
  def contain(only: one_value) do
    %CustomMatcher{
      name: "only contain",
      expected: one_value,
      fn: fn given -> given == [one_value] end
    }
  end

  def contain(value) do
    %CustomMatcher{name: "contain", expected: value, fn: fn given -> value in given end}
  end

  @doc "Verifies that `expected` is an empty list, map, or tuple"
  @spec be_empty() :: t()
  def be_empty() do
    %CustomMatcher{name: "be empty", fn: &empty?/1}
  end

  defp empty?([]), do: true
  defp empty?([_ | _rest] = _list), do: false

  defp empty?({}), do: true
  defp empty?(tuple) when is_tuple(tuple), do: false

  defp empty?(map) when is_map(map) and map_size(map) == 0, do: true
  defp empty?(map) when is_map(map), do: false

  defp empty?(_otherwise) do
    {:error, "be empty, but it's not a list, map, or tuple."}
  end

  @doc "Matches `expected` against the provided regular expression using `Regex.match?`"
  @spec match_regex(Regex.t()) :: t()
  def match_regex(regex) do
    %CustomMatcher{
      name: "match regex",
      expected: regex,
      fn: fn given -> Regex.match?(regex, given) end
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
      end
    }
  end

  @doc "Verifies that `expected` is nil"
  @spec be_nil() :: t()
  def be_nil() do
    %CustomMatcher{
      name: "be nil",
      fn: fn
        nil -> true
        _otherwise -> false
      end
    }
  end

  @doc "Verifies that `expected` is either a List or String with the given length"
  @spec have_length(non_neg_integer()) :: t()
  def have_length(expected_length) do
    %CustomMatcher{
      name: "have length",
      expected: expected_length,
      fn: &verify_length(&1, expected_length)
    }
  end

  defp verify_length(list, expected_length)
       when is_list(list) do
    actual_length = length(list)

    if actual_length == expected_length do
      true
    else
      {:error, "have length #{expected_length}, but it is actually #{actual_length}"}
    end
  end

  defp verify_length(binary, expected_length)
       when is_binary(binary) do
    actual_length = String.length(binary)

    actual_length == expected_length
  end

  defp verify_length(_bad_input, expected_length) do
    {:error, "have length #{expected_length}, but it is neither a list nor a string"}
  end

  @doc """
    Verifies that the given value matches against the given pattern.

    ```
    expect({:ok, _msg}, to: pattern_match({:ok, "this is fine"}))

    expect({:ok, _msg}, to: pattern_match({:error, "this is NOT fine !!!"}))
    # raises an error

    # you can also pass in variables for the pattern
    result = {:error, "oh gods everything is on fire"}
    expect({:error, _reason}, to: pattern_match(result))

    # nb : you do not want to pass in variables for the given value
    # this test will never fail, as it effectively re-assigns the variable `whoops`
    whoops = :ok
    expect(whoops, to: pattern_match(:error))
    ```
  """
  defmacro pattern_match(expected) do
    {:pattern_match, expected}
  end
end

defmodule Expect.AssertionError do
  @moduledoc false
  defexception [:message]
end
