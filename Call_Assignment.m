%MAIN
tic
load('Amsterdam.mat');
%load('SA_Input_Phase1_variant0.mat');
load('Amsterdam_Transit_Lines.mat');
load('Amsterdam_Metro_Lines.mat');
 %Transit_Lines=TL_solution_vector;

number_of_shortest_paths=1;
utility_type=1;

[Adj_Matrix_Transit_Running_Times] = Transit_RTs(Node_id,Link_input,Transit_Lines,Metro_Lines);
[Paths] = PathGen(OD,Adj_Matrix_Transit_Running_Times,number_of_shortest_paths,Origins,Destinations);
Initial_Paths=Paths;
%save('Amsterdam_Paths_d2026.mat','Initial_Paths')
toc
[Paths] = Assign_Transit_Lines_v4(Paths,Transit_Lines,Metro_Lines);
Assigned_paths=Paths;
save('Amsterdam_Assigned_Paths.mat','Assigned_paths')
toc
[Paths] = TimeComponents(Paths,Transit_Lines,Metro_Lines,R_G);
toc
[Paths] = Utility_Components(Paths);
toc;
[Paths] = Utility(Paths,utility_type);
toc;
Fortisi=Assignment(Paths,OD,R_G,Adj_Matrix_Running_Times,Origins,Destinations);
toc

save('Amsterdam_Transit_Assignment_v4u1.mat','Paths','Fortisi');