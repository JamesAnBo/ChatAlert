addon.name      = 'chatalert';
addon.author    = 'Aesk';
addon.version   = '2.0';
addon.desc      = 'Alets when keywords are seen in chat.';
addon.link      = 'https://github.com/JamesAnBo/ChatAlert';

require('common');
local chat = require('chat');

local sound = 'Sound07.wav';

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
	
	return lst;

end

local function is_primary(e)
	local msg = clean_str(e.message_modified);
	local k = false;
	local cstm = make_lower(primary_terms);
	
	msg = msg:lower();
	
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

		if index <= count then
			return col[index]
		end
	end
end

local function list_primary()
	PPrint('~Primary terms:');
	for k,v in ipairs(primary_terms) do
		PPrint(k..') '..v);
	end
end

local function list_secondary()
	PPrint(' ');
	PPrint('~Secondary terms:');
	for k,v in ipairs(secondary_terms) do
		PPrint(k..') '..v);
	end
end

local function list_ignored()
	PPrint(' ');
	PPrint('~Ignored terms:');
	for k,v in ipairs(ignored_terms) do
		PPrint(k..') '..v);
	end
end

local function print_help()

PPrint('/ca add1 <term> - add a primary term. (not case sensative, can include spaces)');
PPrint('/ca add2 <term> - add a secondary term. (not case sensative, can include spaces)');
PPrint('/ca ignore <term> - add a term to be ignored. (not case sensative, can include spaces)');
PPrint('/ca list - list all terms.');
PPrint('/ca clear all - clear all terms.');
PPrint('/ca clear primary - clear primary terms.');
PPrint('/ca clear secondary - clear secondary terms.');
PPrint('/ca help - print help.');

end

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if (#args == 0 or (args[1] ~= '/chatalert' and args[1] ~= '/ca')) then
        return;
    else
		e.blocked = true;
        local cmd = args[2];
	
		if (#args == 2) then
			if (cmd:any('help')) then
				print_help()
			elseif (cmd:any('list')) then
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
			end
		elseif (#args >= 3) then
			if (cmd:any('clear','reset')) then
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
	-- Say, Shout, Yell, Tell, Party, Linkshell1, Linkshell2
	if (cm == 9 or cm == 10 or cm == 11 or cm == 12 or cm == 13 or cm == 14 or cm == 214) then
		if (is_ignored(e)) then
			return;
		elseif (is_primary(e)) then
			if (#secondary_terms > 0) then
				if (is_secondary(e)) then
					ashita.misc.play_sound(addon.path:append('\\sounds\\'):append(sound));
					PPrint('Message contains ['..p_t..'] & ['..s_t..']');
					return;
				end
			else
				ashita.misc.play_sound(addon.path:append('\\sounds\\'):append(sound));
				PPrint('Message contains ['..p_t..']');
				return;
			end
		end
	end
	
end);

function PPrint(txt)
    print(string.format('[\30\08ChatAlert\30\01] %s', txt));
end
