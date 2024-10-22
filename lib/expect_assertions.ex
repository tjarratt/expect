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

  def to_match_regex(expected, regex) do
    if Regex.match?(regex, expected.given) do
      expected
    else
      raise ExpectAssertions.AssertionError,
        message: "Expected '#{inspect(expected.given)}' to match regex '#{inspect(regex)}'"
    end
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
