if (SERVER) then
	AddCSLuaFile();
	AddCSLuaFile("source/ponlib.lua");
	AddCSLuaFile("source/nstream.lua");
	include("source/ponlib.lua");
	include("source/nstream.lua");
	

	local files, folders = file.Find("source/*.lua", "LUA");

	for k, file in pairs(files) do
		local prefix = file:sub(1, 3);

		if (prefix == "cl_") then
			AddCSLuaFile("source/" .. file);
		elseif (prefix == "sv_") then
			include("source/" .. file);
		elseif (prefix == "sh_") then
			AddCSLuaFile("source/" .. file);
			include("source/" .. file);
		end;
	end;
else
	include("source/ponlib.lua");
	include("source/nstream.lua");

	local files, folders = file.Find("source/*.lua", "LUA");

	for k, file in pairs(files) do
		local prefix = file:sub(1, 3);

		if (prefix == "cl_" or prefix == "sh_") then
			include("source/" .. file);
		end;
	end;
end;

properties.Add("ffOption", {
	MenuLabel = "Forcefield Type",
	MenuIcon = "icon16/image.png",
	Order = 1,

	Filter = function(self, ent, player)
		if (!IsValid(ent) or ent:GetClass() != "z_forcefield") then return false; end;
		if (!player:IsAdmin()) then return false; end;
		if (SERVER and ent.Owner != player) then return false; end;

		return true;
	end,

	Action = function()
	end,

	SetType = function(self, ent, bUseAlt)
		self:MsgStart();
		net.WriteEntity(ent);
		net.WriteBool(bUseAlt);
		self:MsgEnd();
	end,

	Receive = function(self, length, player)
		local ent = net.ReadEntity();
		local bUseAlt = net.ReadBool();

		if (!self:Filter(ent, player)) then return false; end;

		ent:SetDTBool(1, bUseAlt);
	end,

	MenuOpen = function(self, option, ent, trace)
		local subMenu = option:AddSubMenu();

		local option = subMenu:AddOption("Default", function()
			self:SetType(ent, false);
		end);

		option:SetChecked(!ent:GetDTBool(1));

		local option = subMenu:AddOption("Alternate", function()
			self:SetType(ent, true);
		end);

		option:SetChecked(ent:GetDTBool(1));
	end,
});
