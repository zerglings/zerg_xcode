# Lexer for flattened object graphs stored in .pbxproj files.
#
# Author:: Victor Costan
# Copyright:: Copyright (C) 2009 Zergling.Net
# License:: MIT

# :nodoc: namespace
module ZergXcode


# Lexer for flattened object graphs stored in .xcodeproj files.
class Lexer

  def initialize(string)
    @string = string
    @i = 0
  end

  def at_beginning?
    @i == 0
  end
  private :at_beginning?

  def before_the_end?
    @i < @string.length
  end
  private :before_the_end?

  def advance(n=1)
    @i += n
  end
  private :advance

  def peek(n=1)
    @string[@i, n]
  end
  private :peek

  def match_and_advance(pattern)
    match = @string[@i..-1].match(pattern)
    @i += match[0].length if match
    match
  end
  private :match_and_advance

  def tokenize
    tokens = []
    while true
      token = next_token
      break unless token
      tokens << token
    end
    tokens
  end

  def next_token
    if at_beginning?
      encoding_match = match_and_advance(/^\/\/ \!\$\*(.*?)\*\$\!/)
      raise "No encoding - #{peek(20)}" unless encoding_match
      return [:encoding, encoding_match[1]]
    end

    while before_the_end?
      skip_comment
      
      case peek
      when /\s/
        advance
      when '(', ')', '{', '}', '=', ';', ','
        token = {'(' => :begin_array, ')' => :end_array,
                 '{' => :begin_hash, '}' => :end_hash,
                 '=' => :assign, ';' => :stop, ',' => :comma}[peek]
        advance
        return token
      when '"'
        # string
        advance
        token = ''
        while peek != '"'
          if peek == '\\'
            advance
            case peek
            when 'n', 'r', 't'
              token << { 'n' => "\n", 't' => "\t", 'r' => "\r" }[peek]
              advance
            when '"', "'", '\\'
              token << peek
              advance
            else
              raise "Uknown escape sequence \\#{peek 20}"
            end
          else
            token << peek
            advance
          end
        end
        advance
        return [:string, token]
      else
        symbol = ""
        while peek(1) =~ /[^\s\t\r\n\f(){}=;,]/
          symbol << peek(1)
          advance
        end
        return [:symbol, symbol]
      end
    end
  end
  private :next_token

  def skip_comment
    if peek(2) == '/*'
      advance(2)
      advance while peek(2) != '*/'
      advance(2)
    end
  end
  private :skip_comment

  def self.tokenize(string)
    Lexer.new(string).tokenize
  end

end

end
