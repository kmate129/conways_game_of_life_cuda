#include "GameSpace.h"
#include <random>

GameSpace::GameSpace(const int width) : nRow(width), nColumn(width)
{
	nCells = 0;
	table = new int* [width];
	std::random_device rD;
	std::default_random_engine rE(rD());
	std::uniform_int_distribution<int> dist(0, 100);

	for (int i = 0; i < width; ++i)
	{
		table[i] = new int[width];

		for (int j = 0; j < width; ++j)
		{
			if (dist(rE) <= 10)
			{
				table[i][j] = 1;
				nCells++;
			}
			else
			{
				table[i][j] = 0;
			}
		}
	}
}

GameSpace::GameSpace(const int height, const int width) : nRow(height), nColumn(width)
{
	nCells = 0;
	table = new int* [height];
	std::random_device rD;
	std::default_random_engine rE(rD());
	std::uniform_int_distribution<int> dist(0, 100);

	for (int i = 0; i < height; i++)
	{
		table[i] = new int[width];

		for (int j = 0; j < width; ++j)
		{
			if (dist(rE) <= 10)
			{
				table[i][j] = 1;
				nCells++;
			}
			else
			{
				table[i][j] = 0;
			}
		}
	}
}

GameSpace::GameSpace(const int width, const double chance) : nRow(width), nColumn(width)
{
	nCells = 0;
	table = new int* [width];
	std::random_device rD;
	std::default_random_engine rE(rD());
	std::uniform_int_distribution<int> dist(0, 1000);

	for (int i = 0; i < width; ++i)
	{
		table[i] = new int[width];

		for (int j = 0; j < width; ++j)
		{
			if (static_cast<double>(dist(rE)) / 1000 <= chance)
			{
				table[i][j] = 1;
				nCells++;
			}
			else
			{
				table[i][j] = 0;
			}
		}
	}
}

GameSpace::GameSpace(const int height, const int width, const double chance) : nRow(height), nColumn(width)
{
	nCells = 0;
	table = new int* [height];
	std::random_device rD;
	std::default_random_engine rE(rD());
	std::uniform_int_distribution<int> dist(0, 1000);

	for (int i = 0; i < height; ++i)
	{
		table[i] = new int[width];

		for (int j = 0; j < width; ++j)
		{
			if (static_cast<double>(dist(rE)) / 1000 <= chance)
			{
				table[i][j] = 1;
				nCells++;
			}
			else
			{
				table[i][j] = 0;
			}
		}
	}
}

GameSpace::GameSpace(const int height, const int width, const int top, const int left, const int** matrix) : nRow(height), nColumn(width)
{
	table = new int* [height];
	nCells = 0;
	int i = top;
	size_t k = 0;
	std::vector<std::vector<int>>::size_type matrixHeight = sizeof(matrix) / sizeof(matrix[0]);
	std::vector<int>::size_type matrixWidth = sizeof(matrix[0]) / sizeof(matrix[0][0]);

	for (int i = 0; i < height; ++i)
	{
		table[i] = new int[width];

		for (int j = 0; j < width; ++j)
		{
			table[i][j] = 0;
		}
	}

	while (i < height && k < matrixHeight)
	{
		int j = left;
		size_t l = 0;
		while (j < width && l < matrixWidth)
		{
			table[i][j] = matrix[k][l];
			if (table[i][j] == 1)
			{
				nCells++;
			}

			j++;
			l++;
		}

		i++;
		k++;
	}
}

int** GameSpace::GetTable() const
{
	return table;
}

void GameSpace::Print() const {
	for (size_t i = 0; i < nRow; ++i)
	{
		for (size_t j = 0; j < nColumn; ++j)
		{
			if (0 == table[i][j]) {
				printf("%c ", '0');
			}
			else {
				printf("%c ", '1');
			}
		}

		printf("\n");
	}
}

void GameSpace::RoundInc() {
	++nRound;
}

void GameSpace::CellsInc() {
	++nCells;
}

void GameSpace::SetCells(int val) {
	nCells = val;
}

int GameSpace::GetRows() const {
	return nRow;
}
int GameSpace::GetColumns() const {
	return nColumn;
}

void GameSpace::SetTableElement(int i, int j, int val) {
	table[i][j] = val;
}