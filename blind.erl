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
		{TargetLevel} -> set_level(TargetLevel), listen()
	end.


level() ->
	[{level, Level}] = ets:lookup(name(), level),
	Level.


set_level(TargetLevel) ->
	ets:insert(name(), {level, TargetLevel}).


% przeslanie stanu zaluzji do glownego watku
send_message_to_main(Pid, Level) ->
	receive
		after 1000 ->
			Pid ! {Level}
	end.


% zmiana stanu zaluzji
move(TargetLevel) ->
	receive
		after 1000 ->
			
			if 
				level > TargetLevel ->   
					level = level - 6;
					
					if 
						level < TargetLevel ->
							level = TargetLevel
					end;
			   
			if
				level < TargetLevel ->
					level = Level + 6;
					
					if 
						level > TargetLevel ->
							level = TargetLevel
					end;
					
			move(TargetLevel)
	
  end.


% glowna funkcja - sprawdzenie i zmiana stanu zaluzji
check_and_move_level(TargetLevel, level) ->
	if 
		TargetLevel == level ->
			io:write("Blinds are currently on that level");
		
		TargetLevel >= 0 -> 
			io:write(""),
			move(TargetLevel);
	
		true ->
			io:fwrite("Enter blind level within the range (0 - 100)")
	end.


