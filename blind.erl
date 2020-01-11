-module(blind).

-define(BLIND_LEVEL, 0).

-export([init/0]).

name() -> 
	list_to_atom("blind" ++ pid_to_list(self())).



init() ->
	ets:new(name(), [set, named_table]),
	ets:insert(name(), {blind_level, 0}),
	timer:send_interval(1000, self(), {move, ok}),
	listen().


listen() ->
	receive
		{target_level} -> set_level(target_level), listen()
	end.


level() ->
	[{level, Level}] = ets:lookup(name(), level),
	Level.


set_level(target_level) ->
	ets:insert(name(), {level, target_level}).


% przeslanie stanu zaluzji do glownego watku
send_message_to_main(Pid, Level) ->
	receive
		
		after 1000 ->
			Pid ! {Level}
	end.


% zmiana stanu zaluzji
move(target_level) ->
	receive
		after 1000 ->
			io:write("")
		% to do 
	end.


% glowna funkcja - sprawdzenie i zmiana stanu zaluzji
check_and_move_level(target_level, Level) ->
	if 
		target_level == Level ->
			io:write("Blinds are currently on that level");
		
		target_level >= 0 -> 
			io:write(""),
			move(target_level);
	
		true ->
			io:fwrite("Enter blind level within the range (0 - 100)")
	end.


