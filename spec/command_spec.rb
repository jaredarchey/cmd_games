require_relative "spec_helper"

describe Command do 
	it "should initialize with an object and an action" do 
		c = Command.new([1,2,3], :length)
		expect(c.action_object.class).to eq(Array)
	end

	describe "#send" do 
		it "should call the action_object's action" do 
			c = Command.new([1,2,3], :length)
			expect(c.send).to eq(3)
		end

		it "should optionally call the action with parameters" do 
			c = Command.new([1,2,3], :<<)
			expect(c.send(4)).to eq([1, 2, 3, 4])
		end
	end
end