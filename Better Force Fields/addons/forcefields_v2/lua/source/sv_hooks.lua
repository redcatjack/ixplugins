hook.Add("KeyPress", "forcefield_KeyPress", function(player, key)
	local data = {};
	data.start = player:GetShootPos();
	data.endpos = data.start + player:GetAimVector() * 84;
	data.filter = player;
	local trace = util.TraceLine(data);
	local entity = trace.Entity;

	if (key == IN_USE and IsValid(entity) and entity:GetClass() == "z_forcefield") then
		entity:Use(player, player, USE_ON, 1);
	end;
end);

hook.Add("PlayerInitialSpawn", "forcefield_SendUpdate", function(player)
	if (IsValid(player)) then
		local forcefields = ents.FindByClass("z_forcefield");

		if (!forcefields) then return; end;

		local ffCount = table.Count(forcefields);
		local uid = player:Nick();

		timer.Create("forcefield_Queue" .. uid, 1.5, ffCount, function()
			if (!IsValid(player)) then
				timer.Remove("forcefield_Queue" .. uid);

				return;
			end;

			if (IsValid(forcefields[1])) then
				forcefields[1]:SendFullUpdate(player);
				table.remove(forcefields, 1);
			else
				table.remove(forcefields, 1);
			end;
		end);
	end;
end);

netstream.Hook("forcefieldRequest", function(player, operation, toAdd)
	if (IsValid(player:GetNWEntity("ffTarget", nil))) then
		local forcefield = player:GetNWEntity("ffTarget", nil);

		if (type(toAdd) == "Player") then
			if (!IsValid(toAdd)) then
				return;
			end;
		end;

		if (operation == "addPlayer") then
			forcefield:AddPlayer(toAdd);
		elseif (operation == "removePlayer") then
			forcefield:RemovePlayer(toAdd);
		elseif (operation == "addTeam") then
			forcefield:AddTeam(toAdd);
		elseif (operation == "removeTeam") then
			forcefield:RemoveTeam(toAdd);
		elseif (operation == "addContributor") then
			forcefield:AddContributor(toAdd);
		elseif (operation == "removeContributor") then
			forcefield:RemoveContributor(toAdd);
		end;
	end;
end);

netstream.Hook("forcefieldEditorClosed", function(player)
	player:SetNWEntity("ffTarget", nil);
end);