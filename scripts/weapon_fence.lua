--Science weapon that deploys a fence spawn.
Weap_RR_Science_Deploy_Fence = Weap_RR_Base_Transporter:new{
    Name = "Electric Fence",
    Description = "Teleport in a stationary electric fence that deals chain damage through adjacent targets.",
    Class = "Science",
    Icon = "weapons/weapon_fence.png",
    Deployed = "pawn_spawn_fence",
    PowerCost = 1,
    Upgrades = 2,
    UpgradeCost = { 2, 3 },
    UpgradeList = { "+1 Damage", "+1 Damage" },
    Limited = 2,
    TipImage = {
        Unit = Point(2,4),
        Target = Point(2,2),
        Enemy = Point(1,1),
        Enemy2 = Point(2,1),
        Enemy3 = Point(3,1),
        Second_Origin = Point(2,2),
        Second_Target = Point(2,1),
    },
}

--More zappy damage
Weap_RR_Science_Deploy_Fence_A = Weap_RR_Science_Deploy_Fence:new{
    UpgradeDescription = "Increases the Electric Fence's attack damage by 1.",
    Deployed = "pawn_spawn_fence2"
}

--More zappy damage (for less!)
Weap_RR_Science_Deploy_Fence_B = Weap_RR_Science_Deploy_Fence:new{
    UpgradeDescription = "Increases the Electric Fence's attack damage by 1.",
    Deployed = "pawn_spawn_fence2"
}

--Even more zappy damage!
Weap_RR_Science_Deploy_Fence_AB = Weap_RR_Science_Deploy_Fence:new{
    Deployed = "pawn_spawn_fence3"
}

--Generic weapon used by Electric Fence spawn
Weap_RR_Spawn_Lightning = Skill:new{
    LaunchSound = "/weapons/electric_whip",
    Icon = "weapons/prime_lightning.png",
	PathSize = 1,
    Damage = 1
}

--Electric Fence with damage upgrade
Weap_RR_Spawn_Lightning2 = Weap_RR_Spawn_Lightning:new{
    Damage = 2
}

--Electric Fence with damage upgrade
Weap_RR_Spawn_Lightning3 = Weap_RR_Spawn_Lightning:new{
    Damage = 3
}

--Skill Effect for lightning attack
function Weap_RR_Spawn_Lightning:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    if not Board:IsPawnSpace(p2) then return ret end                        -- Don't attack empty spaces

    local hash = function(point) return point.x + point.y * 8 end           -- Hash Point into an int for indexing
    local past = { [hash(p1)] = true }                                      -- We're not Pichu

    function RR_RecurseLightning(prev, curr, ret)
        past[hash(curr)] = true                                             -- Mark tile as past

        local damage = SpaceDamage(curr, self.Damage)                       -- Damage adjacent tiles
        damage.sAnimation = "Lightning_Blue_"..GetDirection(curr - prev)    -- Damage
        ret:AddDamage(damage)                                               -- Damage

        for dir = DIR_START, DIR_END do                                     -- Loop through adjacent tiles
            local next = curr + DIR_VECTORS[dir]                            -- Adjacent tile Point
            if not past[hash(next)] and Board:IsPawnSpace(next) then        -- If tile is not past and has a pawn then
                ret = RR_RecurseLightning(curr, next, ret)                     -- Recurse to adjacent tiles
            end
        end
        
        return ret
    end
    
    ret = RR_RecurseLightning(p1, p2, ret)                                     -- Start recursion
    return ret
end