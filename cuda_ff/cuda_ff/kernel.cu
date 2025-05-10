#include <stdio.h>
#include "GameSpace.h"
#include "device_launch_parameters.h"
#include "cuda_runtime.h"

const int _dimension = 10;
const int _threads = 4;
const int _goal = 1;

typedef int my_arr[_dimension];

__device__ int test;

__global__ void NextRound(my_arr* table, my_arr* temptable, int dimension) {
	int global_column = blockIdx.x * blockDim.x + threadIdx.x;
	int global_row = blockIdx.y * blockDim.y + threadIdx.y;

	if (global_row >= dimension || global_column >= dimension) {
		return;
	}

	__shared__ int shr_matrix[_threads + 2][_threads + 2];
	shr_matrix[threadIdx.y + 1][threadIdx.x + 1] = table[global_row][global_column];

	if (threadIdx.x == 0 && global_column != 0) 
	{
		shr_matrix[threadIdx.y + 1][threadIdx.x] = table[global_row][global_column-1];

		if (threadIdx.y == 0) 
		{
			shr_matrix[threadIdx.y][threadIdx.x] = table[global_row-1][global_column-1];
		}
		if (threadIdx.y == _threads - 1) {
			shr_matrix[threadIdx.y+2][threadIdx.x] = table[global_row+1][global_column-1];
		}
	}
	if (threadIdx.x == _threads - 1 && global_column != dimension - 1) 
	{
		shr_matrix[threadIdx.y+1][threadIdx.x+2] = table[global_row][global_column + 1];

		if (threadIdx.y == 0) 
		{
			shr_matrix[threadIdx.y][threadIdx.x+2] = table[global_row-1][global_column+1];
		}
		if (threadIdx.y == _threads - 1)
		{
			shr_matrix[threadIdx.y+2][threadIdx.x+2] = table[global_row+1][global_column+1];
		}
	}
	if (threadIdx.y == 0 && global_row != 0)
	{
		shr_matrix[threadIdx.y][threadIdx.x+1] = table[global_row-1][global_column];
	}
	if (threadIdx.y == _threads - 1 && global_row != dimension - 1)
	{
		shr_matrix[threadIdx.y+2][threadIdx.x+1] = table[global_row+1][global_column];
	}

	int count = 0;
	int cell = shr_matrix[threadIdx.y + 1][threadIdx.x + 1];

	int startRow = threadIdx.y;
	int startColumn = threadIdx.x;
	int endRow = threadIdx.y + 2;
	int endColumn = threadIdx.x + 2;

	if (global_row == 0)
	{
		startRow = threadIdx.y + 1;
	}
	if (global_row == dimension - 1)
	{
		endRow = threadIdx.y + 1;
	}
	if (global_column == 0)
	{
		startColumn = threadIdx.x + 1;
	}
	if (global_column == dimension - 1)
	{
		endColumn = threadIdx.x + 1;
	}

	for (int k = startRow; k <= endRow; ++k)
	{
		for (int l = startColumn; l <= endColumn; ++l)
		{
			if ((k != threadIdx.y + 1 || l != threadIdx.x + 1) && shr_matrix[k][l] == 1)
			{
				count++;
			}
		}
	}

	if (cell == 1 && (count == 2 || count == 3))
	{
		temptable[global_row][global_column] = 1;
	}
	else if (cell == 1 && (count < 2 || count >3))
	{
		temptable[global_row][global_column] = 0;
	}
	else if (cell == 0 && count == 3)
	{
		temptable[global_row][global_column] = 1;
	}
	else
	{
		temptable[global_row][global_column] = 0;
	}
}

__global__ void kernel(my_arr* table, my_arr* temptable, int dimension) {
	int global_column = blockIdx.x * blockDim.x + threadIdx.x;
	int global_row = blockIdx.y * blockDim.y + threadIdx.y;

	if (global_row >= dimension || global_column >= dimension) {
		return;
	}

	table[global_row][global_column] = temptable[global_row][global_column];

}

int main()
{
	GameSpace g(_dimension, _dimension, 0.3);

	my_arr* host_table;
	my_arr* dev_table;
	my_arr* dev_temptable;
	size_t dsize = _dimension * _dimension * sizeof(int);
	host_table = (my_arr*)malloc(dsize);

	for (size_t i = 0; i < _dimension; ++i) {
		for (size_t j = 0; j < _dimension; ++j) {
			host_table[i][j] = g.GetTable()[i][j];
		}
	}

	for (size_t i = 0; i < _dimension; ++i) {
		for (size_t j = 0; j < _dimension; ++j) {
			printf("%d", host_table[i][j]);
			printf(" ");
		}
		printf("\n");
	}
	printf("\n");

	// device memorian allokacio
	cudaMalloc(&dev_table, dsize);
	cudaMalloc(&dev_temptable, dsize);
	// memoria copy oda
	cudaMemcpy(dev_table, host_table, dsize, cudaMemcpyHostToDevice);

	//1d blokkok
	int blocks = (_dimension + _threads - 1) / _threads;
	//2d
	dim3 THREADS(_threads, _threads);
	dim3 BLOCKS(blocks, blocks);

	int round = 0;
	do {
		NextRound << <BLOCKS, THREADS >> > (dev_table, dev_temptable, _dimension);
		kernel << <BLOCKS, THREADS >> > (dev_table, dev_temptable, _dimension);
		++round;
	} while (round != _goal);

	// memoria copy vissza
	cudaMemcpy(host_table, dev_table, dsize, cudaMemcpyDeviceToHost);

	for (size_t i = 0; i < _dimension; ++i) {
		for (size_t j = 0; j < _dimension; ++j) {
			printf("%d", host_table[i][j]);
			printf(" ");
		}
		printf("\n");
	}

	printf("kesz");

	free(host_table);
	cudaFree(dev_table);
	cudaFree(dev_temptable);
}