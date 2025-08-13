defmodule Expect.Matchers do
  # @related [tests](test/expect/matchers_test.exs)

  @moduledoc """
    A matcher is responsible for providing expect() three things

    1. the name for the matcher
    2. the value that was matched against (optional)
    3. a function to invoke with the given value to `expect()`

    Expect will invoke the function, and if it fails to match as expected, it will
    construct an error message using the name and the value.

    For example, given a matcher that returns `{"be cool", nil, fn given -> given =~ "cool" end}`,
    we could expect the following result

    ```
    expect("literal fire", to: be_cool())
    # raises an error with message "Expected 'literal fire' to be cool, but it was not"
    ```

    Alternatively, a matcher that returns `{"be greater than", 5, fn given -> given > 5 end}`
    would have the following result

    ```
    expect(0, to: be_greater_than(5))
    # raises an error with message "Expected '0' to be greater than '5'"
    ```
  """
  @type t :: {String.t(), any(), (any() -> bool())}

  @doc """
  Verifies that `expected` is equal to `value`, using `==`.

  If you want to verify strict equality with `===` then use `strict: true`

  `expect(1, to: equal(1.0, strict: true))`
  """
  @spec be_equal_to(any(), Keyword.t()) :: t()
  def be_equal_to(value, opts \\ [])

  def be_equal_to(value, :strict) do
    {"strictly equal", value, fn given -> given === value end}
  end

  def be_equal_to(value, _opts) do
    {"equal", value, fn given -> given == value end}
  end

  @doc """
  Verifies that the provided `value` is in the list `expected`

  If you want to verify that the list ONLY contains the one value then use `:only`

  `expect([1], to: contain(only: 1))`
  """
  @spec contain(any()) :: t()
  @spec contain(only: any()) :: t()
  def contain(only: one_value) do
    {"only contain", one_value, fn given -> given == [one_value] end}
  end

  def contain(value) do
    {"contain", value, fn given -> value in given end}
  end

  @doc "Verifies that `expected` is an empty list, map, or tuple"
  def to_be_empty(%{given: given} = expected) do
    case empty?(given) do
      :ok -> expected
      {:error, message} -> raise_error(message)
    end
  end

  defp empty?([]), do: :ok
  defp empty?([_ | _rest] = list), do: {:error, "Expected list '#{inspect(list)}' to be empty"}

  defp empty?({}), do: :ok

  defp empty?(tuple) when is_tuple(tuple) do
    {:error, "Expected tuple '#{inspect(tuple)}' to be empty"}
  end

  defp empty?(map) when is_map(map) and map_size(map) == 0, do: :ok

  defp empty?(map) when is_map(map) do
    {:error, "Expected map '#{inspect(map)}' to be empty"}
  end

  defp empty?(otherwise) do
    {:error, "Expected '#{inspect(otherwise)}' to be empty, but it's not a list, map, or tuple."}
  end

  @doc "Matches `expected` against the provided regular expression using `Regex.match?`"
  def to_match_regex(expected, regex) do
    if Regex.match?(regex, expected.given) do
      expected
    else
      raise_error("Expected '#{inspect(expected.given)}' to match regex '#{inspect(regex)}'")
    end
  end

  @doc "Verifies that `expected` is a falsy value -- either `nil` or `false`"
  def to_be_truthy(%Expect.WrappedValue{given: falsy}) when is_nil(falsy) or falsy === false do
    raise_error("Expected '#{inspect(falsy)}' to be truthy")
  end

  def to_be_truthy(otherwise), do: otherwise

  @doc "Verifies that `expected` is nil"
  @spec to_be_nil(Expect.WrappedValue.t()) :: Expect.WrappedValue.t()
  def to_be_nil(%Expect.WrappedValue{given: nil} = expected), do: expected

  def to_be_nil(otherwise) do
    raise_error("Expected '#{inspect(otherwise.given)}' to be nil")
  end

  @doc "Verifies that `expected` is either a List or String with the given length"
  @spec to_have_length(Expect.WrappedValue.t(), non_neg_integer()) :: Expect.WrappedValue.t()
  def to_have_length(expected = %Expect.WrappedValue{given: list}, expected_length)
      when is_list(list) do
    actual_length = length(list)

    if actual_length == expected_length do
      expected
    else
      raise_error(
        "Expected '#{inspect(expected.given)}' to have length #{expected_length}, but it is actually #{actual_length}"
      )
    end
  end

  def to_have_length(expected = %Expect.WrappedValue{given: list}, expected_length)
      when is_binary(list) do
    actual_length = String.length(list)

    if actual_length == expected_length do
      expected
    else
      raise_error(
        "Expected '#{inspect(expected.given)}' to have length #{expected_length}, but it is actually #{actual_length}"
      )
    end
  end

  def to_have_length(expected, expected_length) do
    raise_error(
      "Expected '#{inspect(expected.given)}' to have length #{expected_length}, but it is neither a list nor a string"
    )
  end

  # # #

  defp raise_error(message) do
    raise Expect.AssertionError, message: message
  end
end

defmodule Expect.AssertionError do
  @moduledoc false
  defexception [:message]
end
