# SSON - S-Expression Standard Object Notation
# a faithful embedding of JSON (RFC 8259) into a S-Expression syntax

#
# value = "#n" / "#t" / "#f" /
#         "(" value* ")" / "#(" (string value)* ")" /
#         json-number / string
# string = json-string / literal
# literal = [^0-9#;()" \t\r\n+-][^#;()" \t\r\n]*
# ";" starts a comment until end of line, it is treated as whitespace
#

# To the extent possible under law, Leah Neukirchen <leah@vuxu.org>
# has waived all copyright and related or neighboring rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

require 'json'
require 'prettyprint'
require 'strscan'

module SSON; end
class << SSON
  VERSION = "0.1"
               
  SCANIDENT = /[^0-9#;()" \t\r\n+-][^#;()" \t\r\n]*/
  IDENT = /\A#{SCANIDENT}\z/

  class SSONError < StandardError; end
  class GeneratorError < SSONError; end
  class ParserError < SSONError; end

  def generate(o)
    case o
    when Hash
      r = "#("
      o.each { |k, v| 
        r << " "  if r.size > 2
        r << generate(k.to_s) << " " << generate(v) 
      }
      r << ")"
      r
    when Array
      r = "("
      o.each { |e|
        r << " "  if r.size > 1
        r << generate(e)
      }
      r << ")"
      r
    when true
      "#t"
    when false
      "#f"
    when nil
      "#n"
    when Integer
      o.to_s
    when Float
      if o.nan?
        raise GeneratorError, "NaN not allowed in SSON"
      elsif o.infinite?
        raise GeneratorError, "Infinity not allowed in SSON"
      end
      o.to_s
    when String
      if o =~ IDENT
        o
      else
        JSON.generate(o)
      end
    else
      # like JSON.generate
      generate(o.to_s)
    end
  end

  def pretty_generate(obj)
    return PrettyPrint.format('', 80) { |q|
      inner = lambda { |o|
        case o
        when Array
          q.group(1) {
            q.text "("
            b = false
            o.each { |e|
              q.breakable " "  if b
              b = true
              inner[e]
            }
            q.text ")"
          }
        when Hash
          q.group(2) {
            q.text "#("
            b = false
            o.each { |k, v|
              q.breakable " "  if b
              b = true
              q.group {
                inner[k]
                q.text " "
                inner[v]
              }
            }
            q.text ")"
          }

        when true; q.text "#t"
        when false; q.text "#f"
        when nil; q.text "#n"
        when Integer
          q.text o.to_s
        when Float
          if o.nan?
            raise GeneratorError, "NaN not allowed in SSON"
          elsif o.infinite?
            raise GeneratorError, "Infinity not allowed in SSON"
          end
          q.text o.to_s
        when String
          if o =~ IDENT
            q.text o  # ES5 identifier
          else
            q.text JSON.generate(o)
          end
        end
      }
      inner[obj]
    }
  end

  def parse(str)
    e = SSON.enum_for(:tok, str)
    r = parse_form e
    begin
      e.next
    rescue StopIteration
      r
    else
      raise ParserError, "trailing garbage"
    end
  end

  private

  def tok(str)
    ss = StringScanner.new(str)
    until ss.eos?
      if ss.scan(/\A[ \t\r\n]+/) || ss.scan(/;[^\n]*$/)
        # ignore
      elsif ss.scan(/\(/);      yield :OPEN
      elsif ss.scan(/\)/);      yield :CLOSE
      elsif ss.scan(/#\(/);     yield :HASH
      elsif ss.scan(/#n/);      yield :NULL
      elsif ss.scan(/#t/);      yield :TRUE
      elsif ss.scan(/#f/);      yield :FALSE
      elsif s = ss.scan(/"(\\"|[^"])*"/)
        yield JSON.parse(s)
      elsif s = ss.scan(SCANIDENT)
        yield s
      elsif s = ss.scan(/[-+]?(?:\d*\.?\d+|\d+\.?\d*)(?:[eE][-+]?\d+)?/)
        yield Float(s)
      else
        raise ParserError, "invalid SSON: " + ss.peek(20).dump
      end
    end
  end

  def parse_form(e)
    case t = e.next
    when :OPEN
      r = []
      while e.peek != :CLOSE
        r << parse_form(e)
      end
      e.next
      r
    when :HASH
      r = {}
      while e.peek != :CLOSE
        k = e.next
        raise "non string key"  unless k.kind_of?(String)
        v = parse_form(e)
        r[k] = v
      end
      e.next
      r
    when :CLOSE;   raise ParserError, "invalid SSON, toplevel )"
    when :NULL;    nil
    when :TRUE;    true
    when :FALSE;   false
    when String;   t
    when Float;    t
    end
  rescue StopIteration
    raise ParserError, "early EOF"
  end

end
