require_relative "spec_helper"

describe Coordinate do

	before :each do
		@c = Coordinate.new(3, 6)
	end

	it "should be converted to an array" do 
		expect(@c.to_a).to eq([3, 6])
	end

	it "should add two coordinates" do 
		c2 = Coordinate.new(3, 3)
		c3 = @c + c2
		expect(c3.to_a).to eq([6, 9])
	end

	it "should add an array to the coordinate" do 
		c2 = @c + [1, 2]
		expect(c2.to_a).to eq([4, 8])
	end

	it "should raise an error if array length is not 2" do
		expect {@c + [1, 2, 3] }.to raise_error(ArgumentError)
		expect {@c + [1] }.to raise_error(ArgumentError)
	end

	it "should add a fixnum to both row and column" do
		c2 = @c + 3
		expect(c2.to_a).to eq([6, 9])
	end
end