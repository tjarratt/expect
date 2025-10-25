defmodule Expect.Matchers.NoValue do
  @moduledoc false
  defstruct([])

  # # # Sentinel value to distinguish between two cases that are distinct but look similar
  # scenario 1 : actual is `nil` because the value passed to `expect` is literally `nil`
  # scenario 2 : the matcher does not receive an input that should be shown in the error message
end

defmodule Expect.Matchers.CustomMatcher do
  @moduledoc false
  alias Expect.Matchers.NoValue

  @enforce_keys [:name, :fn]
  defstruct name: nil, actual: %NoValue{}, fn: nil
end
