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
  @type t :: {matcher_name :: String.t(), matched_against :: any(), (given :: any() -> bool())}

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

  @spec be_empty() :: t()
  @doc "Verifies that `expected` is an empty list, map, or tuple"
  def be_empty() do
    {"be empty", nil, &empty?/1}
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
    {"match regex", regex, fn given -> Regex.match?(regex, given) end}
  end

  @doc "Verifies that `expected` is a falsy value -- either `nil` or `false`"
  @spec be_truthy() :: t()
  def be_truthy() do
    {"be truthy", nil,
     fn given ->
       case given do
         nil -> false
         false -> false
         _ -> true
       end
     end}
  end

  @doc "Verifies that `expected` is nil"
  @spec be_nil() :: t()
  def be_nil() do
    {"be nil", nil,
     fn
       nil -> true
       _otherwise -> false
     end}
  end

  @doc "Verifies that `expected` is either a List or String with the given length"
  @spec have_length(non_neg_integer()) :: t()
  def have_length(expected_length) do
    {"have length", expected_length, &verify_length(&1, expected_length)}
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
end

defmodule Expect.AssertionError do
  @moduledoc false
  defexception [:message]
end
