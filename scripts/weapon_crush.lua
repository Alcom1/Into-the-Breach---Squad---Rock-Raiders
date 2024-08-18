--Crush weapon with a charge, pass-through, damage, and pull effect
Weap_RR_Prime_Crush = Skill:new{
    Name = "Chrome Array",
    Description = "Drill to an adjacent tile, then fire a piercing beam.",
    Class = "Brute",
    Icon = "weapons/weapon_crush.png",
    Range = 2,
    Damage = 1,
    PowerCost = 1,
    DamageAnimation = "rock1d",
    DamageSound = "/mech/distance/artillery/death",
    TipImage = {
        Unit = Point(2, 3),
        Enemy = Point(2, 2),
        Target = Point(2, 1)
    }
}

--Target Area for pass-through
function Weap_RR_Prime_Crush:GetTargetArea(p1)
    local ret = PointList()
    for i = DIR_START, DIR_END do                           --For each direction
        for k = 1, self.Range do                            --For each tile in a line
            local point = p1 + DIR_VECTORS[i] * k
            if not Board:IsValid(point) then                --Break when we leave the board
                break
            end

            if not Board:IsBlocked(point, PATH_FLYER) then  --Point is valid if it can be flown to, if it is empty
                ret:push_back(point)
            end
        end
    end

    return ret
end

--Skill Effect for charge, damage, pull, and upgrades
function Weap_RR_Prime_Crush:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local damagePoints = p1:Bresenham(p2, 1, 1)                                 --Points from here to there
    local pullDirection = GetDirection(p1 - p2)                                 --Direction to pull in
    
    --ret:AddAnimation(p1, self.DamageAnimation)                                  --Initial Animation
    ret:AddSound(self.DamageSound)                                              --Initial Drill Sound
    ret:AddCharge(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)                  --Charge!
    
    local ramp = 0

    for i, point in ipairs(damagePoints) do
        if self.FriendlyDamage or not Board:IsPawnTeam(point, TEAM_PLAYER) then --If ally immune, skip damage for allies
            local damage = SpaceDamage(point, self.Damage + ramp)               --Damage
            damage.iPush = pullDirection                                        --Damage pull
            damage.sAnimation = self.DamageAnimation
            damage.sSound = self.DamageSound
            ret:AddDamage(damage)                                               --Damage
            ret:AddBounce(point, 4)                                             --Bounce
        else
            ret:AddDamage(SpaceDamage(point, DAMAGE_ZERO))                      --0 damage for immune allies
        end

        if self.ImpactRamp and Board:IsPawnSpace(point) then                    --If ramp, ramp
            ramp = ramp + 1                                                     --ramp
        end
        
        ret:AddDelay(0.1)                                                       --Delay effects as we travel
    end

    return ret
end