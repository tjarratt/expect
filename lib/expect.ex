defmodule Expect do
  alias Expect.Expect

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
  def expect(value) do
    %Expect{given: value}
  end
end

defmodule Expect.Expect do
  @moduledoc false
  defstruct [:given]
end
