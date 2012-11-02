%% This source code and work is provided and developed by DXNN Research Group WWW.DXNNResearch.COM
%%
%Copyright (C) 2012 by Gene Sher, DXNN Research Group, CorticalComputer@gmail.com
%All rights reserved.
%
%This code is licensed under the version 3 of the GNU General Public License. Please see the LICENSE file that accompanies this project for the terms of use.

-module(morphology).
-compile(export_all).
-include("records.hrl").

predator(actuators)->
	prey(actuators);
predator(sensors)->
	prey(sensors).

prey(actuators)->
	Movement = [#actuator{name=two_wheels,type=standard,scape={public,flatland},format=no_geo,vl=2,parameters=[2]}],
	Movement;
prey(sensors)->
	Pi = math:pi(),
	Distance_Scanners = [#sensor{name=distance_scanner,type=standard,scape={public,flatland},format=no_geo,vl=Density,parameters=[Spread,Density,ROffset]} || 
		Spread<-[Pi/2],Density<-[5], ROffset<-[Pi*0/2]],
	Color_Scanners = [#sensor{name=color_scanner,type=standard,scape={public,flatland},format=no_geo,vl=Density,parameters=[Spread,Density,ROffset]} ||
		Spread <-[Pi/2], Density <-[5], ROffset<-[Pi*0/2]],
	Energy_Scanners = [#sensor{name=energy_scanner,type=standard,scape={public,flatland},format=no_geo,vl=Density,parameters=[Spread,Density,ROffset]} ||
		Spread <-[Pi/2], Density <-[5], ROffset<-[Pi*0/2]],
	Stat_Readers = [#sensor{name=Name,type=standard,scape={public,flatland},format=no_geo,vl=Density,parameters=Param} || {Name,Density,Param} <- [{energy_reader,1,[]}]],
	Color_Scanners.%++Distance_Scanners.
	
generate_id() ->
	{MegaSeconds,Seconds,MicroSeconds} = now(), 
	1/(MegaSeconds*1000000 + Seconds + MicroSeconds/1000000).
