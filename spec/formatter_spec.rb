require_relative "spec_helper"

describe FormatHelper do 

	before :each do
		@format = FormatHelper
		@f1 = Formatter.new(5, 5)
	end


end

describe Formatter do

	before :each do
		@f = Formatter.new(10, 3)
	end

	it "should be able to initialize with a default background" do 
		f = Formatter.new(10, 3, :black)
		f.each do |space|
			expect(space[:background]).to eq(:black)
		end
	end

	describe "#columns" do
		it "should return its number of columns" do
			expect(@f.columns).to eq(3)
		end
	end

	describe "#rows" do
		it "should return its number of rows" do
			expect(@f.rows).to eq(10)
		end
	end

	describe "#size" do
		it "should return an array of its size" do
			expect(@f.size).to eq([10,3])
		end
	end

	describe "#<" do
		it "should know if another format is smaller" do
			f2 = Formatter.new(5, 2)
			expect(f2 < @f).to be true
			expect(@f < f2).to be false
		end
	end

	describe "#[]" do
		it "should return the row if indexed" do 
			@f[0][0] = "1"
			expect(@f[0]).to eq(['1', ' ', ' '])
			expect(@f[0][0]).to eq("1")
		end

		it "should return nil if index is not assigned" do
			expect(@f[20]).to eq(nil)
			expect(@f[-20]).to eq(nil)
		end
	end

	describe "#[]=" do
		it "should assign the row a new array only of length columns" do 
			@f[0] = [1, 2, 3]
			expect(@f[0]).to eq([1, 2, 3])
			expect { @f[0] = [1, 2, 3, 4] }.to raise_error(IndexError)
			expect { @f[0] = [1, 2] }.to raise_error(IndexError)
		end
	end

	describe "#each" do
		it "should yield each space format with its position" do
			count = 0
			@f[0][2], @f[2][0] = "l", "b"
			@f.each do |space, pos|
				expect(@f.map[pos[0]][pos[1]]).to equal(space)
				count += 1
			end
			expect(count).to eq(@f.rows * @f.columns)
		end
	end

	it "should intialize with all empty uncolored spaces" do
		@f.each do |space, pos|
			expect(space[:value]).to eq(" ")
			expect(space[:color]).to eq(nil)
			expect(space[:background]).to eq(nil)
		end
	end

	describe "#get_space" do 
		it "should return the space at the position" do 
			@f[0][0] = "l"
			expect(@f.get_space([0,0])).to eq(@f[0][0])
		end

		it "should take a coordinate class as an argument" do
			@f[0][0] = "h"
			expect(@f.get_space(Coordinate.new(0, 0))).to eq(@f[0][0])
		end

		it "should return nil for spaces out of range" do
			expect(@f.get_space([10, 3])).to eq(nil)
			expect(@f.get_space([11, 1])).to eq(nil)
		end
	end

	describe "#set_space" do
		it "should take a coordinate class as an argument" do
			@f.set_space(Coordinate.new(0, 0), value: "X")
			expect(@f[0][0]).to eq("X")
		end

		it "should set the value of a space only with a single character" do
			@f.set_space([0,0], value: "X")
			expect(@f[0][0]).to eq("X")
			expect{ @f.set_space([0,0], value: "XY") }.to raise_error(ArgumentError)
		end

		it "should set the foreground of a space" do 
			@f.set_space([0,0], color: :red)
			expect(@f.map[0][0][:color]).to eq(:red)
			expect(@f[0][0].colorized?).to be true
		end

		it "should set the background of a space" do
			@f.set_space([0,0], background: :red)
			expect(@f.map[0][0][:background]).to eq(:red)
			expect(@f[0][0].colorized?).to be true
		end

		it "should uncolorize the space" do 
			@f.set_space([0,0], value: "X", color: :red)
			@f.set_space([0,0], uncolor: :true)
			expect(@f.get_space([0,0]).colorized?).to be false
			expect(@f[0][0]).to eq("X")
		end
	end

	describe "#set_background" do 
		it "should set the background of all spaces" do
			@f.set_background(:black)
			@f.each {|space| expect(space[:background]).to eq(:black)}
		end
	end

	describe "#set_direction" do 
		it "should set the value of all spaces in a direction" do 
			@f.set_direction([0,0], [0,1], value: "X")
			@f.columns.times {|column| expect(@f[0][column]).to eq("X")}
			@f.set_direction([0,0], [1,0], value: "Y")
			@f.rows.times {|row| expect(@f[row][0]).to eq("Y")}
			@f.set_direction([0,0], [1,1], value: "Z")
			@f.columns.times {|column| expect(@f[column][column]).to eq("Z")}
		end

		it "should set the foreground color of all spaces in direction" do
			@f.set_direction([0,0], [0,1], value: "X", color: :red)
			@f.columns.times {|column| expect(@f[0][column].colorized?).to be true}
			@f.set_direction([0,0], [1,0], value: "Y", color: :red)
			@f.rows.times {|row| expect(@f[row][0].colorized?).to be true}
			@f.set_direction([0,0], [1,1], value: "Z", color: :red)
			@f.columns.times {|column| expect(@f[column][column].colorized?).to be true}
		end

		it "should set the background color of all spaces in direction" do 
			@f.set_direction([0,0], [0,1], background: :red)
			@f.columns.times {|column| expect(@f[0][column].colorized?).to be true}
			@f.set_direction([0,0], [1,0], background: :red)
			@f.rows.times {|row| expect(@f[row][0].colorized?).to be true}
			@f.set_direction([0,0], [1,1], background: :red)
			@f.columns.times {|column| expect(@f[column][column].colorized?).to be true}
		end
	end

	describe "#add_child" do
		it "should append a child and all its childrens formats" do
			f2 = Formatter.new(5,3,:blue)
			f3 = Formatter.new(2,3,:yellow)
			f2.add_child([0,0], f3)
			@f.add_child([0,0], f2)
			f3.set_direction([0,0], [0,1], value: "X", color: :red)
			@f.map[0].each do |format| 
				expect(format).to eq({value: "X", color: :red, background: :yellow})
			end
			@f.map[2].each {|format| expect(format).to eq({value: " ", color: nil, background: :blue})}
		end
	end
end