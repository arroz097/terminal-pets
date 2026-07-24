---@class fsm
---@field state string
---@field transitions table
---@field callbacks table
local fsm = {}
fsm.__index = fsm

---@class fsm.connection
---@field _self fsm
---@field _state string
---@field _hook string
local connection = {}
connection.__index = connection

---@param initialState string
---@return fsm
function fsm.new(initialState)
	return setmetatable({
		state = initialState,
		transitions = {},
		callbacks = { enter = {}, exit = {} }
	}, fsm)
end

---@param _self self
---@param state string
---@return fsm.connection
function connection.new(_self, state, hook)
	return setmetatable({
		_self = _self,
		_state = state,
		_hook = hook,
	}, connection)
end

function connection:Disconnect()
	self._self.callbacks[self._hook][self._state] = nil
	self._self = nil
	self._state = nil
	self._hook = nil
end

---@param from string
---@param action string
---@param to string
function fsm:add(from, action, to)
	if not self.transitions[from] then
		self.transitions[from] = {}
	end

	self.transitions[from][action] = to
end

---@param state string
---@param fn function
---@return fsm.connection
function fsm:onEnter(state, fn)
	self.callbacks.enter[state] = fn
	return connection.new(self, state, "enter")
end

---@param state string
---@param fn function
---@return fsm.connection
function fsm:onExit(state, fn)
	self.callbacks.exit[state] = fn
	return connection.new(self, state, "exit")
end

---@param action string
---@return boolean sucess
function fsm:dispatch(action)
	local available = self.transitions[self.state]
	if not available then return false end

	local next = available[action]

	if self.callbacks.exit[self.state] then
		self.callbacks.exit[self.state]()
	end

	if not next then return false end

	self.state = next

	if self.callbacks.enter[next] then
		self.callbacks.enter[next]()
	end

	return true
end

return fsm
