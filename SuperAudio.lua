----------------------------------------------------------
-- Abstract: 	SuperAudio - Extends the built-in audio 
--				class to provide pan and pitch capabilities.
----------------------------------------------------------
-- SuperAudio
-- Version: 1.0
-- 
-- Sample code is MIT licensed
-- Copyright (C) 2012 Mike Gieson. All Rights Reserved.

----------------------------------------------------------
-- USAGE
----------------------------------------------------------
-- Include this file at the top of your "main.lau" file as:
-- require("SuperAudio")

-- When playing a file, you'll need to capture the "source" 
-- using the secret undocumented technique of:

-- local myTrack = audio.load("path/to/file/mp3")
-- local myChannel, mySource = audio.play(myTrack)

----------------------------------------------------------
-- IMPORTANT
----------------------------------------------------------
-- Pan adjustments can only happen on "mono" audio sources. 
-- Stereo files can NOT be panned.

----------------------------------------------------------
-- NOTE
----------------------------------------------------------
-- The Corona audio classs must be "touched" efore any of 
-- the al.FOO calls can be made. We're "touching" the audio 
-- class via audio.totalChannels above.

local totalChannels = audio.totalChannels
local MATH_PI_180 = math.pi / 180

-- Ensure correct distance model is being used.
al.DistanceModel(al.INVERSE_DISTANCE_CLAMPED)

al.Listener(al.POSITION, 0, 0, 0)
al.Listener(al.ORIENTATION, 0, 1, 0, 0, 0, 1)

local old_play = audio.play

audio.play = function( handle, params )
	local ch, src = old_play(handle, params)
	-- Need to set the rolloff, distance and max distance 
	-- so that we pan "inside" of AL_REFERENCE_DISTANCE 
	-- where the volume is at AL_MAX_GAIN.
	al.Source( src, al.ROLLOFF_FACTOR, 1 )
	al.Source( src, al.REFERENCE_DISTANCE, 2 )
	al.Source( src, al.MAX_DISTANCE, 4 )
	return ch, src
end

audio.pan = function(src, val)

	-- Pan curves the souce "around" the Z axis, 
	-- at a radius of 1 "unit".
	
	-- Another way to think about this is:
	
	-- The Z axis is the pivot point and the X and Y values 
	-- are adjusted to move in a circle "around" that point. 
	-- (Actually, a half-circle)
	
	--[[
	                      | Y
	                      |
	                      |
	                      -  1
	                      |
	                      |
	                      |
	        -1                           1          X
	---------|----------  Z  ------------|-----------
	         .          	             .		 
	         .            |              .
	          .           |             .
	            .         |            .
		           .      |          .
	                   .  - -1   .
	                      |
	                      |
	                      |          ASCII ART ROCKS!
	--]]
	
	
	
	
	-- In this formula, we're moving in 
	-- a half-circle "below" the listener.
	
	-- WAY SLOWER: 
	-- val = math.max(-1, math.min(1, val))
	
	-- WAY FASTER:
	if val < -1 then
		val = -1
	end
	if val > 1 then
		val = 1
	end
	local radi = (-90 + ((1 + val) * -90)) * MATH_PI_180
	al.Source(src, al.POSITION, math.sin(radi), math.cos(radi), 0)
	
end

audio.pitch = function(src, val)
	if val < 0.01 then
		val = 0.01
	end
	if val > 8 then
		val = 8
	end
	al.Source(src, al.PITCH, val)
end



