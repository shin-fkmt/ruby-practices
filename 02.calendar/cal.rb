#!/usr/bin/env ruby

require 'optparse'
require 'date'

# 年月の初期値設定
year = Date.today.year
month = Date.today.month

# コマンドライン引数取得
params = {}
opt = OptionParser.new
opt.on('-y [VAL]') {|v| params[:y] = v }
opt.on('-m [VAL]') {|v| params[:m] = v }
opt.parse!(ARGV)

# -y オプションの存在チェック
if !params[:y].nil?
  # -y オプションの範囲チェック
  if params[:y].to_i.between?(1970, 2100)
    year = params[:y].to_i
  else
    puts "year `#{params[:y]}' not in range 1970..2100"
    return
  end
end

# -m オプションの存在チェック
if !params[:m].nil?
  # -m オプションの範囲チェック
  if params[:m].to_i.between?(1, 12)
    month = params[:m].to_i
  else
    puts "month `#{params[:m]}' not in range 1..12"
    return
  end
end

# カレンダー日数（週ごとに格納）
calendar = Array.new

# 曜日ごとの日数テンプレート
one_week_template = {:Sun => '  ', :Mon => '  ', :Tue => '  ', :Wed => '  ', :Thu => '  ', :Fri => '  ', :Sat => '  '}

# 週ことの日数を初期化
one_week = one_week_template.dup

# 対象年月の1～末日までをループ
last_day = Date.new(year, month, -1).day
(1..last_day).each do |day|
  # 日付オブジェクト生成
  date = Date.new(year, month, day)
  # 曜日の省略名をキーに曜日ごとの日数を2byte右詰めで設定
  one_week[date.strftime('%a').to_sym] = day.to_s.rjust(2, ' ')

  # 土曜日 または 月末最終日の場合
  if date.saturday? || day == last_day
    # カレンダー日数出力用変数に週ごとの日数を追加
    calendar.push(one_week.values)
    # 週ことの日数を初期化
    one_week = one_week_template.dup
  end
end

# カレンダー出力
puts "#{month}月 #{year}".center(20, ' ')
puts "日 月 火 水 木 金 土"
calendar.each { |one_week| puts one_week.join(' ') }
