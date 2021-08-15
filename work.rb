#! /usr/bin/env ruby
# -*- coding: cp932; -*-

require 'record'
include WORK
using WORK

_ = ''
regular_time = 0
overtime     = 0
puts eval(ARGF.read)
  .map{Record.new(_1)}
  .sort
  .map{|rec|
  buf= [rec.mday, rec.wday]
  if rec.business_day? || rec.paid_holiday?
    r = rec.regular_time
    o = rec.overtime
    buf += [rec.beg_hhmm, rec.end_hhmm, rec.total_rest.hh_mm, r.hh_mm, o.hh_mm]
    regular_time += r
    overtime     += o
  end
  buf.join("\t")
}
puts ['', '', '', '', '', regular_time.hh_mm, overtime.hh_mm].join("\t")

