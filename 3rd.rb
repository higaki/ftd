#! /usr/bin/env ruby
# -*- coding: cp932; -*-

require 'record'
include WORK

def format(rec)
  buf = [rec.mday, rec.wday]
  buf << (rec.paid_holiday? || rec.holiday_work? || '')
  unless rec.holiday?
    buf << rec.beg_hhmm
    buf << rec.end_hhmm
    buf += rec.rest_hhmm
  end
  buf.join("\t")
end

if $0 == __FILE__
  _ = ''
  records = eval(ARGF.read).map{Record.new(_1)}.sort

  puts case File.basename($0, ".rb")
       when "1st" then records.first(15)
       when "2nd" then records.drop( 15)
       else
         STDERR.puts <<-USAGE
usage: 1st [file]
usage: 2nd [file]
         USAGE
         exit(1)
       end.map{format(_1)}
end
