game:GetService("ProximityPromptService").MaxPromptsVisible = 100

-- errors
local NO_KEY_GIVEN = "Could not create an input object because no key was given."
local NO_CALLBACK_GIVEN = "Could not set callback because no callback was given."
local NO_CALLBACK_SET = "Could not disconnect/reconnect because no callback was set."
local CALLBACK_NOT_CONNECTED = "Could not disconnect because connection is already disconnected."
local CALLBACK_ALREADY_CONNECTED = "Could not reconnected because connection is already connected."

--[=[
	@class Input

	Used to create and handle input connections.

	:::info
	The [Input] class is chained, meaning it returns itself. That means you can do things like this.

	```lua
	local input = Input.new(Enum.KeyCode.E)
	:setCallback(print)
	:disconnect()
	:reconnect()
	```
	:::
]=]
local Input = {}
do
	Input.__index = Input

	local cachedProximityPrompt = Instance.new("ProximityPrompt")
	cachedProximityPrompt.ActionText = ""
	cachedProximityPrompt.ClickablePrompt = false
	cachedProximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
	cachedProximityPrompt.MaxActivationDistance = 1e-18
	cachedProximityPrompt.Name = ""
	cachedProximityPrompt.RequiresLineOfSight = false
	cachedProximityPrompt.UIOffset = Vector2.new(math.huge, math.huge)

	--[=[
		@return Input

		Creates an input object with the specified [Enum.KeyCode].
	]=]
	function Input.new(key: Enum.KeyCode)
		assert(key, NO_KEY_GIVEN)

		local proximityPrompt = cachedProximityPrompt:Clone()
		proximityPrompt.KeyboardKeyCode = key

		--[=[
			@prop key Enum.KeyCode
			@within Input

			The [Enum.KeyCode] given with [Input.new].
		]=]

		return setmetatable({proximityPrompt = proximityPrompt, key = key}, Input)
	end

	--[=[
		@return Input

		Sets the callback to be ran when the input key is pressed.
	]=]
	function Input:onTriggered(callback: (Player | nil) -> ())
		assert(callback, NO_CALLBACK_GIVEN)

		--[=[
			@prop callback (Player | nil) -> ()
			@within Input

			The callback set with [Input:setCallback].
		]=]
		self.callback = callback

		--[=[
			@prop connection RBXScriptConnection
			@within Input

			The connection created in [Input:setCallback].
		]=]
		self.connection = self.proximityPrompt.Triggered:Connect(callback)

		return self
	end

	--TODO: add onBegin and onEnd functions, or maybe set it as an argument for onTriggered and change the name back to setCallback

	--[=[
		@return Input

		Disconnects the input connection if it was set with [Input:setCallback].
	]=]
	function Input:disconnect()
		assert(self.callback, NO_CALLBACK_SET)
		assert(not self.connection.Connected, CALLBACK_NOT_CONNECTED)

		self.connection:Disconnect()
	end

	--[=[
		@return Input

		Reconnects the input connection if the callback was already set with [Input:setCallback].
	]=]
	function Input:reconnect()
		assert(self.callback, NO_CALLBACK_SET)
		assert(self.connection.Connected, CALLBACK_ALREADY_CONNECTED)

		self.proximityPrompt.Triggered:Connect(self.callback)
	end
end

return Input