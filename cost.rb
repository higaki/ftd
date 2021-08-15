#! /usr/bin/env ruby
# -*- coding: cp932; -*-

require 'record'
include WORK
using WORK

_ = ''
working  = 0
overtime = 0
puts eval(ARGF.read)
  .map{Record.new(_1)}
  .sort
  .map{|rec|
  buf = [rec.mday, rec.wday]
  if rec.business_day?
    w = rec.working_time
    o = rec.overtime(8.0 * 3600)
    buf += [rec.beg_hhmm, rec.end_hhmm, rec.total_rest.to_hour, w.to_hour]
    working  += w
    overtime += o
  end
  buf.join("\t")
}
puts ['', '', '', '', '', working.to_hour, overtime.to_hour].join("\t")
