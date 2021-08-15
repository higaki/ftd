#! /usr/bin/env ruby
# -*- coding: cp932; -*-
require 'record'
require 'test/unit'

class TestRecord < Test::Unit::TestCase
  include WORK

  def test_new
    r = Record.new([[2021, 7, 25], 6, [8, 00], [16, 30], [1]])

    assert_equal(
      Time.local(2021, 7, 25,  8,  0, 0),
      r.instance_eval("@beg_time"))
    assert_equal(
      Time.local(2021, 7, 25, 16, 30, 0),
      r.instance_eval("@end_time"))
    assert_equal(6,      r.instance_eval("@service"))
    assert_equal([3600], r.instance_eval("@rest"))
  end

  def test_rest
    r = Record.new([[2021, 7, 25], 6, [8, 00], [16, 30], [1, 1.5]])
    assert_equal([3600, 5400], r.instance_eval("@rest"))
  end

  def test_holiday?
    [2, 6].each do |x|
      r = Record.new([[2021, 7, 25], x, [8, 0], [16, 30], [1]])
      assert_false(!r.holiday?)
    end
    [0, 1, 3, 4, 5, 7, 8, 9, "", "a"].each do |x|
      r = Record.new([[2021, 7, 25], x, [8, 0], [16, 30], [1]])
      assert_false(r.holiday?)
    end
  end

  def test_paid_holiday?
    [2].each do |x|
      r = Record.new([[2021, 7, 25], x, [8, 0], [16, 30], [1]])
      assert_equal(x, r.paid_holiday?)
    end
    [0, 1, 3, 4, 5, 6, 7, 8, 9, "", "a"].each do |x|
      r = Record.new([[2021, 7, 25], x, [8, 0], [16, 30], [1]])
      assert_false(r.paid_holiday?)
    end
  end

  def test_holiday_work?
    [1].each do |x|
      r = Record.new([[2021, 7, 25], x, [8, 0], [16, 30], [1]])
      assert_equal(x, r.holiday_work?)
    end
    [0, 2, 3, 4, 5, 6, 7, 8, 9, "", "a"].each do |x|
      r = Record.new([[2021, 7, 25], x, [8, 0], [16, 30], [1]])
      assert_false(r.holiday_work?)
    end
  end

  def test_business_day?
    [2, 6].each do |x|
      r = Record.new([[2021, 7, 25], x, [8, 0], [16, 30], [1]])
      assert_false(r.business_day?)
    end
    [0, 1, 3, 4, 5, 7, 8, 9, "", "a"].each do |x|
      r = Record.new([[2021, 7, 25], x, [8, 0], [16, 30], [1]])
      assert_true(r.business_day?)
    end
  end

  def test_wday
    {
      日: [2021, 7, 11],
      月: [2021, 7, 12],
      火: [2021, 7, 13],
      水: [2021, 7, 14],
      木: [2021, 7, 15],
      金: [2021, 7, 16],
      土: [2021, 7, 17],
    }.each do
      r = Record.new([_1.last, '', [8, 0], [16, 30], [1]])
      assert_equal _1.first.to_s, r.wday
    end
  end

  def test_mday
    (1..31).each do |x|
      r = Record.new([[2021, 7, x], '', [8, 0], [16, 30], [1]])
      assert_equal(x, r.mday)
    end
  end

  def test_beg_hhmm
    [
      ["08:00", [ 8, 0]],
      ["09:00", [ 9, 0]],
      ["10:30", [10, 30]],
    ].each do |exp, src|
      r = Record.new([[2021, 7, 1], '', src, [17, 30], [1]])
      assert_equal(exp, r.beg_hhmm)
    end
  end

  def test_end_hhmm
    [
      ["16:45", [16, 45]],
      ["17:00", [17, 00]],
      ["17:30", [17, 30]],
      ["18:15", [18, 15]],
    ].each do |exp, src|
      r = Record.new([[2021, 7, 1], '', [8, 00], src, [1]])
      assert_equal(exp, r.end_hhmm)
    end
  end

  def test_rest_hhmm
    [
      [["1:00"], [1]],
      [["2:15"], [2.25]],
      [["1:00", "0:30"], [1, 0.5]],
      [["0:45"], [0.75]],
      [["0:00"], [0]],
    ].each do |exp, src|
      r = Record.new([[2021, 7, 1], '', [8, 00], [16, 30], src])
      assert_equal(exp, r.rest_hhmm)
    end
  end

  def test_total_rest
    [
      [3600, [1]],
      [5400, [1, 0.5]],
      [7200, [1, 1]],
    ].each do |exp, src|
      r = Record.new([[2021, 7, 1], '', [8, 00], [16, 30], src])
      assert_equal(exp, r.total_rest)
    end
  end

  def test_working_time
    [
      [8,   [ 8, 00], [17, 00], [1]],
      [7.5, [ 9, 00], [17, 30], [1]],
      [7.5, [ 9, 00], [18, 00], [1.5]],    # lon rest
      [5,   [13, 00], [18, 00], [0]],      # no rest
      [6.5, [ 8, 00], [17, 00], [1, 1.5]], # multi rest
    ].each do |exp, be, en, rest|
      r = Record.new([[2021, 7, 1], '', be, en, rest])
      assert_equal(exp * 3600, r.working_time)
    end
  end

  def test_regular_time
    [
      [7.5, [16, 30]],        #                 just equals base
      [7.5, [17, 00]],        # return base if greater than base
      [7.0, [16, 00]],        #                   less than base
    ].each do |exp, en|
      r = Record.new([[2021, 7, 1], '', [8, 00], en, [1]])
      assert_equal(exp * 3600, r.regular_time, exp)
    end
  end

  def test_overtime
    [                         # 8 hours working
      [0.0, 8],               # working_time equals base hours
      [0.0, 9],               # working_time less than base hours
      [0.5, 7.5],             # working_time greater than base hours
      [1.0, 7],
    ].each do |exp, base|
      r = Record.new([[2021, 7, 1], '', [8, 00], [17, 00], [1]])
      assert_equal(exp * 3600, r.overtime(base * 3600), base)
    end
  end
end

class TestNumeric < Test::Unit::TestCase
  include WORK
  using WORK

  def test_hh_mm
    [
      ["0:00",    0],
      ["1:00", 3600],
      ["2:15", 8100],
      ["1:15", 4500],
      ["1:15", 4545],         # truncate less than minutes
    ].each do |exp, src|
      assert_equal(exp, src.hh_mm)
    end
  end

  def test_to_hour
    [
      [0,         0],
      [1,      3600],
      [7.75,  27900],
      [1.25,   4500],
      [1.2625, 4545],         # NOT truncate less than minutes
    ].each do |exp, src|
      assert_equal(exp, src.to_hour)
    end
  end
end

