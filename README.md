# Трусковкий Георгий, вариант 11, 19

### Задача №1. 
https://projecteuler.net/problem=11

Given an grid 20x20, need to find biggest product of 4 numbers.

What is the greatest product of four adjacent numbers in the same direction (up, down, left, right, or diagonally) in the 
 grid?

Solution:
Представляем сетку как двумерный массив, для каждого элемента вычисляем product четырёх чисел, учитывая границы матрицы.

### Задача №2

You are given the following information, but you may prefer to do some research for yourself.

1 Jan 1900 was a Monday.
Thirty days has September,
April, June and November.
All the rest have thirty-one,
Saving February alone,
Which has twenty-eight, rain or shine.
And on leap years, twenty-nine.
A leap year occurs on any year evenly divisible by 4, but not on a century unless it is divisible by 400.
How many Sundays fell on the first of the month during the twentieth century (1 Jan 1901 to 31 Dec 2000)?

https://projecteuler.net/problem=19

Solution:
Начиная с известной даты, доходим до 1 января 1901 года, далее с 1901 по 2000 в каждом месяце будем вычислять день недели для первого числа месяца. И обновлять счётчик