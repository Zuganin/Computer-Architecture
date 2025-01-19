
# Печать содержимого регистра, если там храниться целочисленное значение.
.macro print_int (%x)
	li a7, 1
	mv a0, %x
	ecall
.end_macro

# Ввод целого числа с консоли в указанный регистр,
# исключая регистр a0
.macro read_int(%x)
   push	(a0)
   li a7, 5
   ecall
   mv %x, a0
   pop	(a0)
.end_macro

# Печать строки передаваемой в макро.
.macro print_str (%x)
   .data
str:
   .asciz %x
   .text
   push (a0)
   li a7, 4
   la a0, str
   ecall
   pop	(a0)
   .end_macro

# Печать символа передаваемой в макро.
.macro print_char(%x)
   push (a0)
   li a7, 11
   li a0, %x
   ecall
   pop	(a0)
   .end_macro
   
# Перевод строки.
.macro newline
   print_char('\n')
   .end_macro

# Завершение программы
.macro exit
    li a7, 10
    ecall
.end_macro

# Сохранение заданного регистра на стеке
.macro push(%x)
	addi	sp, sp, -4
	sw	%x, (sp)
.end_macro

# Выталкивание значения с вершины стека в регистр
.macro pop(%x)
	lw	%x, (sp)
	addi	sp, sp, 4
.end_macro

# Вывод поэлементно массива с адресом начала в "%x".
.macro	print_array(%x, %size)
	push(a2)
	push(a3)
	mv a3, zero
	
loop_print:
	lw a2 (%x)
	print_int(a2)
	print_char(' ')
	addi %x, %x, 4
	addi a3, a3, 1
	bgt %size, a3, loop_print
	newline
	
	pop(a3)
	pop(a2)
.end_macro 

# Копирование 1 массива %х в регистр %array_copy, size - размер, передаваемого массива.
.macro copy_array(%array_copy, %x,%size)

.text
	push(ra)
	push(t6)
	mv t5, %x
	mv a3, zero								# Обнуляем итератор
loop:
	lw t6, (t5)								# Загрузить текущий элемент из исходного массива в t6
	sw t6, (%array_copy)							# Сохранить элемент в A_array
	addi t5, t5, 4								# Перейти к следующему элементу в исходном массиве
	addi %array_copy, %array_copy, 4					# Перейти к следующему элементу в A_array
	addi a3, a3, 1 								# Итератор 
	bgt %size, a3, loop							# Повторяем цикл пока итератор меньше размера массива	
end_copy:
	mv a3, zero								# Обнуляем итератор
	pop(t6)
	pop(ra)
										
.end_macro 
