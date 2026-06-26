function flState = init_fl_state(numUAVs)

flState.globalModelRGB=rand(1,10);

flState.globalModelThermal=rand(1,10);

flState.round=0;

flState.selectedHistory={};

flState.lossHistory=[];

flState.numUAVs=numUAVs;
flState.globalRound=0;

flState.totalAsyncUpdates=0;

flState.lastUpdateCycle=0;

flState.pendingUpdates={};

flState.stalenessHistory=[];

flState.energyHistory=[];
%% ===== ASYNC FL ADDITIONS =====

flState.globalRound=0;

flState.lastUpdateCycle=0;

flState.totalAsyncUpdates=0;

flState.stalenessHistory=[];

flState.energyHistory=[];

flState.pendingUpdates={};
flState.stalenessHistory=[];

end