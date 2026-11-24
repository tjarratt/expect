defmodule Expect.Matchers.Composition do
  # @related [tests](test/expect/matchers/composition_test.exs)

  alias Expect.Matchers
  alias Expect.Matchers.CustomMatcher
  alias Expect.Matchers.ErrorResult
  alias Expect.Matchers.Result

  @moduledoc """
    Provides matchers that compose matchers. See docs for `satisfy_all` for more details.
  """

  @doc """
  Verifies that `given` matches all provided `matchers`.

  ```
  iex> expect(2, to: satisfy_all([be_greater_than(0), be_greater_than(1)]))
  :ok

  iex> expect(1, to_not: satisfy_all([be_greater_than(0), be_greater_than(1)]))
  :ok
  ```
  """
  @spec satisfy_all(list(Matchers.t())) :: Matchers.t()
  def satisfy_all(matchers) do
    matcher_descriptions = matchers |> Enum.map_join(", ", & &1.name)

    %CustomMatcher{
      name: "satisfy all (#{matcher_descriptions})",
      fn: fn given ->
        grouped =
          matchers
          |> Enum.map(& &1.fn.(given))
          |> Enum.group_by(fn
            %Result{succeeded?: true} -> "true"
            %Result{succeeded?: false} -> "false"
            %ErrorResult{} -> "error"
          end)

        failed = Map.get(grouped, "false", [])
        errored = Map.get(grouped, "error", [])

        cond do
          errored != [] ->
            error_message = errored |> Enum.map_join(" and ", & &1.error)
            %ErrorResult{error: error_message}

          failed != [] ->
            %Result{succeeded?: false}

          true ->
            %Result{succeeded?: true}
        end
      end
    }
  end
end
