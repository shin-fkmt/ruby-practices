#!/usr/bin/env ruby
# frozen_string_literal: true

class Ls
  def initialize(max_col_size = 3)
    @max_col_size = max_col_size
  end

  def main
    retrieve_directory_contents
    sort_contents_for_ls_command
    output
  end

  private

  def retrieve_directory_contents
    @directory_contents = Dir.children(Dir.pwd).filter { _1[0] != '.' }
  end

  def sort_contents_for_ls_command
    @output_text = []
    row_count = @directory_contents.size / @max_col_size
    row_count += 1 unless (@directory_contents.size % @max_col_size).zero?

    @directory_contents.sort
                       .each_slice(row_count)
                       .to_a
                       .each do |rows|
                         max_char_size = rows.max { |a, b| a.size <=> b.size }.size
                         rows.each_with_index do |row, i|
                           @output_text[i] ||= []
                           @output_text[i] << row.ljust(max_char_size)
                         end
                       end
  end

  def output
    @output_text.each { |line| puts line.join('  ') }
  end
end

Ls.new.main
