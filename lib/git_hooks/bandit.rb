
require 'json'
require GitHooks.shared_path('git_hooks/violation')
require GitHooks.shared_path('git_hooks/violations')

module GitHooks
  module Bandit
    class Violations
      include GitHooks::Violations

      def initialize(violations_json, diffs)
        @violations = parse_violations(violations_json)
        @diffs = diffs
      end

      def fix_path(path)
        path.sub(/^#{GitHooks::GitUtils.git_base_path}\/?/, '').sub(/^\.\//, '')
      end

      def parse_violations(violations_json)
        json = JSON.parse(violations_json)

        files = json['results'].group_by { |result| fix_path(result['filename']) }

        violations = {
          'files' => files.collect { |path, results|
            {
              'path' => path,
              'offenses' => results.collect { |result|
                {
                  'severity' => result['issue_severity'],
                  'message' => "#{result['test_id']} #{result['test_name']} - #{result['issue_text']} (confidence: #{result['issue_confidence']})",
                  'location' => {
                    'line' => result['line_number'].to_i,
                    'column' => result['col_offset'].to_i + 1
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
