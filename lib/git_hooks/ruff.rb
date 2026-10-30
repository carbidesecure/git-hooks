
require 'json'
require GitHooks.shared_path('git_hooks/violation')
require GitHooks.shared_path('git_hooks/violations')

module GitHooks
  module Ruff
    class Violations
      include GitHooks::Violations

      def initialize(violations_json, diffs)
        @violations = parse_violations(violations_json)
        @diffs = diffs
      end

      def fix_path(path)
        path.sub(/^#{GitHooks::GitUtils.git_base_path}\/?/, '')
      end

      def parse_violations(violations_json)
        json = JSON.parse(violations_json)

        files = json.group_by { |violation| fix_path(violation['filename']) }

        violations = {
          'files' => files.collect { |path, file_violations|
            {
              'path' => path,
              'offenses' => file_violations.collect { |violation|
                {
                  'message' => [violation['code'], violation['message']].compact.join(' - '),
                  'location' => {
                    'line' => violation['location']['row'].to_i,
                    'column' => violation['location']['column'].to_i
                  }
                }
              }
            }
          }
        }

        violations
      end
    end
  end
end
