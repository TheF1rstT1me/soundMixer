export type SoundsA = {
	new: (Folder) -> SoundsA,
	
	SoundsFolder: Folder,
	SoundsMixer: {string:Sound},
	
	CreateASoundMixer: (SoundsA, MixerName: string) -> (),
	StopASoundMixer: (SoundsA, MixerName: string) -> (),
	PlaySound: (SoundsA, MixerName: string, SoundName: string, Required: boolean) -> (),
	
	Destroy: (SoundsA) -> ()
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RF = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local plrGui = plr.PlayerGui

local SoundsA = {}
SoundsA.ClassName = "SoundMixer"
SoundsA.__index = SoundsA

function FadeOutSound(sound: Sound)
	local transitiontime = 1

	local tween = TweenService:Create(sound, TweenInfo.new(transitiontime), {Volume = 0})
	tween:Play()

	tween.Completed:Wait()
end

function FadeIn(sound: Sound)
	local LastVolume = sound.Volume
	sound.Volume = 0
	
	local transitiontime = 0.2

	local tween = TweenService:Create(sound, TweenInfo.new(transitiontime), {Volume = LastVolume})
	tween:Play()
	sound:Play()
	
	tween.Completed:Wait()
end

function SoundsA:_GetSound(nameSound: string)
	local self: SoundsA = self
	
	local sound = self.SoundsFolder:FindFirstChild(nameSound)
	
	if sound then
		return sound
	else
		warn("[SoundClassMixer] Sound "..nameSound.." has not been found!")
		return false
	end
	
end

function SoundsA.new(SoundsFolder: Folder)
	local self: SoundsA = setmetatable({}, SoundsA)
	
	self.SoundMixerFree = Instance.new("BindableEvent")
	
	self.SoundsFolder = SoundsFolder
	self.SoundsMixer = {}
	
	return self
end

function SoundsA:CreateASoundMixer(SoundMixerName: string)
	local self: SoundsA = self
	
	if self.SoundsMixer[SoundMixerName] then warn("[SoundClassMixer] Mixer "..SoundMixerName.." has been founded!") return end;
	self.SoundsMixer[SoundMixerName] = false
	
	print("[SoundClassMixer] Mixer "..SoundMixerName.." has been created!")
end

function SoundsA:StopASoundMixer(SoundMixerName: string)
	local self: SoundsA = self

	if not self.SoundsMixer[SoundMixerName] then 
		self.SoundsMixer[SoundMixerName] = nil 
		warn("[SoundClassMixer] Mixer "..SoundMixerName.." has been deleted!") 
		return 
	end;
	
	if self.SoundsMixer[SoundMixerName].TimeLength - self.SoundsMixer[SoundMixerName].TimePosition <= 1 then
		self.SoundsMixer[SoundMixerName]:Stop()
		self.SoundsMixer[SoundMixerName] = nil
	else
		FadeOutSound(self.SoundsMixer[SoundMixerName])
		self.SoundsMixer[SoundMixerName]:Stop()
		self.SoundsMixer[SoundMixerName] = nil
	end
	

	print("[SoundClassMixer] Mixer "..SoundMixerName.." has been stopped and deleted!")
end

function SoundsA:PlaySound(SoundMixerName: string, SoundName: string, required: boolean)
	local self: SoundsA = self
	
	local sound: Sound = self:_GetSound(SoundName)
	if not sound then return end;
	
	if self.SoundsMixer[SoundMixerName] == false then
		
		self.SoundsMixer[SoundMixerName] = sound
		FadeIn(sound)
		
		if not sound.Looped then
			
			sound.Ended:Once(function(soundId: string) 
				self.SoundsMixer[SoundMixerName] = false
				self.SoundMixerFree:Fire(SoundMixerName)
			end)
			
		end
	else
		if self.SoundsMixer[SoundMixerName] and required then
			
			if self.SoundsMixer[SoundMixerName].TimeLength - self.SoundsMixer[SoundMixerName].TimePosition <= 1 then
				self.SoundsMixer[SoundMixerName]:Stop()
			else
				FadeOutSound(self.SoundsMixer[SoundMixerName])
				self.SoundsMixer[SoundMixerName]:Stop()
			end	
			
			self.SoundMixerFree:Fire(SoundMixerName)
			
			self.SoundsMixer[SoundMixerName] = sound
			FadeIn(sound)

			if not sound.Looped then

				sound.Ended:Once(function(soundId: string) 
					self.SoundsMixer[SoundMixerName] = false
					self.SoundMixerFree:Fire(SoundMixerName)
				end)

			end
			
		end
	end
	
end

function SoundsA:Destroy()
	local self = setmetatable(self, nil)
end

return SoundsA
