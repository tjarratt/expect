defmodule Expect.WrappedValue do
  defstruct [:given]

  @opaque t :: %__MODULE__{given: any()}
end
