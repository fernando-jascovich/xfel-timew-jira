# frozen_string_literal: true

module Xfel
  module Timew
    # Class for REST interaction with Jira servers.
    class Jira
      def initialize(worklog)
        jira_host = ''

        @start = worklog[:start]
        @duration = worklog[:duration]
        @url = "#{jira_host}/rest/api/3/issue/#{worklog[:key]}/worklog"
        sync
      end

      def vars
        {
          notifyUsers: false,
          adjustEstimate: 'leave',
          overrideEditableFlag: true
        }
      end

      def sync
        jira_user = ''
        jira_pass = ''
        body = {
          comment: '', started: @start, timeSpentSeconds: @duration
        }
        puts "Should sync: #{@url}"
      end
    end
  end
end
