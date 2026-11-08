# Expect

[![Build Status](https://github.com/tjarratt/expect/workflows/CI/badge.svg)](https://github.com/tjarratt/expect/actions)
[![Latest tag](https://img.shields.io/github/tag/tjarratt/expect.svg)](https://pushin.eu/tjarratt/expect)
[![MIT License](https://img.shields.io/hexpm/l/expect.svg)](https://hex.pm/packages/expect)
[![Hex.pm Version](https://img.shields.io/hexpm/v/expect.svg)](https://hex.pm/packages/expect)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/expect/)

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

## Avoiding tests that pass erroneously

Sometimes we accidentally write tests that don't test anything meaningful. Consider
the following test:

```elixir
test "widget names follow the 'Manufacturer - Year - Name' convention" do
    widgets = Tools.widgets()

    for widget <- widgets do
       assert Regex.scan(~r/([A-Za-z]+) - ([0-9]+) - ([A-Za-z]+)/, widget.name) 
    end
end
```

This test is bad because `Regex.scan/2` either returns an array of matches, or an empty list `[]`.
This variant of the test also would pass.

```elixir
test "widget names follow the 'Manufacturer - Year - Name' convention" do
    for widget <- widgets do
       assert Regex.scan(~r/([A-Za-z]+) - ([0-9]+) - ([A-Za-z]+)/, "this should not pass, but does") 
    end
end
```

The problem is that `assert` on its only will only verify that the value is neither `false` nor `nil`.
A matcher from `Expect` encapsulates the behaviour it cares about, and verifies it directly.
We could thus rewrite our test using the `match_regex` matcher:

```elixir
test "widget names follow the 'Manufacturer - Year - Name' convention" do
    widgets = Tools.widgets()

    for widget <- widgets do
       expect(widget.name, to: match_regex(~r/([A-Za-z]+) - ([0-9]+) - ([A-Za-z]+)/))
    end
end
```

Matchers increase legibility of tests and make it harder to introduce these types of errors.

## Installation

Add `expect` to your list of dependencies in `mix.exs` :

```elixir
def deps do
  [
    {:expect, "~> 2.0"}
  ]
end
```

Run `mix deps.get` then use it in your tests :

```elixir
defmodule MyApp.PoetryTest do
    use ExUnit.Case, async: true
    use Expect

    test "it gyres and gimbles when it's brillig" do
        poem = Poetry.generate("'Twas brillig")

        expect(poem.author, to: equal("Lewis Carrol"))
        expect(poem.year, to: be_less_than(2026))
        expect(poem.body, to: match_regex(~r"gyre and gimble"))
    end
end
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
* be an error
* match pattern (eg: `assert %{key: value} = %{key: "value"}`)
* datetime `Date`, `Datetime` matchers
    * be_same_day (works with date, datetime)
    * occur_at(hour: minute: second:)

## Roadmap

Here's a non-exhaustive list of features that are in our roadmap

* Temporal matchers (eg: a `Date` should occur before or after another)
    * occur_after
    * occur_before
    * occur_on_or_after
    * occur_on_or_before
* string matching 
    * have_prefix
    * have suffix
    * contain_substring
* satisfy all, satisfy any for combining matchers
* match yaml, json, or xml
* be element of some data structure
* be struct of a given type
* have key present in map
* `beCloseTo` matcher
    * defaults to 0.1
    * precision can be added

Many of these features can be found in other libraries, such as [gomega](https://onsi.github.io/gomega/#provided-matchers)

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

## Docs

<https://hexdocs.pm/expect>

