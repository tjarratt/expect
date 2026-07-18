# Expect

`Expect` allows you to write simple, clear assertions in your unit tests.

While initially this may appear to be a simple case of style, over time
you will find that these assertions read better, simplify your tests, 
and allow you to write tests that more clearly reveal their intent.

Instead of writing the following...

```elixir
subject = %Author{name: "Douglas Adams", answer: 42}

assert subject.name == "Douglas Adams"
assert subject.answer == 42
```

you can write...

```elixir
use Expect

expect(subject.name, to: equal("Douglas Adams"))
expect(subject.answer, to: be_the_answer_to_life_the_universe_and_everything_else())
```

See the documentation on `Expect.Matchers` for more examples of matchers to use.

## Installation

Add `expect` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:expect, "~> 2.0"}
  ]
end
```

## Custom Matchers

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

use Expect
import MyFancyMatchers

expect("🍌", to: be_bananas())
```

For more details see the documentation for `Expect.Matchers`.

## Available Matchers

Expect ships with quite a few built-in matchers for you to use in tests

* equal (eg: `==`)
* strictly equal (eg: `===`)
* contain element inside a list
* match regular expression
* be empty
* be truthy
* be nil
* have length
* match pattern (eg: `assert %{key: value} = %{key: "value"}`)

## Roadmap

Here's a non-exhaustive list of features that are in our roadmap

* be_equivalent `Date`, `Datetime` matchers
    * be_same_day (works with date, datetime)
* be_temporally (eg: a date should occur before or after another)
    * occur_after
    * occur_before
    * occur_on_or_after
    * occur_on_or_before
* string matching (have prefix, have suffix, contain substring)
* match yaml, json, or xml
* contain elements with/without strict ordering
* be element of some data structure
* be struct of a given type
* have key present in map
* satisfy all, satisfy any, satisfy
* Matchers can return an optional suffix when the match fails
  * eg: "expected [1,2,3] to have length 99, but it was actually 3"
  * "but it was actually 3" is an example of an optional suffix

Many of these features can be found in other libraries, such as [gomega](https://onsi.github.io/gomega/#provided-matchers)

## Docs

<https://hexdocs.pm/expect>.

