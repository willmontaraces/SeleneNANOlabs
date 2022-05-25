// A C++ program for Dijkstra's single source shortest path algorithm.
// The program is for adjacency matrix representation of the graph

#include <limits.h>
#include <stdio.h>
#include "workload.h"


// Number of vertices in the graph
#define V 20


int AdjMatrix[V][V] = { 
			{  0,   0, 470,  56, 880, 463, 497, 107, 940, 549, 683,   0,   0, 501,   0, 710,   0, 270,   0, 954},
			{  0,   0, 170, 728,   0, 548,   0,   0,   0,  13,   0,   0, 987, 539, 601, 123, 939, 929,   0,   0},
			{470, 170,   0, 337, 879,  43,   0,  27, 351, 786, 406, 387,   0, 182, 358,   0,   0,   0,   0, 486},
			{ 56, 728, 337,   0, 367,   0,   0,   0, 581,  10, 584, 505, 694, 609, 604, 948, 202, 608, 909,   0},
			{880,   0, 879, 367,   0, 910, 355,   0, 966, 350,   0, 246, 891, 406, 838, 329,   0, 156,   0, 661},
			{463, 548,  43,   0, 910,   0,   0,   0, 457,   0, 877,   0, 827,   0,   0, 952, 987,   0, 221,   0},
			{497,   0,   0,   0, 355,   0,   0, 982, 334, 530,   0,  73,   0, 646, 996, 235,   0, 706,   0, 534},
			{107,   0,  27,   0,   0,   0, 982,   0, 690,   0, 502,   0,   0, 799,   0,   9, 376, 122,   0, 613},
			{940,   0, 351, 581, 966, 457, 334, 690,   0, 845, 948,   0, 424,   0, 494, 832,  99,   0, 559,   0},
			{549,  13, 786,  10, 350,   0, 530,   0, 845,   0, 135, 838, 320, 267, 527, 521, 712,   0,   0,   0},
			{683,   0, 406, 584,   0, 877,   0, 502, 948, 135,   0, 504, 443,   0,   0,   0,   0,   0, 356,   0},
			{  0,   0, 387, 505, 246,   0,  73,   0,   0, 838, 504,   0, 161, 638,  87,  95,   0, 263, 282,   0},
			{  0, 987,   0, 694, 891, 827,   0,   0, 424, 320, 443, 161,   0, 938,   0,   0, 515, 290, 601,   0},
			{501, 539, 182, 609, 406,   0, 646, 799,   0, 267,   0, 638, 938,   0, 502, 233, 136,   0, 279, 762},
			{  0, 601, 358, 604, 838,   0, 996,   0, 494, 527,   0,  87,   0, 502,   0,   0, 717, 105,   0, 563},
			{710, 123,   0, 948, 329, 952, 235,   9, 832, 521,   0,  95,   0, 233,   0,   0, 867,   0,  35,   0},
			{  0, 939,   0, 202,   0, 987,   0, 376,  99, 712,   0,   0, 515, 136, 717, 867,   0, 457,   0,   0},
			{270, 929,   0, 608, 156,   0, 706, 122,   0,   0,   0, 263, 290,   0, 105,   0, 457,   0,   0, 448},
			{  0,   0,   0, 909,   0, 221,   0,   0, 559,   0, 356, 282, 601, 279,   0,  35,   0,   0,   0,   0},
			{954,   0, 486,   0, 661,   0, 534, 613,   0,   0,   0,   0,   0, 762, 563,   0,   0, 448,   0,   0}
};



// find the vertex with minimum distance value, from
// the set of vertices not yet included in shortest path
int minDistance(int * dist, int * sptSet)
{
	// Initialize min value
	int min = INT_MAX;
	int min_index;

	for (int v = 0; v < V; v++){
		if (sptSet[v] == 0 && dist[v] <= min){
			min = dist[v];
			min_index = v;
		}
	}
	return min_index;
}


void dijkstra(int *graph, int src, int * dist)
{

	// distance from src to i

	int sptSet[V]; // sptSet[i] will be true if vertex i is included in shortest
	// path tree or shortest distance from src to i is finalized

	// Initialize all distances as INFINITE and stpSet[] as false
	for (int i = 0; i < V; i++){
		dist[i] = INT_MAX;
		sptSet[i] = 0;
	}

	// Distance of source vertex from itself is always 0
	dist[src] = 0;

	// Find shortest path for all vertices
	for (int count = 0; count < V - 1; count++) {
		// Pick the minimum distance vertex from the set of vertices not
		// yet processed. u is always equal to src in the first iteration.
		int u = minDistance(dist, sptSet);

		// Mark the picked vertex as processed
		sptSet[u] = 1;

		// Update dist value of the adjacent vertices of the picked vertex.
		for (int v = 0; v < V; v++){

			// Update dist[v] only if is not in sptSet, there is an edge from
			// u to v, and total weight of path from src to v through u is
			// smaller than current value of dist[v]
			if (sptSet[v]==0 && graph[u*V+v] && dist[u] != INT_MAX
				&& dist[u] + graph[u*V+v] < dist[v])
				dist[v] = dist[u] + graph[u*V+v];
		}
	}
}



void mkernel(int mhartid)
{
                 
	for(int i=0;i<CORE_DELAY*mhartid;i++){
		__asm("nop");
	}

    	int * dist = (int*) (RES_PTR + mhartid*RES_ITEMS);
	dijkstra(AdjMatrix, 0, dist);
	
/*	
	printf("Vertex Distance from Source\n");
	for (int i = 0; i < V; i++)
		printf("0 to %d: %d\n", i, dist[i]);
*/

	//stall all harts but hart-0 (main core)
	while(mhartid>0){ };
}






