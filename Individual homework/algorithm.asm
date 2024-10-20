.include "macrolib.asm"
.globl algorithm


.text
# Основной алгоритм, по которому происходит заполнение массива B. Алгоритм содержит 3 цикла для заполнения положительных, нулевых и отрицательных элементов соответственно.
algorithm:
	push(ra)							# Кладем ra на стек.
	la t0 A_array							# Загрузили в t0 начало массива А.
	
# Цикл для заполениния массива положительными числами.
# Бежим по всему массиву и проверяем каждое число на положительность.
loop_for_positive:	
	lw a2 (t0)							# Загружаем число по адресу t0 в регистр a2.
	bgtz a2, push_positive						# Проверяем позитивное ли оно.
	addi t0, t0, 4							# Обновляем адрес следующего числа и
	addi a3, a3, 1							# Итератор.
	bgt a1, a3, loop_for_positive					
	j reset_for_null						# Если прошли весь массив, переходим к подготовлению массива и итератора для аналогичного цикла для нулевых значений.

# Если число положительное, передаем его в начало массива B по регистру t1.
push_positive:
	sw a2 (t1)
	addi t1, t1, 4	
	addi t0, t0, 4
	addi a3, a3, 1
	bgt a1, a3, loop_for_positive					# Возвращаемся дальше в цикл.
	
# Обновляем итератор и регистр массива.
reset_for_null:								
	mv a3, zero
	la t0 A_array
	
# Аналогичный цикл, что и для положительных чисел, однако проверяет числа на равенство нулю.
loop_for_null:
	lw a2 (t0)
	beqz a2, push_null
	addi t0, t0, 4
	addi a3, a3, 1							# Итератор
	bgt a1, a3, loop_for_null
	j reset_for_negative
	
# Заполнение массива B нулевыми элементами.
push_null:
	sw a2 (t1)
	addi t1, t1, 4	
	addi t0, t0, 4
	addi a3, a3, 1
	bgt a1, a3, loop_for_null

# Обновляем итератор и регистр массива.
reset_for_negative:				
	mv a3, zero
	la t0 A_array
	
# Аналогичный цикл, что и для положительных чисел, однако проверяет числа на отрицательность.	
loop_for_negative:	
	lw a2 (t0)
	bltz a2, push_negative
	addi t0, t0, 4
	addi a3, a3, 1							# Итератор
	bgt a1, a3, loop_for_negative
	j end_alghoritm
	
# Заполнение массива B отрицательными элементами.
push_negative:
	sw a2 (t1)
	addi t1, t1, 4	
	addi t0, t0, 4
	addi a3, a3, 1
	bgt a1, a3, loop_for_negative
# Конец алгоритма возвращаем все знаения из стека и обновляем в регистрах t0 и t1 адреса массивов.
end_alghoritm:
	la t0 A_array							# Загрузили в Т0 начало массива А
	la t1 B_array							# Загрузили в Т1 начало массива B
	pop(ra)
	ret
