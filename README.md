# Expect

`Expect` allows you to write simple, clear assertions in your unit tests.

While initially this may appear to be a simple case of style, over time
you will find that these assertions read better, simplify your tests, 
and allow you to write tests that more clearly reveal their intent.

Instead of writing the following...

`assert name == "Douglas Adams"`

you can write...

`expect(name, to: be_equal_to("Douglas Adams"))`

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

You are highly encouraged to implement your own custom matchers. For the application you
will build, there will surely be some interesting properties and shapes of data that
will be important to verify. It might be easy to use the `be_equal_to` matcher for 99%
of assertions, but writing a higher-level matcher can be much more intent revealing.

Imagine we wanted to implement a `be_bananas()` matcher. It could look like this

```elixir
defmodule MyFancyMatchers do
    def be_bananas() do
       {
            "be bananas",
            Expect.Matchers.without_any_value(),
            fn given ->
                case given do
                    "bananas" -> true
                    "BANANAS" -> true
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

For more details see the documentation for `Expect.Matchers`.

## Docs

<https://hexdocs.pm/expect>.

