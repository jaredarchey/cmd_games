require_relative "spec_helper"

describe TicTacToe do

	before :all do 
		@ttt = TicTacToe.new
	end

	describe "#initialize" do 

		it "should be 3 rows and 3 columns" do 
			expect([@ttt.board.rows, @ttt.board.columns]).to eq([3,3])
		end

		it "should have X vs O" do 
			expect(@ttt.player1.setter).to eq("X")
			expect(@ttt.player2.setter).to eq("O")
		end
	end

	describe "#select_space" do 

		it "should set a players piece in the current space" do 
			@ttt.select_space
			expect(@ttt.board.board[0][0].value).to eq("X")
		end

		it "should only set in an empty space" do 
			@ttt.board.set_space([0,0], value: "$")
			@ttt.select_space
			expect(@ttt.board.board[0][0].value).to eq("$")
		end

		it "should change turns if the current space is empty" do 
			expect(@ttt.board.board[0][1].empty?).to be true
			expect(@ttt.turn).to eq(@ttt.player2)
			@ttt.board.move_highlight(:right)
			@ttt.select_space
			expect(@ttt.turn).to eq(@ttt.player1)
		end

		it "should not change turns if the current space is not empty" do 
			expect(@ttt.turn).to eq(@ttt.player1)
			expect(@ttt.board.board[0][1].empty?).to be false
			@ttt.select_space
			expect(@ttt.turn).to eq(@ttt.player1)
		end

		it "should find a winner if there are @to_win in a row" do 
			expect(@ttt.to_win).to eq(3)
			expect(@ttt.winner).to eq(nil)
			@ttt.board.set_space([0,0], value: " ")
			@ttt.board.set_by_pattern([0,1], [1,0], "X")
			@ttt.board.move_highlight(:left)
			@ttt.select_space
			expect(@ttt.winner).to eq("X")
			@ttt.board.set_by_pattern([0,0], [1,0], value: " ")
			@ttt.board.set_by_pattern([0,0], [0,1], value: " ")
		end
	end

	describe "#adjust_size" do 

		it "should change the size of the board" do 
			expect(@ttt.size).to eq(3)
			@ttt.adjust_size(:right)
			expect(@ttt.size).to eq(4)
			expect([@ttt.board.rows, @ttt.board.columns]).to eq([4,4])
			@ttt.adjust_size(:left)
			expect(@ttt.size).to eq(3)
			expect([@ttt.board.rows, @ttt.board.columns]).to eq([3,3])
		end

		it "should not make the size less than to_win" do 
			expect([@ttt.size, @ttt.to_win]).to eq([3,3])
			@ttt.adjust_size(:left)
			expect(@ttt.size).to eq(3)
		end

		it "should not make the size greater than 5" do 
			2.times { @ttt.adjust_size(:right) }
			expect(@ttt.size).to eq(5)
			@ttt.adjust_size(:right)
			expect(@ttt.size).to eq(5)
		end

		it "should not make the size less than 2" do
			@ttt.to_win = 0
			5.times { @ttt.adjust_size(:left) }
			expect(@ttt.size).to eq(2)
			@ttt.size = 3
			@ttt.to_win = 3
		end
	end

	describe "#adjust_win" do 

		it "should change the number of spaces needed to win" do 
			@ttt.adjust_win(:left)
			@ttt.board.set_space([0,1], value: "O")
			expect(@winner).to eq(nil)
			@ttt.select_space
			expect(@ttt.winner).to eq("O")
			@ttt.board.set_by_pattern([0,0], [0,1], value: " ")
			@ttt.winner = nil
		end

		it "should not be more than the size" do 
			expect(@ttt.to_win).to eq(2)
			expect(@ttt.size).to eq(3)
			3.times { @ttt.adjust_win(:right) }
			expect(@ttt.to_win).to eq(3)
		end

		it "should not be less than 2" do 
			3.times { @ttt.adjust_win(:left) }
			expect(@ttt.to_win).to eq(2)
		end
	end
end