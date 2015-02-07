# git-snip

[![Build Status](https://travis-ci.org/htanata/git_snip.svg?branch=master)](https://travis-ci.org/htanata/git_snip)
[![Code Climate](https://codeclimate.com/github/htanata/git_snip/badges/gpa.svg)](https://codeclimate.com/github/htanata/git_snip)

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

Show branches which would be deleted (accepts the same arguments as `-f`):

    $ git snip -n

Delete branches already merged to master:

    $ git snip -f

Delete branches already merged to master, except staging and production:

    $ git snip -f --ignore=staging production

Delete branches already merged to master on `/some/repo/path`:

    $ git snip -f --repo=/some/repo/path

Delete branches already merged to `branch_a`:

    $ git snip -f --target=branch_a

## Contributing

1. Fork it ( https://github.com/htanata/git_snip/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[git-cherry]: http://git-scm.com/docs/git-cherry
