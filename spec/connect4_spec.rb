require_relative "spec_helper"

describe Connect4 do 
	before :all do 
		@c4 = Connect4.new
	end

	describe "#initilize" do 

		it "should need 4 in a row to win" do 
			expect(@c4.to_win).to eq(4)
		end

		it "should have O vs 0" do 
			expect(@c4.player1.setter).to eq("0")
			expect(@c4.player2.setter).to eq("O")
		end

		it "should only move left and right" do 
			@c4.board.use("\e[C")
			expect(@c4.board.current_space(true)).to eq([0,1])
			@c4.board.use("\e[D")
			expect(@c4.board.current_space(true)).to eq([0,0])
			@c4.board.use("\e[A")
			expect(@c4.board.current_space(true)).to eq([0,0])
			@c4.board.use("\e[B")
			expect(@c4.board.current_space(true)).to eq([0,0])
		end
	end

	describe "#select_space" do 
		it "should set a marker in the first empty column" do 
			expect(@c4.turn).to eq(@c4.player1)
			@c4.select_space
			expect(@c4.board.board[5][0].value).to eq("0")
		end

		it "should change turns after a marker is placed" do
			expect(@c4.turn).to eq(@c4.player2)
		end

		it "should not set in a column once its filled" do 
			4.times { @c4.select_space }
			expect(@c4.board.board[0][0].empty?).to be true
			@c4.select_space
			expect(@c4.turn).to eq(@c4.player1)
			expect(@c4.board.board[0][0].value).to eq("O")
			@c4.select_space
			expect(@c4.board.board[0][0].value).to eq("O")
		end

		it "should not change turns if the column is full" do 
			expect(@c4.turn).to eq(@c4.player1)
		end
	end
end