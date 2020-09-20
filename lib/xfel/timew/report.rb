#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'date'

module Xfel
  module Timew
    class Report
      def initialize
        out = {}
        read.each do |x|
          worklog = convert(x)
          next if worklog.nil?

          sync(worklog)
          k = worklog[:project]
          unless out.key?(k)
            out[k] = {}
          end

          unless out[k][worklog[:key]]
            out[k][worklog[:key]] = 0
          end

          out[k][worklog[:key]] += worklog[:duration]
        end
        table(out)
      end

      def read
        header_finished = false
        json_str = ''
        while (line = gets)
          if !header_finished
            header_finished = line.length == 1
          else
            json_str += line
          end
        end
        JSON.parse(json_str)
      end

      def key_from_tags(tags)
        tags.each do |x|
          return x unless (x =~ /^[A-Z]+-[0-9]+$/).nil?
        end
        nil
      end

      def project_from_key(key)
        key.split('-')[0]
      end

      def convert(item)
        key = key_from_tags(item['tags'])
        return unless key && item['end']

        start = DateTime.parse(item['start'])
        finish = DateTime.parse(item['end'])
        duration = finish.to_time.to_i - start.to_time.to_i
        project = project_from_key(key)
        { project: project, key: key, start: start, duration: duration }
      end

      def sync(worklog)
        jira_host = ''
        jira_user = ''
        jira_pass = ''
        vars = {
          notifyUsers: false,
          adjustEstimate: 'leave',
          overrideEditableFlag: true
        }
        body = {
          comment: '',
          started: worklog[:start],
          timeSpentSeconds: worklog[:duration]
        }
        url = "#{jira_host}/rest/api/3/issue/#{worklog[:key]}/worklog"
        puts "Should sync: #{url}"
      end

      def col(text, fill = ' ')
        col_width = 20
        "| #{text.ljust(col_width, fill)} "
      end

      def table(data)
        puts col('Project') + col('Hours') + col('Total')
        puts col('', '-') + col('', '-') + col('', '-')
        data.each do |project, tickets|
          puts col(project)
          total = 0
          tickets.each do |key, duration|
            k = "|--#{key}"
            hours = (duration.to_f / 60 / 60).round(1)
            total += hours
            puts "#{col(k)}#{col(hours.to_s)}"
          end
          puts col('') + col('') + col(total.to_s)
        end
      end
    end
  end
end
