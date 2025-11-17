defmodule Expect.Matchers.NoValue do
  @moduledoc false
  defstruct([])

  # # # Sentinel value to distinguish between two cases that are distinct but look similar
  # scenario 1 : expected is `nil` because the value passed to `expect` is literally `nil`
  # scenario 2 : the matcher does not receive an input that should be shown in the error message
end

defmodule Expect.Matchers.CustomMatcher do
  @moduledoc """
  You are highly encouraged to implement your own custom matchers. For the application you
  will build, there will surely be some interesting properties and shapes of data that
  will be important to verify. It might be easy to use the `equal()` matcher for 99%
  of assertions, but writing a higher-level matcher can be much more intent revealing.

  Imagine we are building an application that provides users with the highest quality
  bananas that money can buy. As part of our unit testing, it's crucial that we can
  verify that the output of our system is indeed a banana. It would be valuable to
  implement a `be_bananas()` matcher, as depending on the market the user is in
  the type of banana we supply them will vary (maybe they prefer it more or less ripe). 

  A simple version of our custom bananas matcher could look like this

  ```elixir
  defmodule MyFancyMatchers do
    alias Expect.Matchers.CustomMatcher

    def be_bananas() do
       %CustomMatcher{
            name: "be bananas",
            fn: fn given ->
                case given do
                    "bananas" -> true
                    "BANANAS" -> true
                    "🍌" ->      true

                    _ -> false
                end
            end
       }
    end
  end

  import Expect
  import MyFancyMatchers

  expect("🍌", to: be_bananas())
  ```
  """

  alias Expect.Matchers.NoValue

  @enforce_keys [:name, :fn]
  defstruct name: nil, expected: %NoValue{}, fn: nil
end
