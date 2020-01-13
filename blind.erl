-module(blind).

-define(BLIND_LEVEL, 0).
-define(BLIND_CHANGE, 1).

-export([init/0]).

name() -> 
	list_to_atom("blind" ++ pid_to_list(self())).



init() ->
	ets:new(name(), [set, named_table]),
	ets:insert(name(), {blind_level, 0}),
	timer:send_interval(1000, self(), {move, ok}),
	loop().


loop() -> %main function
	receive
		{shut} -> 
			move(100),
			loop();
		{raise} ->
			move(0),
			loop();
		{getStatus} ->
			io:format(level()),
			loop();
		{Value} ->
			io:format(lists:flatten(io_lib:format("~p",[Value]))),
			move(Value),
			loop();
		{getLevel, PidMain} ->
			Val = ets:lookup(name(), blind_level),
			PidMain ! {blindLevel, Val},
			loop()
	end.


level() ->
	[{level, Level}] = ets:lookup(name(), level),
	Level.


set_level(Target_level) ->
	ets:insert(name(), {level(), Target_level}).


% przeslanie stanu zaluzji do glownego watku
send_message_to_main(Pid, Level) ->
	receive
		
		after 1000 ->
			Pid ! {Level}
	end.


% zmiana stanu zaluzji
move(Target_level) ->
	receive
	after
		100 ->
			[{_, Val}] = ets:lookup(name(), blind_level),
			if
				Val == Target_level ->
					unit;
				Val < Target_level ->
					ets:insert(name(), {blind_level, Val + ?BLIND_CHANGE}),
					move(Target_level);
				true ->
					ets:insert(name(), {blind_level, Val - ?BLIND_CHANGE}),
					move(Target_level)
			end
	end.



