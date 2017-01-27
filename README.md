# lita-regexcellent

Only compatible with Slack adapter. We use `slack-ruby-client` to get channel message history.


## Installation

Add lita-regexcellent to your Lita instance's Gemfile:

``` ruby
gem "lita-regexcellent"
```

## Configuration


## Usage

To use, issue the command (where `lita` is your robots name):

```
lita count /regex/ from:1_year_from_now to:today
=> 12 results found.
```

`from` and `to` are both optional.
