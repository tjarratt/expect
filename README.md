# Expect

`Expect` allows you to write simple, clear assertions in your unit tests.

While initially this may appear to be a simple case of style, over time
you will find that these assertions read better, simplify your tests, 
and allow you to write tests that more clearly reveal their intent.

Instead of writing the following...

`assert name == "Douglas Adams"`

you can write...

`expect(name) |> to_equal("Douglas Adams")`

See the documentation on `Expect.Matchers` for more examples of matchers to use.

## Installation

Add `expect` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:expect, "~> 0.1.0"}
  ]
end
```

## Custom Matchers

Feel free to implement your own custom matchers. They have a fairly simple interface.
At a bare minimum they should receive a single positional argument that will be a struct
with a `given` field. This is the value that is wrapped by the `expect` function.

Imagine we wanted to implement a `is_bananas()` matcher. It could look like this

```elixir
defmodule MyFancyMatchers do
    def is_bananas(%{given: given}) do
        cond given do
            "bananas" -> given
            "BANANAS" -> given
            "🍌" -> given
            _ -> raise AssertionError, message: "Expected '#{inspect(given)}' to be bananas, but it clearly was not."
        end
    end
end
```

## Docs

<https://hexdocs.pm/expect>.

