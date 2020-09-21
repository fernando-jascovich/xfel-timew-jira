# frozen_string_literal: true

require 'date'
require 'json'
require_relative 'jira'
require_relative 'table'

module Xfel
  module Timew
    # Main entry point for TimeWarrior report
    class Report
      def initialize
        table = Table.new
        read.each do |x|
          worklog = convert(x)
          next if worklog.nil?

          Jira.new(worklog)
          table.add(worklog)
        end
        table.render
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
    end
  end
end
