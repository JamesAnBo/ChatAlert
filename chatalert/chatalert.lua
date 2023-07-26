addon.name      = 'chatalert';
addon.author    = 'Aesk';
addon.version   = '1.0';
addon.desc      = 'Alets when keywords are seen in chat.';
addon.link      = 'https://github.com/JamesAnBo/';

require('common');
local chat      = require('chat');

local sound = 'Sound07.wav';

local matching = true;
local primary_words = T{'bastok'}; -- Initial keywords to match from message.
local secondary_words = T{'9-2'}; -- Secondary keywords to match if matching = true.
local p_w;
local s_w;

local name;
local message;

--[[

incoming chat hex/IDs:
0x00 / 9 = /say
0x01 / 10 = /shout
0x26 / 11 = /yell
0x03 / 12 = /tell
0x04 / 13 = /party
0x05 / 14 = /linkshell
0x27 / 214 = /linksehll2
0x08 / 15 = /emote
0x33 / 212 = /unity
0x34 / 220 = /assistj
0x35 / 222 = /assiste

--]]

local function clean_str(str)
    -- Parse the strings auto-translate tags..
    str = AshitaCore:GetChatManager():ParseAutoTranslate(str, true);

    -- Strip FFXI-specific color and translate tags..
    str = str:strip_colors();
    str = str:strip_translate(true);

    return str;
end

local function make_lower(t)
	lst = t;
	
	for k,v in pairs(lst) do
    lst[k] = v:lower()
	end
	
	return lst;

end

local function is_primary(e)
	local msg = clean_str(e.message_modified);
	local k = false;
	local cstm = make_lower(primary_words);
	
	msg = msg:lower();
	
	k, _ = cstm:find_if(function (v, _)
		if (msg:contains(v)) then
			p_w = v;
			return true;
		end
		return false;
	end);
	
	if (k) then
		return true;
    end
	
	return false;
end

local function is_secondary(e)
	local msg = clean_str(e.message_modified);
	local k = false;
	local cstm = make_lower(secondary_words);
	
	msg = msg:lower();
	
	k, _ = cstm:find_if(function (v, _)
		if (msg:contains(v)) then
			s_w = v;
			return true;
		end
		return false;
	end);
	
	if (k) then
		return true;
    end
	
	return false;
end

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if (#args == 0 or (args[1] ~= '/chatalert')) then
        return;
    else
		e.blocked = true;
        local cmd = args[2];
	
		if ((#args == 2) and (cmd:any('match'))) then
			matching = not matching;
			PPrint('Matching is '..tostring(matching));
		end
	end
	
end);

ashita.events.register('packet_in', 'packet_in_cb', function (e)
	su = struct.unpack('b', e.data_modified, 0x04 + 1)
	
	--(su == 0x00 or su == 0x01 or su == 0x26 or su == 0x03 or su == 0x04 or su == 0x05 or su == 0x27)
    -- -- Packet: Chat
    if (e.id == 0x0017 and (su == 0x00 or su == 0x01 or su == 0x26 or su == 0x03 or su == 0x04 or su == 0x05 or su == 0x27)) then
        -- -- Calculate the size of the message from the packet..
        local id_size   = struct.unpack('H', e.data_modified, 0x00 + 0x01);
        local size      = (0x04 * (bit.rshift(id_size, 0x09)) - 0x18) + 0x01;
		local sender    = struct.unpack('c15', e.data_modified, 0x08 + 0x01);
        local msg       = struct.unpack(('c%d'):fmt(size), e.data_modified, 0x17 + 0x01);
		
		
        -- -- Fixups..
        sender  = string.trim(sender);
        msg     = string.trim(msg, '\0');
		
		msg = AshitaCore:GetChatManager():ParseAutoTranslate(msg, true);
		
		-- Returns the sender.
		name = sender
    end
end);

ashita.events.register('text_in', 'text_in_cb', function (e)
    local cm = bit.band(e.mode,  0x000000FF);
	
	if (cm == 9 or cm == 10 or cm == 11 or cm == 12 or cm == 13 or cm == 14 or cm == 214) then
		if (is_primary(e)) then
			if matching == true then
				if (is_secondary(e)) then
					ashita.misc.play_sound(addon.path:append('\\sounds\\'):append(sound));
					PPrint('Message from '..name..' contains ['..p_w..'] & ['..s_w..']');
					return;
				end
			else
				ashita.misc.play_sound(addon.path:append('\\sounds\\'):append(sound));
				PPrint('Message from '..name..' contains ['..p_w..']');
				return;
			end
		end
	end
	
end);

function PPrint(txt)
    print(string.format('[\30\08ChatAlert\30\01] %s', txt));
end