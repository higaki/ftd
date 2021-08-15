#! /usr/bin/env ruby
# -*- coding: cp932; -*-
require_relative '1st'
require 'test/unit'

class Test1st < Test::Unit::TestCase
  include WORK

  def exp(src)
    src.map(&:strip).join("\t")
  end

  def test_wday
    [
      [1, "木"],
      [2, "金"],
      [3, "土"],
      [4, "日"],
      [5, "月"],
      [6, "火"],
      [7, "水"],
    ].each do |mday, wday|
      e = exp(%W[#{mday} #{wday} \  08:00 16:30 1:00])
      r = Record.new [[2021, 7, mday], 'not holiday', [8, 00], [16, 30], [1]]
      assert_equal(e, format(r))
    end
  end

  def test_service
    [
      [exp(%W[1 木 \  08:00 16:30 1:00]), ''], # business day
      [exp(%W[1 木 1  08:00 16:30 1:00]), 1],  # holiday work
      [exp(%W[1 木 2]),                   2],  # paid holiday
      [exp(%W[1 木 \ ]),                  6],  # holiday
      [exp(%W[1 木 \  08:00 16:30 1:00]), " "],
      [exp(%W[1 木 \  08:00 16:30 1:00]), 0],
      [exp(%W[1 木 \  08:00 16:30 1:00]), 3],
      [exp(%W[1 木 \  08:00 16:30 1:00]), 4],
      [exp(%W[1 木 \  08:00 16:30 1:00]), 5],
      [exp(%W[1 木 \  08:00 16:30 1:00]), 7],
      [exp(%W[1 木 \  08:00 16:30 1:00]), 8],
      [exp(%W[1 木 \  08:00 16:30 1:00]), 9],
      [exp(%W[1 木 \  08:00 16:30 1:00]), 'a'],
    ].each do |e, srv|
      r = Record.new [[2021, 7, 1], srv, [8, 00], [16, 30], [1]]
      assert_equal(e, format(r), srv)
    end
  end
end
