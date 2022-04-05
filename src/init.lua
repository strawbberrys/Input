game:GetService("ProximityPromptService").MaxPromptsVisible = 100

type callback = (Player?) -> ()

-- errors
local NO_KEY_GIVEN = "Could not create an input object because no key was given."
local NO_CALLBACK_GIVEN = "Could not set callback because no callback was given."
local NO_CALLBACK_SET = "Could not disconnect/reconnect because no callback was set."
local CALLBACK_NOT_CONNECTED = "Could not disconnect because connection is already disconnected."
local CALLBACK_ALREADY_CONNECTED = "Could not reconnected because connection is already connected."
local NO_AMOUNT_GIVEN = "Could not set timeout because no amount was given."

--[=[
	@class Input

	Used to create and handle input connections.

	:::info
	The [Input] class is chained, meaning it returns itself. That means you can do things like this.

	```lua
	local input = Input.new(Enum.KeyCode.E)
	:onBegan(print)
	:onEnd(warn)
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
			@prop proximityPrompt ProximityPrompt
			@within Input

			The [ProximityPrompt] created with [Input.new].
		]=]

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
	function Input:onBegan(callback: callback)
		assert(callback, NO_CALLBACK_GIVEN)

		--[=[
			@prop beganCallback (Player | nil) -> ()
			@within Input

			The callback set with [Input:onBegan].
		]=]
		self.beganCallback = callback

		--[=[
			@prop beganConnection RBXScriptConnection
			@within Input

			The connection created in [Input:onBegan].
		]=]
		self.beganConnection = self.proximityPrompt.Triggered:Connect(callback)

		return self
	end

	--[=[
		@return Input

		Sets the callback to be ran when the input key is let go.
	]=]
	function Input:onEnd(callback: callback)
		assert(callback, NO_CALLBACK_GIVEN)

		--[=[
			@prop endCallback (Player | nil) -> ()
			@within Input

			The callback set with [Input:onEnd].
		]=]
		self.endCallback = callback

		--[=[
			@prop endConnection RBXScriptConnection
			@within Input

			The connection created in [Input:onEnd].
		]=]
		self.endConnection = self.proximityPrompt.TriggerEnded:Connect(callback)

		return self
	end

	--[=[
		@return Input

		Sets a timeout in between key presses for [Input:onBegan].
	]=]
	function Input:setTimeout(amount: number)
		assert(amount, NO_AMOUNT_GIVEN)
		assert(self.beganCallback, NO_CALLBACK_SET)

		if (self.beganConnection.Connected) then
			self.beganConnection:Disconnect()

			local lastPressed = -amount

			self.proximityPrompt.Triggered:Connect(function(player)
				if (os.clock() - lastPressed >= amount) then
					self.callback(player)
				end
			end)
		end

		self.timeout = amount

		return self
	end

	--[=[
		@return Input

		Disconnects either of the input connections created with [Input:onBegan] or [Input:onEnd] depending on the type argument.
	]=]
	function Input:disconnect(type: Enum.UserInputState)
		local data = if (type == Enum.UserInputState.Begin) then {callback = self.beganCallback, connection = self.beganConnection} elseif (type == Enum.UserInputState.End) then {callback = self.endCallback, connection = self.endConnection} else nil

		assert(data.callback, NO_CALLBACK_SET)
		assert(not data.connection.Connected, CALLBACK_NOT_CONNECTED)

		data.connection:Disconnect()

		return self
	end

	--[=[
		@return Input

		Reconnects either of the input connections created with [Input:onBegan] or [Input:onEnd] depending on the type argument.
	]=]
	function Input:reconnect(type: Enum.UserInputState)
		local data = if (type == Enum.UserInputState.Begin) then {callback = self.beganCallback, connection = self.beganConnection} elseif (type == Enum.UserInputState.End) then {callback = self.endCallback, connection = self.endConnection} else nil

		assert(data.callback, NO_CALLBACK_SET)
		assert(data.connection.Connected, CALLBACK_ALREADY_CONNECTED)

		if (self.timeout) then
			local amount = self.timeout
			local lastPressed = -amount

			self.proximityPrompt.Triggered:Connect(function(player)
				if (os.clock() - lastPressed >= amount) then
					data.callback(player)
				end
			end)
		else
			self.proximityPrompt.Triggered:Connect(data.callback)
		end

		return self
	end
end

return Input