-module(calling).

-export([start/2,while/3,while/4]).
-import(exchange,[mlisten/0]).

while(Send,Recs,Id) -> 
	while(Send,Recs,Id,0).
while(Send,[],Id,0) ->
	ok;
while(Send,[H|T],Id,0) ->
	Receiver = whereis(H),
	timer:sleep(rand:uniform(100)),
	Receiver!{imsg,Id,Send},
   	while(Send,T,Id,0).

start(Send,Recs) ->
	while(Send,Recs,self()),
	clisten(Send).

clisten(Send) ->
receive
	{rmsg,Revr,T3} ->
		Master = whereis(master),
		Master ! {print_rep,Send,Revr,T3},
		clisten(Send);
	{imsg,Sender,Revr} ->
		{T1,T2,T3} = erlang:now(),
		Master = whereis(master),
		Master ! {print_intr,Send,Revr,T3},
		timer:sleep(rand:uniform(100)),
	Sender!{rmsg,Send,T3},
    	clisten(Send)
after 5000 -> io:format("Process ~p has received no calls for 1 second, ending...~n",[Send])
end.