.include "macrolib.asm"
.globl algorithm

.text
# Зададим, два значения x_0 и x_1, такие что значения функции от этих аргументов будут разных знаков.
# Следующий шаг алгоритма: обновления приближения корня с помощью уравнения хорды.
# Итерации происходят до тех пор, пока разность между последовательными приближениями не станет, меньше заданной точности.
algorithm:
	push(ra)					# Пусть x_0 и x_1 равны границам нашего интервала.
	fld ft0 A_x0 t0
	fld ft1 B_x1 t0
	
loop:
	fsub.d fs2, ft1, ft0			# значение x_1-x_0
	my_func(ft0)				# Значение f(x_0)
	fmv.d fs3, fa0				# Переносим в fs3
	
	my_func(ft1)				# Значение f(x_1)
	fmv.d fs4, fa0				# Переносим в fs4
	
	fmul.d fs2, fs2, fs3			# Умножаем данную дробь на f(x_0)
	fsub.d fs3, fs4, fs3			# Находим f(x_1) - f(x_0)

	fdiv.d fs2, fs2, fs3			# Делим разность аргументов на разность значений

	fsub.d ft2, ft0, fs2			# Находим x_2
	
check:
	fcvt.d.w   fs5, zero
	
	fsub.d fs5, ft2, ft1			
	fabs.d fs5, fs5				# Нахожу модуль разности x_i и x_{i-1}
	
	flt.d   t1, fs5, ft11			# Сравниваю его с заданной точностью
	bnez   t1, end_loop			# Выхожу из цикла, если точность больше либо равна

	
	fmv.d ft0, ft1
	fmv.d ft1, ft2
	fcvt.d.w   ft2, zero
	j loop
end_loop:
	pop(ra)
	ret 
