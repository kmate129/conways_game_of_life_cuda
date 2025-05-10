#pragma once
#pragma once

class GameSpace
{
public:
	GameSpace(const int width);
	GameSpace(const int height, const int width);
	GameSpace(const int width, const double chance);
	GameSpace(const int height, const int width, const double chance);
	GameSpace(const int height, const int width, const int top, const int left, const int** matrix);

	int nRound = 1;
	int nCells;

	int GetRows() const;
	int GetColumns() const;
	int** GetTable() const;
	void SetTableElement(int i, int j, int val);

	void RoundInc();
	void CellsInc();
	void SetCells(int val);

	void Print() const;
private:
	int** table;
	int nRow;
	int nColumn;
};

