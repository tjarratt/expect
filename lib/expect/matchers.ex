defmodule Expect.Matchers do
  # @related [tests](test/expect/matchers_test.exs)

  @doc "Verifies that `expected` is equal to `value`"
  def to_equal(expected, value, opts \\ [])

  def to_equal(expected, value, :strict) do
    if expected.given === value do
      expected
    else
      raise_error("Expected '#{inspect(expected.given)}' to strictly equal '#{inspect(value)}'")
    end
  end

  def to_equal(expected, value, _opts) do
    if expected.given == value do
      expected
    else
      raise_error("Expected '#{inspect(expected.given)}' to equal '#{inspect(value)}'")
    end
  end

  @doc "Verifies that the provided `value` is in the list `expected`"
  def to_contain(expected, value)

  def to_contain(expected, only: one_value) do
    if expected.given == [one_value] do
      expected
    else
      raise_error("Expected '#{inspect(expected.given)}' to only contain '#{inspect(one_value)}'")
    end
  end

  def to_contain(expected, value) do
    if value in expected.given do
      expected
    else
      raise_error("Expected '#{inspect(expected.given)}' to contain '#{inspect(value)}'")
    end
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

  # # # 

  defp raise_error(message) do
    raise Expect.AssertionError, message: message
  end
end

defmodule Expect.AssertionError do
  @moduledoc false
  defexception [:message]
end
