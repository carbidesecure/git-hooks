#!/usr/bin/env ruby

require(File.join(File.expand_path(File.dirname(__FILE__)), *%w{ .. lib git_hooks }))

ROOT_DIR=`git rev-parse --show-cdup`.strip

if !File.exist?("#{ROOT_DIR}.bundle/config")
  exit(0)
end

print GitHooks.msg("\nUpdating bundle path... ", 'cyan')

`#{ROOT_DIR}bin/update-bundle-path`

if $? != 0
  puts "#{GitHooks.msg("WARNING:", 'red')} tried to switch bundle path but..."
  puts ruby_version
else
  puts GitHooks.ok
end
