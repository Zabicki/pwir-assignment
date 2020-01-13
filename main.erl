-module(main).
-export([init/0]).
-import(c, [flush/0]).
-import(string, [tokens/2]).
-import(lists, [nth/2, member/1]).
-import(maps, [keys/1]).


init() ->
	ServerPid = spawn(server, serverLoop, []),
	B1Pid = spawn(blind, init, []),
	B2Pid = spawn(blind, init, []),
	B3Pid = spawn(blind, init, []),
	Map = #{"server" => ServerPid, "blind1" => B1Pid, "blind2" => B2Pid, "blind3" => B3Pid},
	mainLoop(Map).

print_blind(Map, BlindName) ->
	maps:get(BlindName, Map) ! {getLevel, self()},
	receive
		{blindLevel, [{blind_level, Val}]} ->
			io:format(BlindName),
			io:format(" is on level "),
			io:format(lists:flatten(io_lib:format("~p\n",[Val])))
	end.
	
	

%example command: blind1 shut
parse(Command, Map) ->
	Words = string:tokens(Command, " "),
	Length = length(Words),
	IsBlindInMap = lists:member(lists:nth(1, Words), maps:keys(Map)),
	FirstElem = string:trim(nth(1, Words), trailing, "\n"),
	
	if 
		Length == 1, FirstElem == "exit" ->
			io:format("Exit process"),
			exit(normal);
		Length == 2, IsBlindInMap ->
			BlindName = nth(1, Words),
			Value = nth(2, Words),
			TrimmedValue = string:trim(Value, trailing, "\n"),

			if 
				TrimmedValue == "shut" ->
					{BlindName, TrimmedValue};

				TrimmedValue == "raise" ->
					{BlindName, TrimmedValue};

				true ->
					{BlindName, list_to_integer(TrimmedValue)}
			end;
		true ->
			NewCommand = io:get_line("Invalid input! Insert new command: "),
			parse(NewCommand, Map)
	end.


mainLoop(Map) ->
	io:format(os:cmd(clear)),
	print_blind(Map, "blind1"),
	print_blind(Map, "blind2"),
	print_blind(Map, "blind3"),
	Command = io:get_line("Insert command: "),
	{BlindName, Value} = parse(Command, Map),
	maps:get(BlindName, Map) ! {Value},
	mainLoop(Map).
