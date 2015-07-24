require_relative "board"
require_relative "player"
require_relative "menu"
require_relative "../lib/formatter"
require_relative "character_selection"

class Game
	include FormatHelper

	def initialize(rows, columns, interactive=true)
		@board = Board.new(rows, columns, interactive)
		@display = @board.full(:light_magenta)
		@player1 = @turn = Player.new
		@player2 = Player.new
		@characters = Selection.new
		@main_menu = Menu.new(self.class.to_s)

		@winner = nil
	end

	def change_turn
		@turn = @turn.object_id === @player1.object_id ? @player2 : @player1
	end

	def save

	end
end