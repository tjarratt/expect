defmodule Expect do
  # @related [test](test/expect_test.exs)

  @moduledoc """
    `Expect` allows you to write simple, clear assertions in your unit tests.

    While initially this may appear to be a simple case of style, over time
    you will find that these assertions read better, simplify your tests,
    and allow you to write tests that more clearly reveal their intent.

    Instead of writing the following...

    `assert name == "Douglas Adams"`

    you can write...

    `expect(name) |> to_equal("Douglas Adams")`

    See the documentation on `Expect.Matchers` for more examples of matchers to use.
  """

  @doc """
    Take a given value and prepare it to be matched against one or more matchers.

    Example:

    expect(42) |> to_equal(42)

    # raises an error
    expect(42) |> to_equal("the answer to life, the universe, and everything")
  """

  defmacro expect(given, args \\ []) do
    case Keyword.get(args, :to_match) do
      nil ->
        quote do
          %Expect.WrappedValue{given: unquote(given)}
        end

      actual ->
        given_as_string = Macro.to_string(given)
        actual_as_string = Macro.to_string(actual)

        quote do
          try do
            unquote(given) = unquote(actual)
          rescue
            MatchError ->
              raise Expect.AssertionError,
                message:
                  "Expected '#{unquote(given_as_string)}' to match against '#{unquote(actual_as_string)}', but it did not."
          end
        end
    end
  end
end
