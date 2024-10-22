netstream.Hook("forcefieldMenu", function(forcefield)
	if (FFMenu) then
		FFMenu:Remove();
		FFMenu = nil;
	end;

	FFMenu = vgui.Create("forcefieldMenu");
	FFMenu:Center();
	FFMenu.forcefield = forcefield;
end);

netstream.Hook("forcefieldUpdate", function(operation, data)
	local forcefield = data[1];

	if (operation == "fullUpdate") then
		forcefield.AllowedPlayers = data[2];
		forcefield.AllowedTeams = data[3];
		forcefield.Contributors = data[4];
	elseif (operation == "addPlayer") then
		forcefield.AllowedPlayers = forcefield.AllowedPlayers or {};

		if (!IsValid(data[2])) then return; end;

		forcefield.AllowedPlayers[data[2]] = true;
	elseif (operation == "removePlayer") then
		forcefield.AllowedPlayers = forcefield.AllowedPlayers or {};

		if (!IsValid(data[2])) then return; end;

		forcefield.AllowedPlayers[data[2]] = nil;
	elseif (operation == "addTeam") then
		forcefield.AllowedTeams = forcefield.AllowedTeams or {};

		forcefield.AllowedTeams[data[2]] = true;
	elseif (operation == "removeTeam") then
		forcefield.AllowedTeams = forcefield.AllowedTeams or {};

		forcefield.AllowedTeams[data[2]] = nil;
	elseif (operation == "addContributor") then
		forcefield.Contributors = forcefield.Contributors or {};

		if (!IsValid(data[2])) then return; end;

		forcefield.Contributors[data[2]] = true;
	elseif (operation == "removeContributor") then
		forcefield.Contributors = forcefield.Contributors or {};

		if (!IsValid(data[2])) then return; end;

		forcefield.Contributors[data[2]] = nil;
	end;
end);