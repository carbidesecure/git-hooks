#!/usr/bin/env ruby

require File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks })
require GitHooks.shared_path('git_hooks/git_tools')
require GitHooks.shared_path('git_hooks/git_utils')
require GitHooks.shared_path('git_hooks/ruff')

statuses, files = GitHooks::GitUtils.git_statuses_and_files(/.+\.pyi?/)

if !files.empty?
  if statuses.include?('AM')
    puts GitHooks.partially_staged_code('Python', 'ruff')
    exit(127)
  else
    ruff = GitHooks.fetch_command('ruff', 'ruff')

    puts <<~TEXT
      #{GitHooks.running('ruff')}

      #{GitHooks.checking_files(files)}
    TEXT

    cmd = "#{ruff} check --output-format json --no-fix --force-exclude #{files.collect { |file|
      Shellwords.escape(file)
    }.join(' ')}"

    output = `#{cmd}`

    if $? != 0
      diffs = GitHooks::GitTools::Diff.new(GitHooks::GitUtils.git_diff(:cached))
      violations = GitHooks::Ruff::Violations.new(output, diffs)

      if violations.relevant_violations?
        puts GitHooks.whoa_there
        puts GitHooks.show_violations(violations)
        exit(1)
      end
    end

    puts GitHooks.ok
  end
end

exit(0)
