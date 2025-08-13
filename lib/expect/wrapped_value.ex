defmodule Expect.WrappedValue do
  defstruct [:given]

  @type t :: %__MODULE__{given: any()}
end
