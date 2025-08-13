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
    case args do
      [] ->
        quote do
          %Expect.WrappedValue{given: unquote(given)}
        end

      [to_match: actual] ->
        given_as_string = Macro.to_string(given)
        actual_as_string = Macro.to_string(actual)

        quote do
          try do
            unquote(given) = unquote(actual)
          rescue
            MatchError ->
              raise Expect.AssertionError,
                message:
                  "Expected '#{unquote(given_as_string)}' to match pattern '#{unquote(actual_as_string)}', but it did not."
          end
        end

      [to: matcher_args] ->
        given_as_string = Macro.to_string(given)

        quote do
          {condition, actual, matcher} = unquote(matcher_args)

          case matcher.(unquote(given)) do
            true ->
              :ok

            false ->
              raise_error(unquote(given_as_string), "to", condition, actual)

            {:error, reason} ->
              raise Expect.AssertionError,
                message: "Expected '#{unquote(given_as_string)}' to #{reason}"
          end
        end

      [to_not: matcher_args] ->
        given_as_string = Macro.to_string(given)

        quote do
          {condition, actual, matcher} = unquote(matcher_args)

          case matcher.(unquote(given)) do
            false ->
              :ok

            true ->
              raise_error(unquote(given_as_string), "to not", condition, actual)

            {:error, reason} ->
              raise Expect.AssertionError,
                message: "Expected '#{unquote(given_as_string)}' to not #{reason}"
          end
        end
    end
  end

  def raise_error(given, proposition, matcher_property, nil) do
    raise Expect.AssertionError,
      message: "Expected '#{given}' #{proposition} #{matcher_property}"
  end

  def raise_error(given, proposition, matcher_property, actual) do
    raise Expect.AssertionError,
      message: "Expected '#{given}' #{proposition} #{matcher_property} '#{inspect(actual)}'"
  end
end
