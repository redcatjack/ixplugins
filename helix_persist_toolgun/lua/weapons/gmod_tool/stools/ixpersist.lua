--[[
    Created by redcatjack
    https://github.com/redcatjack
--]]

if CLIENT then
	TOOL.Information = {
        { name = "info", stage = 1 },
		{ name = "left" },
		{ name = "right" },
	}
    language.Add( "tool.ixpersist.left", "Make an entity persistent" )
	language.Add( "tool.ixpersist.right", "Remove persistence from entity" )
    language.Add( "tool.ixpersist.name", "Helix Persistance Tool" )
    language.Add( "tool.ixpersist.desc", "Make entities persist through restarts" )
end

TOOL.Category = "Helix"
TOOL.Name = "#tool.ixpersist.name"
TOOL.Description = "#tool.ixpersist.desc"

if SERVER then
    util.AddNetworkString("PersistenceTool_Persist")
    util.AddNetworkString("PersistenceTool_Unpersist")

    net.Receive("PersistenceTool_Persist", function(len, ply)
        local entity = net.ReadEntity()
        if not IsValid(entity) then return end

        entity:SetPersistent(true) -- Custom function to make entity persistent
        print(ply:Nick() .. " has made " .. entity:GetClass() .. " persistent.")
        ply:Notify("Enabled persist for ".. entity:GetClass())
    end)

    net.Receive("PersistenceTool_Unpersist", function(len, ply)
        local entity = net.ReadEntity()
        if not IsValid(entity) then return end

        entity:SetPersistent(false) -- Custom function to remove persistence
        print(ply:Nick() .. " has removed persistence from " .. entity:GetClass() .. ".")
        ply:Notify("Removed persist for ".. entity:GetClass())
    end)
end

function TOOL:LeftClick(trace)
    if CLIENT then
        local entity = trace.Entity
        if not IsValid(entity) then return false end

        net.Start("PersistenceTool_Persist")
        net.WriteEntity(entity)
        net.SendToServer()

        return true
    end
end

function TOOL:RightClick(trace)
    if CLIENT then
        local entity = trace.Entity
        if not IsValid(entity) then return false end

        net.Start("PersistenceTool_Unpersist")
        net.WriteEntity(entity)
        net.SendToServer()

        return true
    end
end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", {Description = "#tool.ixpersist.desc"})
end
