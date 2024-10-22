local PLUGIN = PLUGIN;

function Schema:LoadBForceFields()
	for _, v in ipairs(ix.data.Get("betterforceFields") or {}) do
		local entity = ents.Create("z_forcefield")

		entity:SetPos(v.pos)
		entity:SetAngles(v.ang)
		entity.save = v.saveData1
		entity.save2 = v.saveData2
		entity.save3 = v.saveData3
		entity:Spawn()
		entity.AllowedTeams = v.teams
		entity.AllowedPlayers = v.plys
	end
	print("FIELDS LOADED.")
end


function Schema:SaveBForceFields()
	local buffer = {}

	for k, v in pairs(ents.FindByClass("z_forcefield")) do
		print("FIELD FOUND", v:GetPos())
		buffer[#buffer + 1] = {
			pos = v:GetPos(),
			ang = v:GetAngles(),
			mode = v.mode or 1,
			plys = v.AllowedPlayers,
			teams = v.AllowedTeams,
			saveData1 = v.save,
			saveData2 = v.save2,
			saveData3 = v.save3,
		}
	end
	ix.data.Set("betterforceFields", buffer)
	print("FIELDS SAVED")
end