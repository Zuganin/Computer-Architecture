.include "macrolib.asm"
# Загружаем возможные значения точности для тестов
.data 
	test1: .double 0.001				
	test2: .double 0.0001
	test3: .double 0.00001
	test4: .double 0.000001
.text
tests:
# Тестирование программы
test_1:
	fld ft11 test1 t0
	la t0 algorithm	
	jalr t0
	la t0 rounding						
	jalr t0
	print_str("Вот значение корня с заданной вами точностью :")
	print_double(ft2)
test_2:
	fld ft11 test2 t0
	la t0 algorithm	
	jalr t0
	la t0 rounding						
	jalr t0
	print_str("Вот значение корня с заданной вами точностью :")
	print_double(ft2)

test_3:
	fld ft11 test3 t0
	la t0 algorithm	
	jalr t0
	la t0 rounding						
	jalr t0
	print_str("Вот значение корня с заданной вами точностью :")
	print_double(ft2)
test_4:
	fld ft11 test4 t0
	la t0 algorithm	
	jalr t0
	la t0 rounding						
	jalr t0
	print_str("Вот значение корня с заданной вами точностью :")
	print_double(ft2)
	exit


