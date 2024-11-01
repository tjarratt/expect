defmodule Expect.WrappedValue do
  @moduledoc false
  defstruct [:given]

  @type t :: %__MODULE__{
    given: any()
  }
end
