defmodule ExpectAssertions.Expect do
  defstruct [:given]
end

defmodule ExpectAssertions.Matchers do
  def to_equal(expected, other) do
    if expected.given == other do
      expected
    else
      raise ExpectAssertions.AssertionError, 
        message: "Expected '#{inspect(expected.given)}' to equal '#{inspect(other)}'"
    end
  end

  def to_contain(expected, other) do
    if other in expected.given do
      expected
    else
      raise ExpectAssertions.AssertionError, 
        message: "Expected '#{inspect(expected.given)}' to contain '#{inspect(other)}'"
    end
  end

  @doc "Verifies that `expected` is an empty list, map, or tuple"
  def to_be_empty(%{given: given} = expected) do
    case empty?(given) do
      :ok -> expected
      {:error, message} -> raise matcher_error(message)
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

  def to_match_regex(expected, regex) do
    if Regex.match?(regex, expected.given) do
      expected
    else
      raise ExpectAssertions.AssertionError,
        message: "Expected '#{inspect(expected.given)}' to match regex '#{inspect(regex)}'"
    end
  end

  # # # 

  defp matcher_error(message) do
    raise ExpectAssertions.AssertionError, message: message
  end
end

defmodule ExpectAssertions.AssertionError do
  defexception [:message]
end

defmodule ExpectAssertions do
  alias ExpectAssertions.Expect

  def expect(value) do
    %Expect{given: value}
  end
end
