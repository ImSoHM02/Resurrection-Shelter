require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/r_shelter.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

-----------------------------------------------------------------------
--For regular tents

local function PlaySleepLoopSoundTask(inst, stopfn)
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_sleep")
end

local function stopsleepsound(inst)
    if inst.sleep_tasks ~= nil then
        for i, v in ipairs(inst.sleep_tasks) do
            v:Cancel()
        end
        inst.sleep_tasks = nil
    end
end

local function startsleepsound(inst, len)
    stopsleepsound(inst)
    inst.sleep_tasks =
    {
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 33 * FRAMES),
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 47 * FRAMES),
    }
end

-----------------------------------------------------------------------

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        stopsleepsound(inst)
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:PushAnimation("idle", true)
    end
    if inst.components.sleepingbag ~= nil and inst.components.sleepingbag.sleeper ~= nil then
        inst.components.sleepingbag:DoWakeUp()
    end
    TheWorld:PushEvent("ms_sendlightningstrike", Vector3(inst.Transform:GetWorldPosition()))
end

local function onbuilt_shelter(inst)
    inst:AddTag("lightningrod")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/lean_to_craft")
    TheWorld:PushEvent("ms_sendlightningstrike", Vector3(inst.Transform:GetWorldPosition()))
end

local function onfinishedsound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_twirl")
end

local function onfinished(inst)
    inst.AnimState:PlayAnimation("trash")
    local smoke = SpawnPrefab("maxwell_smoke")
    local pos = inst:GetPosition()
    smoke.Transform:SetPosition(pos.x, pos.y, pos.z)
    smoke.Transform:SetScale(3,5,3)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    inst:ListenForEvent("animover", inst.Remove)
    inst:DoTaskInTime(16 * FRAMES)
    inst.persists = false
end

local function onignite(inst)
    inst.components.sleepingbag:DoWakeUp()
end

local function wakeuptest(inst, phase)
    if phase ~= inst.sleep_phase then
        inst.components.sleepingbag:DoWakeUp()
    end
end

local function onwake(inst, sleeper, nostatechange)
    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
        inst.sleeptask = nil
    end

    inst:StopWatchingWorldState("phase", wakeuptest)
    sleeper:RemoveEventCallback("onignite", onignite, inst)

    if not nostatechange then
        if sleeper.sg:HasStateTag("tent") then
            sleeper.sg.statemem.iswaking = true
        end
        sleeper.sg:GoToState("wakeup")
    end

    if inst.sleep_anim ~= nil then
        inst.AnimState:PushAnimation("idle", true)
        stopsleepsound(inst)
    end

    inst.components.finiteuses:Use()
end

local function onsleeptick(inst, sleeper)
    local isstarving = sleeper.components.beaverness ~= nil and sleeper.components.beaverness:IsStarving()

    if sleeper.components.hunger ~= nil then
        sleeper.components.hunger:DoDelta(inst.hunger_tick, true, true)
        isstarving = sleeper.components.hunger:IsStarving()
    end

    if sleeper.components.sanity ~= nil and sleeper.components.sanity:GetPercentWithPenalty() < 1 then
        sleeper.components.sanity:DoDelta(inst.sanity_tick, true)
    end

    if not isstarving and sleeper.components.health ~= nil then
        sleeper.components.health:DoDelta(inst.health_tick * 2, true, inst.prefab, true)
    end

    if sleeper.components.temperature ~= nil then
        if inst.is_cooling then
            if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
            end
        elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
        end
    end

    if isstarving then
        inst.components.sleepingbag:DoWakeUp()
    end
end

local function onsleep(inst, sleeper)
    inst:WatchWorldState("phase", wakeuptest)
    sleeper:ListenForEvent("onignite", onignite, inst)

    if inst.sleep_anim ~= nil then
        inst.AnimState:PlayAnimation(inst.sleep_anim, true)
        startsleepsound(inst, inst.AnimState:GetCurrentAnimationLength())
    end

    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
    end
    inst.sleeptask = inst:DoPeriodicTask(TUNING.SLEEP_TICK_PERIOD, onsleeptick, nil, sleeper)
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function OnHaunt(inst, haunter)
    inst.components.finiteuses:Use()
    return true
