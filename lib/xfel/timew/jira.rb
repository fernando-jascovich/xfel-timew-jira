# frozen_string_literal: true

require 'net/http'

module Xfel
  module Timew
    # Class for REST interaction with Jira servers.
    class Jira
      @worklogs = {}

      class << self
        attr_reader :worklogs
      end

      def initialize(worklog)
        @start = worklog[:start]
        @duration = worklog[:duration]
        @key = worklog[:key]
        return unless ENV['XFEL_JIRA_SYNC']

        if ENV['JIRA_HOST'] && ENV['JIRA_USER'] && ENV['JIRA_PASS']
          @uri = "#{ENV['JIRA_HOST']}/rest/api/2/issue/#{@key}/worklog"
          sync
        else
          log 'Missing required env vars: JIRA_HOST, JIRA_USER, JIRA_PASS'
        end
      end

      def log(msg)
        puts "#{@key} | #{msg}"
      end

      def vars
        'notifyUsers=false&adjustEstimate=leave&overrideEditableFlag=false'
      end

      def sync
        log "#{@start} sync..."
        if worklogs.any? { |w| duplicated?(w) }
          log "#{@start} already present, skipping it."
        else
          res = req_for_sync
          log "#{@start} error: #{res.code}. #{res.body}" unless req_success?(res)
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

      def fetch_worklogs
        uri = URI(@uri)
        res = execute(Net::HTTP::Get.new(uri), uri)
        unless req_success?(res)
          log "Error getting worklogs. #{res.code}: #{res.msg}"
          exit
        end
        self.class.worklogs[@key] = JSON.parse(res.body)['worklogs']
      end

      def worklogs
        fetch_worklogs unless self.class.worklogs[@key]
        self.class.worklogs[@key]
      end
    end
  end
end
