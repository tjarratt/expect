defmodule Expect do
  # @related [test](test/expect_test.exs)

  alias Expect.ProgrammerError
  alias Expect.Matchers.CustomMatcher
  alias Expect.Matchers.ErrorResult
  alias Expect.Matchers.Result

  @moduledoc """
    `Expect` allows you to write simple, clear assertions in your unit tests.

    While initially this may appear to be a simple case of style, over time
    you will find that these assertions read better, simplify your tests,
    and allow you to write tests that more clearly reveal their intent.

    Instead of writing the following...

    `assert name == "Douglas Adams"`

    you can write...

    `expect(name, to: equal("Douglas Adams"))`

    See the documentation on `Expect.Matchers` for more examples of matchers to use.
  """

  @doc """
    Take a given value and prepare it to be matched against one or more matchers.

    Example:

    ```
    expect(42, to: equal(42))

    # raises an error
    expect(42, to: equal("the answer to life, the universe, and everything"))
    ```
  """

  defmacro __using__(_options) do
    quote do
      import Expect
      import Expect.Matchers
    end
  end

  defmacro expect(given, args \\ [])

  defmacro expect(_given, args) when length(args) > 1 do
    quote do
      raise ProgrammerError,
        message: """
        expect/2 should only be called with one arg, but you provided #{length(unquote(args))} :: #{inspect(Keyword.keys(unquote(args)))}

        To fix this : call expect with either to: or to_not

        eg: expect(some_list, to: have(length(3))
        or: expect("success", to_not: regex(~r[whoopsie]))
        """
    end
  end

  defmacro expect(_given, args) when args == [] do
    quote do
      raise ProgrammerError,
        message: """
          expect/2 should only be called with one arg, but you provided none.

           To fix this : call expect with either to: or to_not

          eg: expect(some_list, to: have(length(3))
          or: expect("success", to_not: regex(~r[whoopsie]))
        """
    end
  end

  @known_propositions [:to, :to_not]

  defmacro expect(_given, [{key, _value}]) when key not in @known_propositions do
    quote do
      raise ProgrammerError,
        message: """
        expect/2 should only be called with :to or :to_not, but you provided :#{unquote(key)}
        """
    end
  end

  # pattern match is tricky to implement
  # ideally this would be implemented as its own matcher
  # but it's important that both the given and actual are unquoted
  # here at the same time, otherwise we lose information
  defmacro expect(given, to: {:pattern_match, _where, [actual]}) do
    given_as_string = Macro.to_string(given)
    actual_as_string = Macro.to_string(actual)

    quote do
      try do
        unquote(given) = unquote(actual)
      rescue
        MatchError ->
          # credo:disable-for-next-line Credo.Check.Warning.RaiseInsideRescue
          raise Expect.AssertionError,
            message:
              "Expected '#{unquote(given_as_string)}' to match pattern '#{unquote(actual_as_string)}', but it did not."
      end

      # perform the pattern match ONE MORE TIME
      # this allows for the variables bound given to be used later in the test
      unquote(given) = unquote(actual)
    end
  end

  defmacro expect(given, to_not: {:pattern_match, _where, [actual]}) do
    given_as_string = Macro.to_string(given)
    actual_as_string = Macro.to_string(actual)

    quote do
      try do
        unquote(given) = unquote(actual)

        raise Expect.AssertionError,
          message:
            "Expected '#{unquote(given_as_string)}' to not match pattern '#{unquote(actual_as_string)}', but it did."
      rescue
        MatchError ->
          :ok
      end
    end
  end

  defmacro expect(given, to: matcher_args) do
    given_as_string = Macro.to_string(given)

    quote do
      %CustomMatcher{name: matcher_name, expected: expected, fn: matcher} = unquote(matcher_args)

      result = matcher.(unquote(given))

      case result do
        %ErrorResult{error: error_message} ->
          raise Expect.AssertionError,
            # TODO: we can pull the matcher name into this message !!!
            message: "Expected '#{unquote(given_as_string)}' to #{error_message}"

        %Result{succeeded?: true} ->
          :ok

        %Result{succeeded?: false} ->
          raise_error(unquote(given_as_string), "to", matcher_name, expected)
      end
    end
  end

  defmacro expect(given, to_not: matcher_args) do
    given_as_string = Macro.to_string(given)

    quote do
      %CustomMatcher{name: matcher_name, expected: expecte, fn: matcher} = unquote(matcher_args)

      result = matcher.(unquote(given))

      case result do
        %ErrorResult{error: error_message} ->
          raise Expect.AssertionError,
            # TODO: we can pull the matcher name into this message !!!
            message: "Expected '#{unquote(given_as_string)}' to not #{error_message}"

        %Result{succeeded?: false} ->
          :ok

        %Result{succeeded?: true} ->
          raise_error(unquote(given_as_string), "to not", matcher_name, expecte)
      end
    end
  end

  @doc false
  def raise_error(given, proposition, matcher_property, %Expect.Matchers.NoValue{}) do
    raise Expect.AssertionError,
      message: "Expected '#{given}' #{proposition} #{matcher_property}"
  end

  @doc false
  def raise_error(given, proposition, matcher_property, expected) do
    raise Expect.AssertionError,
      message: "Expected '#{given}' #{proposition} #{matcher_property} '#{inspect(expected)}'"
  end
end

defmodule Expect.ProgrammerError do
  @moduledoc false
  defexception [:message]
end
