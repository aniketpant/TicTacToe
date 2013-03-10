TicTacToe
=========

I have been trying to learn Ruby recently and I applied for the [apprenticeship program](http://www.8thlight.com/apprenticeship) by [8th Light](http://www.8thlight.com/). The first task is to make an unbeatable AI for a Tic Tac Toe game.

It's quite interesting how a small game like this can be made interesting in terms of the code when you have the freedom to make an AI that cannot be beaten.

## Instructions

Run the program by `ruby start.rb`

## Why use a case based code?

The magic square logic can be used for any size of grid because it allows fast checking of winning possibilities and in making the next move. The MinMax algorithm could have been easily applied but the number of iterations in that algorithm are huge and they increase with the size of the grid. Instead if the victory conditions can be determined before and then the moves be made, it will increase the efficiency of the code. Other than that this code has some problems in terms of the code being less generic but it can be made more modular by using the magic square efficiently.