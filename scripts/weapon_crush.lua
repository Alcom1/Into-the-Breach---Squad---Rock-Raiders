--Crush weapon with a charge, pass-through, damage, and pull effect
Weap_RR_Prime_Crush = Skill:new{
    Name = "Chrome Array",
    Description = "Drill to an adjacent tile, then fire a piercing beam.",
    Class = "Brute",
    Icon = "weapons/weapon_crush.png",
    Range = 2,
    Damage = 1,
    PowerCost = 1,
	TwoClick = true,
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

--Target Area for pass-through
function Weap_RR_Prime_Crush:GetSecondTargetArea(p1, p2)
    return Laser_Base:GetTargetArea(p2)
end

--Skill Effect for charge, damage, pull, and upgrades
function Weap_RR_Prime_Crush:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    ret:AddSound(self.DamageSound)                                  --Initial Drill Sound
    ret:AddCharge(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)      --Charge!

    if p1:Manhattan(p2) >= 2 then
        local pullDirection = GetDirection(p1 - p2)                 --Direction to pull in
        local damage = SpaceDamage(
            p1 + DIR_VECTORS[GetDirection(p2 - p1)], 
            self.Damage)                                            --Damage
        damage.iPush = pullDirection                                --Damage pull
        damage.sAnimation = self.DamageAnimation
        damage.sSound = self.DamageSound
        ret:AddDamage(damage)                                       --Damage
    end

    return ret
end

--Skill Effect for charge, damage, pull, and upgrades
function Weap_RR_Prime_Crush:GetFinalEffect(p1, p2, p3)
    local ret = SkillEffect()
    local distance = p1:Manhattan(p2)

    ret:AddSound(self.DamageSound)                                  --Initial Drill Sound
    ret:AddCharge(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)      --Charge!

    if distance >= 2 then
        local pullDirection = GetDirection(p1 - p2)                 --Direction to pull in
        local damage = SpaceDamage(
            p1 + DIR_VECTORS[GetDirection(p2 - p1)], 
            self.Damage)                                            --Damage
        damage.iPush = pullDirection                                --Damage pull
        damage.sAnimation = self.DamageAnimation
        damage.sSound = self.DamageSound
        ret:AddDamage(damage)                                       --Damage
    end

    ret:AddDelay(0.1 * (distance + 1))
    ret:AddSound("/weapons/burst_beam")

    Laser_Base:AddLaser(
        ret,
        p2 + DIR_VECTORS[GetDirection(p3 - p2)],
        GetDirection(p3 - p2))

    return ret
end