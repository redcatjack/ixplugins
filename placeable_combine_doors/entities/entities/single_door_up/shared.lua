-- Define the door entity
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Single Door - UP"
ENT.Category = "Combine Doors" -- Set the custom category name
ENT.Author = "redcatjack"
ENT.Spawnable = true

-- Initialize the entity
function ENT:Initialize()
    self:SetModel("models/props/redcat/cmbdoors/cmb_door_single.mdl")  -- Set your desired model
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)  -- Prevent physics interactions
    self:SetSolid(SOLID_VPHYSICS)
    self.open = false  -- Track the door state
    self.moving = false  -- Track the door movement state
    self.stopSoundPath = "doors/doormove2.wav"  -- Stop sound path
end

-- Animate the door's movement
function ENT:MoveDoor(up)
    local targetPos
    local moveAmount = self:OBBMaxs().z * 1.8  -- Move 1.8 times the model's height
    if up then
        targetPos = self:GetPos() + Vector(0, 0, moveAmount)
        self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)  -- Allow players to pass through when moving
    else
        targetPos = self:GetPos() - Vector(0, 0, moveAmount)
    end

    -- Smoothly move to the target position
    self.moving = true  -- Set the moving flag
    local startTime = CurTime()
    local duration = 3  -- Duration of the movement in seconds
    local timerName = "DoorMovementTimer_" .. self:EntIndex()
    timer.Create(timerName, 0.01, duration / 0.01, function()
        if not IsValid(self) then
            timer.Remove(timerName)
            self.moving = false  -- Reset the moving flag
            return
        end
        local elapsedTime = CurTime() - startTime
        local lerpFraction = math.min(elapsedTime / duration, 1)
        self:SetPos(LerpVector(lerpFraction, self:GetPos(), targetPos))
        if lerpFraction == 1 then
            timer.Remove(timerName)
            if not up then
                self:SetCollisionGroup(COLLISION_GROUP_NONE)  -- Enable collisions when door is closed
            end
            self.moving = false  -- Reset the moving flag
        end
    end)
end

-- Handle the "Use" key press
function ENT:Use(activator, caller)
    if IsValid(activator) and activator:IsPlayer() and activator:IsCombine() and not self.open and not self.moving then
        self.open = true
        self:EmitSound(self.stopSoundPath)  -- Play stop sound when movement completes
        self:MoveDoor(true)
        timer.Simple(3, function()
            if IsValid(self) then
                self:MoveDoor(false)
                self.open = false
                self:EmitSound(self.stopSoundPath)  -- Play stop sound when movement completes
                self:SetCollisionGroup(COLLISION_GROUP_NONE)  -- Reset collision after closing
            end
        end)
    end
end

-- Register the entity
scripted_ents.Register(ENT, "single_door_up")
