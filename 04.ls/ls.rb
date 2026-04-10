#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

class Ls
  def initialize(max_col_size = 3)
    @max_col_size = max_col_size
  end

  def main
    file_name_match_flag = parse_options_for_file_name_match_flag
    directory_contents = retrieve_directory_contents(file_name_match_flag)
    output_text = sort_contents_for_ls_command(directory_contents)
    output(output_text)
  end

  private

  def parse_options_for_file_name_match_flag
    file_name_match_flag = 0

    opt = OptionParser.new
    opt.on('-a') { |v| file_name_match_flag = File::FNM_DOTMATCH if v }
    opt.parse!(ARGV)

    file_name_match_flag
  end

  def retrieve_directory_contents(file_name_match_flag)
    Dir.glob('*', file_name_match_flag)
  end

  def sort_contents_for_ls_command(directory_contents)
    output_text = []
    row_count = directory_contents.size / @max_col_size
    row_count += 1 unless (directory_contents.size % @max_col_size).zero?

    directory_contents.sort
                      .each_slice(row_count)
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
