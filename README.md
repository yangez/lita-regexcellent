# lita-regexcellent

Counts the number of Slack messages that matches a regular expression in the current channel. Only compatible with the Slack adapter.

## Installation

1. Add gem to your Lita instance: `gem "lita-regexcellent"`
2. Set SLACK_TOKEN if not already set: `heroku config:set SLACK_TOKEN=$token`

## Usage

To use, issue the command (where `lita` is your robots name):

```
lita count /regex/ since:1_week_ago until:now
=> Found 12 results for /regex/ since 1 week ago until now.
```

`since` and `until` are both optional and default to the listed values.

The search will also skip over previous queries (`lita count /regex/`) and previous bot responses (`Found 12 results for...`).

## Running tests

1. Make sure Redis is running locally
2. `rspec spec`
