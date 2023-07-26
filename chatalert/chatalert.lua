addon.name      = 'chatalert';
addon.author    = 'Aesk';
addon.version   = '2.2';
addon.desc      = 'Alets when keywords are seen in chat.';
addon.link      = 'https://github.com/JamesAnBo/ChatAlert/';

require('common');
local chat = require('chat');

local sound = 'Sound07.wav'; -- Default alert sound..
local playsound = true; -- Default play alert sound..
local messages = true; -- Default show addon meesages..

local primary_terms = T{};
local secondary_terms = T{};
local ignored_terms = T{};
local p_t;
local s_t;

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
	
	-- Return table in lower case..
	return lst;

end

local function IsNum(str)

	-- Return true if str is a number..
	return not (str == "" or str:find("%D"))
	
end

local function is_primary(e)

	local msg = clean_str(e.message_modified);
	local k = false;
	local cstm = make_lower(primary_terms);
	
	msg = msg:lower();
	
	-- Return true if message contains a primary term..
	k, _ = cstm:find_if(function (v, _)
		if (msg:contains(v)) then
			p_t = v;
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
	local cstm = make_lower(secondary_terms);
	
	msg = msg:lower();
	
	-- Return true if message contains a secondary term..
	k, _ = cstm:find_if(function (v, _)
		if (msg:contains(v)) then
			s_t = v;
			return true;
		end
		return false;
	end);
	
	if (k) then
		return true;
    end
	
	return false;
	
end

local function is_ignored(e)

	local msg = clean_str(e.message_modified);
	local k = false;
	local cstm = make_lower(ignored_terms);
	
	msg = msg:lower();
	
	-- Return true if message contains an ignored term..
	k, _ = cstm:find_if(function (v, _)
		if (msg:contains(v)) then
			s_t = v;
			return true;
		end
		return false;
	end);
	
	if (k) then
		return true;
    end
	
	return false;
	
end

local function args_iterator (col)

	local index = 2
	local count = #col
	
	return function ()
		index = index + 1
		
		-- Returns args[3+] for concat..
		if index <= count then
			return col[index]
		end
	end
	
end

local function list_primary()

	PPrint('Primary terms:');
	for k,v in ipairs(primary_terms) do
		PPrint('- '..v);
	end
	
end

local function list_secondary()

	PPrint(' ');
	PPrint('Secondary terms:');
	for k,v in ipairs(secondary_terms) do
		PPrint('- '..v);
	end
	
end

local function list_ignored()

	PPrint(' ');
	PPrint('Ignored terms:');
	for k,v in ipairs(ignored_terms) do
		PPrint('- '..v);
	end
	
end

local function print_help()

	print(chat.header(addon.name):append(chat.message('Available commands:')));

	local cmds = T{
		{'/ca add1 <term>', 'add a primary term. (not case sensative, can include spaces)'},
		{'/ca add2 <term>', 'add a secondary term. (not case sensative, can include spaces)'},
		{'/ca ignore <term>', 'add a term to be ignored. (not case sensative, can include spaces)'},
		{'/ca list', 'list all terms.'},
		{'/ca clear all', 'clear all terms.'},
		{'/ca clear primary', 'clear primary terms.'},
		{'/ca clear secondary', 'clear secondary terms.'},
		{'/ca clear ignored', 'clear ignored terms.'},
		{'/ca msg', 'toggle addon messages.'},
		{'/ca alert <1-7>', 'change the alert sound.'},
		{'/ca help', 'print help.'},
	};

    -- Print the command list..
    cmds:ieach(function (v)
        print(chat.header(addon.name):append(chat.error('Usage: ')):append(chat.message(v[1]):append(' - ')):append(chat.color1(6, v[2])));
    end);

end

ashita.events.register('command', 'command_cb', function (e)

    local args = e.command:args();
	
    if (#args == 0 or (args[1] ~= '/chatalert' and args[1] ~= '/ca')) then
        return;
    else
		e.blocked = true;
        local cmd = args[2];
	
		if (cmd:any('help')) then
		
			-- Print help..
			print_help()
			
		elseif (cmd:any('message', 'msg')) then
		
			-- Toggle addon messages on/off
			messages = not messages
			PPrint('Messages changed to '..tostring(messages));
			
		elseif (cmd:any('list')) then
		
			-- Print a list of defined terms..
			if (#primary_terms > 0) then
				list_primary();
			end
			if (#secondary_terms > 0) then
				list_secondary();
			end
			if (#ignored_terms > 0) then
				list_ignored()
			end
			if (#primary_terms == 0) and (#secondary_terms == 0) and (#ignored_terms == 0) then
				PPrint('No terms found.');
			end
			
		elseif (cmd:any('sound', 'alert')) then
			-- Toggle the alert sound on/off..
			if (#args == 2) or (args[3] == nil) then
				playsound = not playsound;
				PPrint('Alert is '..tostring(playsound));
				
			-- Change the alert sound..
			elseif IsNum(args[3]) then
				local num = tonumber(args[3])
				if (num <= 0) or (num > 7) then
					PPrint('Choose alert 1-7.');
				else
					sound = ('Sound0'..args[3]..'.wav')
					PPrint('Alert changed to '..args[3]);
				end
				
			end
				
		elseif (#args >= 3) then
			if (cmd:any('clear','reset')) then
			
				-- Clear all, or defined, list..
				if (args[3]:any('all')) then
					primary_terms = T{};
					secondary_terms = T{};
					PPrint('Clearing all terms.');
				elseif (args[3]:any('1', 'first', 'prime', 'primary')) then
					primary_terms = T{};
					PPrint('Clearing primary terms.');
				elseif (args[3]:any('2', 'second','secondary')) then
					secondary_terms = T{};
					PPrint('Clearing secondary terms.');
				elseif (args[3]:any('ignore', 'ignored')) then
					ignored_terms = T{};
					PPrint('Clearing ignored terms.');
				end
			elseif (cmd:any('add1', 'addp', 'primary', 'addprimary')) then
			
				-- Define a primary term..
				local tbl = T{};
				
				for k in args_iterator(args) do
					table.insert(tbl, k);
				end
				local str = string.format("%s", table.concat(tbl, ' '));
				str = string.lower(str)
				if primary_terms:contains(str) then
					PPrint('"'..str..'" already in primary terms.');
					return
				else
					PPrint('"'..str..'" added to primary terms.');
					table.insert(primary_terms, str);
				end
				
			elseif (cmd:any('add2', 'adds', 'secondary', 'addsecondary')) then
			
				-- Define a secondary term..
				local tbl = T{};
				for k in args_iterator(args) do
					table.insert(tbl, k);
				end
				local str = string.format("%s", table.concat(tbl, ' '));
				str = string.lower(str)
				if secondary_terms:contains(str) then
					PPrint('"'..str..'" already in secondary terms.');
					return
				else
					PPrint('"'..str..'" added to secondary terms.');
					table.insert(secondary_terms, str);
				end
				
			elseif (cmd:any('ignore', 'addi', 'addignore')) then
			
				-- Define an ignored term..
				local tbl = T{};
				for k in args_iterator(args) do
					table.insert(tbl, k);
				end
				local str = string.format("%s", table.concat(tbl, ' '));
				str = string.lower(str)
				if ignored_terms:contains(str) then
					PPrint('"'..str..'" already in ignored terms.');
					return
				else
					PPrint('"'..str..'" added to ignored terms.');
					table.insert(ignored_terms, str);
				end
				
			end
			
		end
		
	end
	
end);

ashita.events.register('text_in', 'text_in_cb', function (e)
	
    local cm = bit.band(e.mode,  0x000000FF);
	
	-- Get incoming chat messages..
	
	--[[

	incoming chat IDs:
	9 = /say
	10 = /shout
	11 = /yell
	12 = /tell
	13 = /party
	14 = /linkshell
	214 = /linksehll2
	15 = /emote
	212 = /unity
	220 = /assistj
	222 = /assiste

	]]--
	
	local channels = T{9, 10, 11, 12, 13, 14, 214};
	
	-- Search Say, Shout, Yell, Tell, Party, Linkshell1, and Linkshell2 for terms..
	if (channels:contains(cm)) then
		if (is_ignored(e)) then
			return;
		elseif (is_primary(e)) then
			if (#secondary_terms > 0) then
				if (is_secondary(e)) then
				
					if playsound == true then
						ashita.misc.play_sound(addon.path:append('\\sounds\\'):append(sound));
					end
					
					if messages == true then
						PPrint('Message contains ['..p_t..'] & ['..s_t..']');
					end
					
					return;
				end
			else
			
				if playsound == true then
					ashita.misc.play_sound(addon.path:append('\\sounds\\'):append(sound));
				end
				
				if messages == true then
					PPrint('Message contains ['..p_t..']');
				end
				
				return;
			end
		end
	end
	
end);

function PPrint(txt)

	print(chat.header(addon.name):append(chat.message(txt)));
	
end