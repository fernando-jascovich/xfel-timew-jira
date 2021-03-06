# frozen_string_literal: true

require 'terminal-table'

module Xfel
  module Timew
    # Report's terminal output.
    class Table
      def initialize
        @data = {}
        @table = Terminal::Table.new({ headings: %w[Project Hours Total] })
      end

      def time_str(seconds)
        hours = seconds / 3600
        minutes = seconds / 60 % 60
        format("#{hours}h %02dm", minutes)
      end

      def project_to_table(project, tickets)
        @table.add_row([project, '', ''])
        project_total = 0
        tickets.each do |key, duration|
          project_total += duration
          @table.add_row(["└── #{key}", time_str(duration), ''])
        end
        @table.add_row(['', '', time_str(project_total)])
        project_total
      end

      def data_to_table
        total = 0
        @data.each do |project, tickets|
          total += project_to_table(project, tickets)
          @table.add_separator
        end
        @table.add_row(['', '', time_str(total)])
      end

      def render
        data_to_table
        @table.align_column(1, :right)
        @table.align_column(2, :right)
        puts @table
      end

      def add(worklog)
        project = worklog[:project]
        ticket = worklog[:key]

        @data[project] = {} unless @data.key?(project)
        @data[project][ticket] = 0 unless @data[project].key?(ticket)
        @data[project][ticket] += worklog[:duration]
      end
    end
  end
end
