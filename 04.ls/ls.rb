#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
require 'date'
require 'optparse'

class Ls
  TYPES = { 'fifo' => 'p', 'characterSpecial' => 'c', 'directory' => 'd',
            'blockSpecial' => 'b', 'file' => '-', 'link' => 'l', 'socket' => 's' }.freeze

  PERMISSIONS = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx',
                  '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }.freeze

  def initialize(max_col_size = 3)
    @options = {}
    opt = OptionParser.new
    opt.on('-a')
    opt.on('-l')
    opt.on('-r')
    opt.parse!(ARGV, into: @options)
    @max_col_size = @options[:l] ? 1 : max_col_size
  end

  def main
    directory_contents = retrieve_directory_contents
    detail_contents = add_detail_contents(directory_contents) if @options[:l]
    output_text = sort_by_column_groups(detail_contents || directory_contents)
    output(output_text)
  end

  private

  def retrieve_directory_contents
    file_name_match_flag = @options[:a] ? File::FNM_DOTMATCH : 0
    directory_contents = Dir.glob('*', file_name_match_flag)
    @options[:r] ? directory_contents.reverse : directory_contents
  end

  def add_detail_contents(directory_contents)
    block_size = 0
    detail_contents = directory_contents.map do |content_name|
      detail_content = []
      file_lstat = File.lstat(File.join(Dir.pwd, content_name))
      block_size += file_lstat.blocks / 2
      detail_content << TYPES[file_lstat.ftype] + convert_to_permission(file_lstat.mode.to_s(8))
      detail_content << file_lstat.nlink.to_s
      detail_content << Etc.getpwuid(file_lstat.uid).name
      detail_content << Etc.getgrgid(file_lstat.gid).name
      detail_content << convert_to_content_size(file_lstat)
      datetime_format = file_lstat.mtime.to_date <= (Date.today << 6) ? '%_m月 %_d  %Y' : '%_m月 %_d %H:%M'
      detail_content << file_lstat.mtime.strftime(datetime_format)
      detail_content << content_name
      detail_content << "-> #{File.readlink(content_name)}" if TYPES[file_lstat.ftype] == TYPES['link']
      detail_content
    end

    adjust_char_length(detail_contents).map { _1.join(' ') }.unshift "合計 #{block_size}"
  end

  def convert_to_content_size(file_lstat)
    if [TYPES['characterSpecial'], TYPES['blockSpecial']].include?(TYPES[file_lstat.ftype])
      "#{file_lstat.rdev_major}, #{file_lstat.rdev_minor}"
    else
      file_lstat.size.to_s
    end
  end

  def convert_to_permission(mode)
    case mode[-4]
    when '1'
      sticky_symbol = PERMISSIONS[mode[-1]][2] == 'x' ? 't' : 'T'
      PERMISSIONS[mode[-3]] + PERMISSIONS[mode[-2]] + PERMISSIONS[mode[-1]][0..1] + sticky_symbol
    when '2'
      sgid_symbol = PERMISSIONS[mode[-2]][2] == 'x' ? 's' : 'S'
      PERMISSIONS[mode[-3]] + PERMISSIONS[mode[-2]][0..1] + sgid_symbol + PERMISSIONS[mode[-1]]
    when '4'
      suid_symbol = PERMISSIONS[mode[-3]][2] == 'x' ? 's' : 'S'
      PERMISSIONS[mode[-3]][0..1] + suid_symbol + PERMISSIONS[mode[-2]] + PERMISSIONS[mode[-1]]
    else
      PERMISSIONS[mode[-3]] + PERMISSIONS[mode[-2]] + PERMISSIONS[mode[-1]]
    end
  end

  def adjust_char_length(detail_contents)
    max_link_count_length = detail_contents.map { _1[1].size }.max
    detail_contents.each { _1[1] = _1[1].rjust(max_link_count_length) }

    max_owner_name_length = detail_contents.map { _1[2].size }.max
    detail_contents.each { _1[2] = _1[2].ljust(max_owner_name_length) }

    max_group_name_length = detail_contents.map { _1[3].size }.max
    detail_contents.each { _1[3] = _1[3].ljust(max_group_name_length) }

    max_content_size_length = detail_contents.map { _1[4].size }.max
    detail_contents.each { _1[4] = _1[4].rjust(max_content_size_length) }
  end

  def sort_by_column_groups(directory_contents)
    output_text = []
    row_count = directory_contents.size / @max_col_size
    row_count += 1 unless (directory_contents.size % @max_col_size).zero?

    directory_contents.each_slice(row_count)
                      .to_a
                      .each do |rows|
                        max_char_length = rows.map(&:size).max
                        rows.each_with_index do |row, i|
                          output_text[i] ||= []
                          output_text[i] << row.ljust(max_char_length)
                        end
                      end

    output_text
  end

  def output(output_text)
    output_text.each { |line| puts line.join('  ') }
  end
end

Ls.new.main
