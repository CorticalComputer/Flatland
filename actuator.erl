%% This source code and work is provided and developed by DXNN Research Group WWW.DXNNResearch.COM
%%
%Copyright (C) 2012 by Gene Sher, DXNN Research Group, CorticalComputer@gmail.com
%All rights reserved.
%
%This code is licensed under the version 3 of the GNU General Public License. Please see the LICENSE file that accompanies this project for the terms of use.

-module(actuator).
-compile(export_all).
-include("records.hrl").

gen(ExoSelf_PId,Node)->
	spawn(Node,?MODULE,prep,[ExoSelf_PId]).

prep(ExoSelf_PId) -> 
	receive 
		{ExoSelf_PId,{Id,Cx_PId,Scape,ActuatorName,VL,Parameters,Fanin_PIds}} ->
			loop(Id,ExoSelf_PId,Cx_PId,Scape,ActuatorName,VL,Parameters,{Fanin_PIds,Fanin_PIds},[])
	end.
%When gen/2 is executed it spawns the actuator element and immediately begins to wait for its initial state message.

loop(Id,ExoSelf_PId,Cx_PId,Scape,AName,VL,Parameters,{[From_PId|Fanin_PIds],MFanin_PIds},Acc) ->
	receive
		{From_PId,forward,Input} ->
			loop(Id,ExoSelf_PId,Cx_PId,Scape,AName,VL,Parameters,{Fanin_PIds,MFanin_PIds},lists:append(Input,Acc));
		{ExoSelf_PId,terminate} ->
			%io:format("Actuator:~p is terminating.~n",[self()])
			ok
	end;
loop(Id,ExoSelf_PId,Cx_PId,Scape,AName,VL,Parameters,{[],MFanin_PIds},Acc)->
	{Fitness,EndFlag} = actuator:AName(ExoSelf_PId,lists:reverse(Acc),Parameters,VL,Scape),
	Cx_PId ! {self(),sync,Fitness,EndFlag},
	loop(Id,ExoSelf_PId,Cx_PId,Scape,AName,VL,Parameters,{MFanin_PIds,MFanin_PIds},[]).
%The actuator process gathers the control signals from the neurons, appending them to the accumulator. The order in which the signals are accumulated into a vector is in the same order as the neuron ids are stored within NIds. Once all the signals have been gathered, the actuator sends cortex the sync signal, executes its function, and then again begins to wait for the neural signals from the output layer by reseting the Fanin_PIds from the second copy of the list.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ACTUATORS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

two_wheels(ExoSelf_PId,Output,Parameters,VL,Scape)->
	OVL = length(Output),
	case OVL == VL of
		true ->
			{Fitness,HaltFlag}=gen_server:call(Scape,{actuator,ExoSelf_PId,two_wheels,Output});
		false ->
			{Fitness,HaltFlag}=gen_server:call(Scape,{actuator,ExoSelf_PId,two_wheels,lists:append(Output,lists:duplicate(OVL - VL,0))})
	end.
