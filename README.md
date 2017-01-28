# lita-regexcellent

Counts the number of Slack messages that matches a regular expression in the current channel. Only compatible with the Slack adapter.

## Installation

1. Add gem to your Lita instance: `gem "lita-regexcellent"`
2. Set SLACK_TOKEN if not already set: `heroku config:set SLACK_TOKEN=$token`

## Usage

To use, issue the command (where `lita` is your robots name):

```
lita count /regex/ since:1_week_ago until:now
=> 12 results found.
```

`since` and `until` are both optional. They default to the listed values.

## Running tests

1. Make sure Redis is running locally
2. `rspec spec`
