#! /usr/bin/env ruby
# -*- coding: cp932; -*-

module WORK
  refine Time do
    def hh_mm
      strftime("%H:%M")
    end
  end

  refine Numeric do
    def hh_mm
      "%d:%02d" % [self / 3600, self % 3600 / 60]
    end

    def to_hour
      to_f / 3600
    end
  end

  using WORK

  class Record
    include Comparable

    def initialize rec
      date, @service, be, en, rest = rec
      @beg_time = Time.local(*date, *be, 0)
      @end_time = Time.local(*date, *en, 0)
      @rest = rest.map{_1 * 3600}
    end

    def <=> o
      @beg_time <=> o.beg_time
    end

    def holiday?
      case @service.to_i
      when 2, 6 then @service
      else           false
      end
    end

    def paid_holiday?
      @service == 2 ? 2 : false
    end

    def holiday_work?
      @service == 1 ? 1 : false
    end

    def business_day?
      !holiday?
    end

    def wday
      "日月火水木金土"[@beg_time.wday]
    end

    def mday
      @beg_time.mday
    end

    def beg_hhmm
      @beg_time.hh_mm
    end

    def end_hhmm
      @end_time.hh_mm
    end

    def rest_hhmm
      @rest.map{_1.hh_mm}
    end

    def total_rest
      @rest.sum
    end

    def working_time
      @end_time - @beg_time - total_rest
    end

    def regular_time(base = 7.5 * 3600)
      _ = working_time
      base < _ ? base : _
    end

    def overtime(base = 7.5 * 3600)
      _ = working_time
      base > _ ? 0 : _ - base
    end

    protected attr_reader :beg_time
  end
end
