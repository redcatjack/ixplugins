local PLUGIN = PLUGIN

function Schema:LoadData()
	self:LoadBForceFields()
end

function Schema:SaveData()
	self:SaveBForceFields()
end