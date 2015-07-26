require "io/console"
require "colorize"
require "rspec"
require_relative "../lib/command"
require_relative "../lib/formatter"
require_relative "../lib/coordinate"
require_relative "../src/player"
require_relative "../src/space"
require_relative "../src/board"
require_relative "../src/menu"
require_relative "../src/game"
require_relative "../src/tic-tac-toe"
require_relative "../src/connect4"
require_relative "../src/mastermind"
require_relative "../src/hangman"
require_relative "../src/chess"

def board_highlight_helper(board, pos)
	board.each_space do |space, space_pos|
		space_pos == pos ? space.format.each {|format| expect(format[:background]).to eq(:white)} : \
				           space.format.each {|format| expect(format[:background]).to eq(:black)}
	end
end

def menu_highlight_helper(expected_option)
	@menu.options.length.times do |option|
		highlight = option == expected_option ? @menu.option_highlight : @menu.menu_background
		@menu.format.children[0][0][option+2].each do |map| 
			expect(map[:background]).to eq(highlight) if map[:value] != " "
			expect(map[:background]).to eq(@menu.menu_background) if map[:value] == " "
		end
	end
end

RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate
end