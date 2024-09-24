local PLUGIN = PLUGIN

function PLUGIN:PlayerUseDoor(client, door)
		if (!door:HasSpawnFlags(256) and !door:HasSpawnFlags(1024)) then
			door:Fire("open")
	end
end