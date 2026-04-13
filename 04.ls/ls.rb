#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

class Ls
  def initialize(max_col_size = 3)
    @max_col_size = max_col_size
  end

  def main
    directory_contents = retrieve_directory_contents
    output_text = sort_by_column_groups(directory_contents)
    output(output_text)
  end

  private

  def retrieve_directory_contents
    directory_contents = Dir.glob('*')

    params = {}
    opt = OptionParser.new
    opt.on('-r')
    opt.parse!(ARGV, into: params)

    params[:r] ? directory_contents.reverse : directory_contents
  end

  def sort_by_column_groups(directory_contents)
    output_text = []
    row_count = directory_contents.size / @max_col_size
    row_count += 1 unless (directory_contents.size % @max_col_size).zero?

    directory_contents.each_slice(row_count)
                      .to_a
                      .each do |rows|
                        max_char_size = rows.map(&:size).max
                        rows.each_with_index do |row, i|
                          output_text[i] ||= []
                          output_text[i] << row.ljust(max_char_size)
                        end
                      end

    output_text
  end

  def output(output_text)
    output_text.each { |line| puts line.join('  ') }
  end
end

Ls.new.main
