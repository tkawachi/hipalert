# coding: utf-8
require 'rubygems'
require 'clockwork'
require 'hipchat-api'

if !ENV['HIPCHAT_API_KEY'] || !ENV['ROOM']
  puts 'HIPCHAT_API_KEY or ROOM env is not set'
  exit(1)
end


class Time
  def home_day?
    tuesday? || wednesday? || thursday? || friday?
  end

  def office_day?
    monday?
  end

  def weekday?
    home_day? || office_day?
  end
end

Clockwork.configure do |config|
  config[:tz] = 'Asia/Tokyo'
end

module Clockwork
  every(1.day, 'meeting.notification', at: %w(8:35 14:50), if: lambda { |t| t.home_day? }) do
    message = 'あと10分でミーティングでーす！'
    send_message(message)
  end

  every(1.week, 'report.notification', at: 'friday 18:20') do
    message = '今日の午後やったことをまとめて話そう。Keep/Problem を書こう。'
    send_message(message)
  end

  def send_message(message)
    hipchat_api = HipChat::API.new(ENV['HIPCHAT_API_KEY'])
    from = ENV['FROM'] || 'bot'
    hipchat_api.rooms_message(ENV['ROOM'], from, message, 1)
  end
end