end

local function common_fn(bank, build, icon, tag, onbuiltfn)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, 1.4)

    inst:AddTag("shelter")
    inst:AddTag("tent")
    inst:AddTag("resurrector")
    if tag ~= nil then
        inst:AddTag(tag)
    end

    inst.AnimState:SetBank("r_shelter")
    inst.AnimState:SetBuild("r_shelter")
    inst.AnimState:PlayAnimation("idle", true)

    inst.MiniMapEntity:SetIcon("r_shelter.tex")

    inst.entity:AddLight()
    inst.Light:Enable(false)
    inst.Light:SetColour(223/255, 208/255, 69/255)
    inst.Light:SetRadius(3)
    inst.Light:SetFalloff(4)
    inst.Light:SetIntensity(.5)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

	inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(ShelterUses)
    inst.components.finiteuses:SetUses(ShelterUses)
    inst.components.finiteuses:SetOnFinished(onfinished)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst:AddComponent("sleepingbag")
    inst.components.sleepingbag.onsleep = onsleep
    inst.components.sleepingbag.onwake = onwake
    --convert wetness delta to drying rate
    inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)

    MakeSnowCovered(inst)
    inst:ListenForEvent("onbuilt", onbuiltfn)

    MakeLargeBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)

    inst.OnSave = onsave 
    inst.OnLoad = onload

    inst:DoPeriodicTask(1, function(inst)
    if ShelterLight and TheWorld.state.isnight 
    then
    inst.Light:Enable(true)    
    else
    inst.Light:Enable(false)
    end
end)

	return inst
end

local function r_shelter()
    local inst = common_fn("r_shelter", "r_shelter", "r_shelter.tex", "siestahut", onbuilt_shelter)
                        --(bank,            build,      icon,     note-> tag,       onbuiltfn)
                        --Note: Somehow Tag plays into the phase check in addition to the inst.sleep_phase.
    if not TheWorld.ismastersim then
        return inst
    end

    inst.sleep_phase = "day"
    --inst.sleep_anim = nil
    inst.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK
    inst.sanity_tick = TUNING.SLEEP_SANITY_PER_TICK
    inst.health_tick = TUNING.SLEEP_HEALTH_PER_TICK
    inst.is_cooling = true

    inst.components.finiteuses:SetMaxUses(TUNING.SIESTA_CANOPY_USES)
    inst.components.finiteuses:SetUses(TUNING.SIESTA_CANOPY_USES)
    --Config Settings Tranfer to Constructed Tipi
    if ShelterUses == 5 then
        inst.components.finiteuses:SetMaxUses(5)
        inst.components.finiteuses:SetUses(5)
    elseif ShelterUses == 10 then
        inst.components.finiteuses:SetMaxUses(10)
        inst.components.finiteuses:SetUses(10)
    elseif ShelterUses == 20 then
        inst.components.finiteuses:SetMaxUses(20)
        inst.components.finiteuses:SetUses(20)
    elseif ShelterUses == 1000000 then
        inst.components.finiteuses:SetMaxUses(1000000)
        inst.components.finiteuses:SetUses(1000000)
    end

    if ShelterSanity == 1 then
        inst.sanity_tick = inst.sanity_tick * 1
    elseif ShelterSanity == 2 then
        inst.sanity_tick = inst.sanity_tick * 2
    elseif ShelterSanity == 3 then
        inst.sanity_tick = inst.sanity_tick * 3
    end

    if ShelterHunger == 1 then
        inst.hunger_tick = inst.hunger_tick * 1
    elseif ShelterHunger == 2 then
        inst.hunger_tick = inst.hunger_tick * 2
    elseif ShelterHunger == 3 then
        inst.hunger_tick = inst.hunger_tick * 3
    end

    if ShelterHealth == 1 then
        inst.health_tick = inst.health_tick * 1
    elseif ShelterHealth == 2 then
        inst.health_tick = inst.health_tick * 2
    elseif ShelterHealth == 3 then
        inst.health_tick = inst.health_tick * 3
    end

    return inst
end

return Prefab( "common/r_shelter", r_shelter, assets),
	MakePlacer( "common/r_shelter_placer", "r_shelter", "r_shelter", "idle" ) 
