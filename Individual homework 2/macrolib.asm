
# Печать содержимого регистра, если там храниться double значение.
.macro print_double(%x)
	li a7, 3
	fmv.d fa0, %x
	ecall
	newline
.end_macro

# Ввод дробного числа(double) числа с консоли в указанный регистр,
# исключая регистр a0
.macro read_double(%x)
   push_d(fa0)
   li a7, 7
   ecall
   fmv.d %x, fa0
   pop_d(fa0)
 
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

# Сохранение заданного регистра на стеке
.macro push_d(%x)
	addi	sp, sp, -4
	fsd	%x, (sp)
.end_macro

# Выталкивание значения с вершины стека в регистр
.macro pop_d(%x)
	fld	%x, (sp)
	addi	sp, sp, 4
.end_macro


# Возведение дробного числа в целочисленную степень %pow
.macro pow_d(%x ,%pow)
.data
	null: .double 0,0
.text	
	push(ra)
	push(t1)
	push_d(ft0)
	push_d(ft1)
	li t1, 1			# Итератор
	beqz %pow, if_pow0
	fcvt.d.w  fa0, t1
	addi %pow, %pow, 1
loop:
	bge t1 %pow end
	fmul.d fa0, fa0, %x
	addi t1 t1 1
	j loop
if_pow0:
	fcvt.d.w ft1, t1
	fld ft0 null t0
	fadd.d fa0, ft1, ft0
end:
	pop_d(ft1)
	pop_d(ft0)
	pop(t1)
	pop(ra)
.end_macro 

# Макрос, который считает значение моей x^5-x-0.2=0
.macro my_func(%x)
.data 
	const: .double 0.2
	null: .double 0.0
.text
	push_d(ft5)
	push_d(ft6)
	push(t0)
	
	fld ft5 null t0
	fld ft6 const t0
	fsub.d ft5, ft5, ft6
	fsub.d ft5, ft5, %x
	li t0 5
	pow_d(%x, t0)
	fadd.d fa0, fa0, ft5

	pop(t0)
	pop_d(ft6)
	pop_d(ft5)
.end_macro 





