# frozen_string_literal: true

require 'net/http'

module Xfel
  module Timew
    # Class for REST interaction with Jira servers.
    class Jira
      @@worklogs = {}

      def initialize(worklog)
        @start = worklog[:start]
        @duration = worklog[:duration]
        @key = worklog[:key]
        @uri = "#{ENV['JIRA_HOST']}/rest/api/2/issue/#{@key}/worklog"
        return unless ENV['XFEL_JIRA_SYNC']

        puts "Syncing worklogs for: #{worklog[:key]}"
        sync
      end

      def vars
        'notifyUsers=false&adjustEstimate=leave&overrideEditableFlag=true'
      end

      def sync
        if worklogs.any? { |w| duplicated?(w) }
          puts "Worklog started at: #{@start} already present, skipping it."
        else
          puts "Syncing #{@start}..."
          res = req_for_sync
          puts "Error: #{res.code}. #{res.body}" unless req_success(res)
        end
      end

      def req_success?(response)
        code_int = response.code.to_i
        code_int > 199 && code_int < 300
      end

      def req_for_sync
        uri = URI("#{@uri}?#{vars}")
        req = Net::HTTP::Post.new(uri)
        req['Content-Type'] = 'application/json'
        req.body = {
          comment: '', started: @start, timeSpentSeconds: @duration
        }.to_json
        execute(req, uri)
      end

      def duplicated?(worklog)
        @start == worklog['started']
      end

      def execute(req, uri)
        req.basic_auth ENV['JIRA_USER'], ENV['JIRA_PASS']
        Net::HTTP.start(uri.hostname, uri.port, { use_ssl: true }) { |http| http.request(req) }
      end

      def worklogs
        return @@worklogs[@key] if @@worklogs[@key]

        uri = URI(@uri)
        res = execute(Net::HTTP::Get.new(uri), uri)
        unless req_success?(res)
          puts "Can't get worklogs from: #{@uri}. #{res.code}: #{res.msg}"
          exit
        end
        @@worklogs[@key] = JSON.parse(res.body)['worklogs']
        @@worklogs[@key]
      end
    end
  end
end
