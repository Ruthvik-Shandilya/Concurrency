-module(exchange).

-export([start/0,while/1,while/2]).
-import(calling,[start/2]).


while(L) -> 
	while(L,0).
while([],0) -> ok;
while([H|T],0) ->
	Line = tuple_to_list(H),
	Line_K = lists:nth(1,Line),
	Line_V = lists:nth(2,Line),
	Pid = spawn(calling,start,[Line_K,Line_V]),
	register(Line_K, Pid),
 while(T,0).

start() ->
  register(master,self()),
  X = file:consult("calls.txt"),
  Filecontent = tuple_to_list(X),
  Inputlist = lists:nth(2,Filecontent),
  Inputmap = maps:from_list(Inputlist),
  io:format("** Calls to be made **~n"),
  maps:fold(
  			fun(K, V, ok) -> 
  				io:format("~p:~p~n",[K,V])
  			end, ok,Inputmap),
  io:format("~n"),
  while(Inputlist),
  mlisten().

mlisten() ->
receive
	{print_rep,Send,Revr,T3} ->
		io:format("~s received reply message from ~s [~p]\n",[Send,Revr,T3]),
	mlisten();
	{print_intr,Send,Revr,T3} ->
		io:format("~s received intro message from ~s [~p]\n",[Send,Revr,T3]),
	mlisten()
after 5500 -> io:format("Master has received no replies for 1.5 seconds, ending...~n")
end.