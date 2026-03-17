local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-Modpack_Lib'].public

config = chalk.auto('config.lua')
public.config = config

local backup, restore = lib.createBackupSystem()

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "FamiliarDelayFix",
    name     = "Familiar Delay Fix",
    category = "BugFixes",
    group    = "NPC & Encounters",
    tooltip  = "Fixes Familiars being summoned after a delay upon entering a room.",
    default  = true,
    dataMutation = true,
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function apply()
    local unblocked = RoomEventData.GlobalRoomInputUnblockedEvents
    for _, event in ipairs(unblocked) do
        if event.FunctionName == "FamiliarSetup" then
            backup(event, "Args")
            event.Args = {}
            break
        end
    end
end

local function registerHooks()
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.enable = apply
public.definition.disable = restore

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if config.Enabled then apply() end
        if public.definition.dataMutation and not mods['adamant-Core'] then
            SetupRunData()
        end
    end)
end)

lib.standaloneUI(public.definition, config, apply, restore)
