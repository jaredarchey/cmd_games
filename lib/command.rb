=begin
		The command class is used to pass an objects actions to be mapped
		to key input. This is a work around because serializing procs with yaml
		raises errors. A command is created by giving it an object and an action.
		When the command needs to be run, call send with the appropriate parameters.
=end

class Command
	attr_reader :action_object, :action

	def initialize(action_object, action)
		@action_object = action_object
		@action = action
	end

	def send(*params)
		params.length == 0 ? @action_object.send(@action) : @action_object.send(@action, *params)
	end
end