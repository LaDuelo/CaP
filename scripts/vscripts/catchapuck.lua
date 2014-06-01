
if CatchaPuckGameMode == nil then
    CatchaPuckGameMode = {}
    CatchaPuckGameMode.__index = CatchaPuckGameMode
end
function CatchaPuckGameMode:new( o )
  print ( '[CaP] CatchaPuck:new' )
  o = o or {}
  setmetatable( o, CatchaPuckGameMode )
  return o
end
function CatchaPuckGameMode:InitGameMode()
  print('[CaP] Starting to load CatchaPuck gamemode...')

  -- Setup rules
--~   GameRules:SetHeroRespawnEnabled( false )
--~   GameRules:SetUseUniversalShopMode( true )
--~   GameRules:SetSameHeroSelectionEnabled( false )
--~   GameRules:SetHeroSelectionTime( 30.0 )
--~   GameRules:SetPostGameTime( 60.0 )
--~   GameRules:SetTreeRegrowTime( 60.0 )
--~   GameRules:SetUseCustomHeroXPValues ( true )
--~   GameRules:SetGoldPerTick(0)
--~   print('[CaP] Rules set')

  InitLogFile( "log/catchapuck.txt","")
  ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(CatchaPuckGameMode,'ReplaceSkills'), self)
  ListenToGameEvent('player_connect_full', Dynamic_Wrap(CatchaPuckGameMode, 'AssignPlayer'), self)
   Convars:RegisterCommand('fake', function()
    -- Check if the server ran it
    if not Convars:GetCommandClient() or DEBUG then
      -- Create fake Players
      SendToServerConsole('dota_create_fake_clients')

      self:CreateTimer('assign_fakes', {
        endTime = Time(),
        callback = function(reflex, args)
          for i=0, 9 do
            -- Check if this player is a fake one
            if PlayerResource:IsFakeClient(i) then
              -- Grab player instance
              local ply = PlayerResource:GetPlayer(i)
              -- Make sure we actually found a player instance
              if ply then
                CreateHeroForPlayer('npc_dota_hero_axe', ply)
              end
            end
          end
        end})
    end
  end, 'Connects and assigns fake Players.', 0)
  PlayerResource:SetGold(0, 1337, true)

  
  capPlayers = {}
  capRadiant = {}
  capDire = {}
  capConnected = 0
end



function CatchaPuckGameMode:Think()
    -- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
    local now = GameRules:GetGameTime()
    if self.t0 == nil then
        self.t0 = now
    end
    local dt = now - self.t0
    self.t0 = now
end
function CatchaPuckGameMode:ReplaceSkills( keys )
	PrintTable(self)
	local plyID = self.PlayerID
	print(plyID)
	PlayerResource:SetGold(0, 1338, true)
	for k,i in pairs({1,2,3,6,4,5}) do
		local ability = player.hero:FindAbilityByName( 'skeleton_king_hellfire_blast')
		if ability ~= nil then
			print ( '[CaP] Assigning abilities')
			player.hero:RemoveAbility('skeleton_king_hellfire_blast')
			player.hero:AddAbility('cap_wraith_king_stun')
		end
	end
end

function CatchaPuckGameMode:AssignPlayer()
	print ('[CaP] getting index')
	--print(keys.index)
	local entIndex = self.index+1
	local ply = EntIndexToHScript(entIndex)
	local playerID = ply:GetPlayerID()
	capConnected = capConnected + 1
	print(playerID)
	if playerID == -1 then
		if #capRadiant > #capDire then
			print('Setting to bad guys')
			ply:SetTeam(DOTA_TEAM_BADGUYS)
			table.insert(capDire, ply)
		else
			print('Setting to good guys')
			ply:SetTeam(DOTA_TEAM_GOODGUYS)
			table.insert(capRadiant,ply)
		end
	end
end