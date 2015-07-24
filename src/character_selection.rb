require_relative "../lib/ascii_art"
require_relative "board"
require_relative "../lib/formatter"
#require_relative "../lib/format_helper"

class Selection
	include Art
	attr_reader :characters

	def initialize
		@board = Board.new(7,6, true)
		@display = @board.full(:cyan)
		@characters = get_chars
		char_index = 0
		@board.each_space do |space|
			space.set(value: @characters[char_index]) if @characters[char_index]
			char_index += 1
		end
	end

	def select_a_character(prompt='')
		character = nil
		while character == nil
			puts @display.to_s
			input = @board.use
			case input
			when "\r" then character = @board.current_space.value
			when " " then character = @board.current_space.value
			when "q" then quit
			end
		end
		character
	end

	def get_nested_hash(hash, values=[])
		hash.each do |key, value|
			if hash[key].class == Hash
				get_nested_hash(hash[key]).each {|value| values << value}
			else 
				values << hash[key]
			end
		end
		values
	end

	def get_chars
		characters = []
		Art.constants.each do |constant|
			if Art.const_get(constant).class == Hash
				get_nested_hash(Art.const_get(constant)).each {|char| characters << char }
			else
				characters << Art.const_get(constant)
			end
		end
		characters
	end
end

#c = Selection.new.select_a_character