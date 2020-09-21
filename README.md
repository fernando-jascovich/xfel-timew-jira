# Xfel::Timew

This is a report and sync tool for TimeWarrior -> Jira ticket's worklog.

## Installation

```bash
gem install xfel-timew-jira

export TMP_EXTENSION_FNAME='~/.timewarrior/extensions/xfel_timew_jira.rb'
echo '#!/usr/bin/env ruby' > "$TMP_EXTENSION_FNAME"
echo "require 'xfel_timew_jira'" >> "$TMP_EXTENSION_FNAME"
```

# Usage

```bash
timew xfel-timew-jira
```

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fernando-jascovich/xfel-timew-jira.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
