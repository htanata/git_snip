# git-snip

Clean obsolete branches on your git repository safely.

When a branch has been merged remotely, your local branch is not automatically
deleted and will build up, making it harder to find your relevant branches.

This gem aims to fix that by doing using [`git cherry`][git-cherry] to find
local branches which have been merged and delete them.

## Installation

Install using RubyGems:

    $ gem install git_snip

You can also this line to your application's `Gemfile`:

```ruby
gem 'git_snip', require: false
```

And then execute:

    $ bundle

## Usage

  git snip

## Contributing

1. Fork it ( https://github.com/htanata/git_snip/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[git-cherry]: http://git-scm.com/docs/git-cherry
