.include  "macrolib.asm"
.globl read_name, open_read_file, save_file,  choice, clear_buffers , check_choice, strcpy
.eqv    NAME_SIZE 256	# Размер буфера для имени файла
.eqv    TEXT_SIZE 512		# Размер буфера для текста
.data
	
	er_name_mes:    .asciz "Неверное имя файла\n"
	er_read_mes:    .asciz "Некорректная операция чтения файла\n"
	er_choice_mes:	.asciz "Некорректный ввод! Введите [Y/N]:"
	choice_outres:	.asciz "Хотите ли вы вывести результаты работы программы на консоль [Y/N]: "
	output_nstr1:	.asciz "Вот символы, которые есть в первой строке, но нет во второй: "
	output_nstr2:	.asciz "Вот символы, которые есть во второй строке, но нет в первой: "
	

	solution: 	.space 	NAME_SIZE
	Yes:		.asciz "Y"
	No:		.asciz "N"
.text
# Параметры
# a0 - строка для ввода имени файла.
#
# a0 - возврат начала буфера файла без \n на конце.
#

read_name:
	
    	# Ввод имени файла с консоли эмулятора
    	read_str(file_name, NAME_SIZE)
    	# Убрать перевод строки
    	li	t4 '\n'
    	la	t5	file_name
loop:
    	lb	t6  (t5)
    	beq t4	t6	replace
    	addi t5 t5 1
    	b	loop
replace:
    	sb	zero (t5)
    	ret


# Параметры
# a0 - строка для ввода имени файла.
#
# a0 - возврат начала буфера файла без \n на конце.
# a1 - возврат длины прочитанной строки.
#	
open_read_file:
	push(s0)
	push(s1)
	push(s2)
	push(s3)
	push(s4)
	push(s5)
	push(s6)
	open(file_name, READ_ONLY)
  	li		s1 	-1				# Проверка на корректное открытие
    	beq		a0 	s1 er_name			# Ошибка открытия файла
    	mv   		s0 	a0       			# Сохранение дескриптора файла

    	# Выделение начального блока памяти для для буфера в куче
    	allocate(TEXT_SIZE)					# Результат хранится в a0
    	mv 		s3, 	a0				# Сохранение адреса кучи в регистре
    	mv 		s5, 	a0				# Сохранение изменяемого адреса кучи в регистре
    	li		s4, 	TEXT_SIZE			# Сохранение константы для обработки
    	mv		s6, 	zero				# Установка начальной длины прочитанного текста
read_loop:
	# Чтение информации из открытого файла
	read_addr_reg(s0, s5, TEXT_SIZE) 		# чтение для адреса блока из регистра
	    
	    	# Проверка на корректное чтение
	beq	a0 	s1 er_read			# Ошибка
	mv   	s2 	a0       			# Сохранение длины текста
	add 	s6, 	s6, 	s2			# Размер текста увеличивается на прочитанную порцию
	    
	# Если длина считанного текста, чем размер буфера,
	# нужно завершить процесс.
	bne	s2 	s4 	end_loop
	    	
	# Иначе расширить буфер и повторить
	allocate(TEXT_SIZE)			# Результат здесь не нужен, но если нужно то...
	add	s5 	s5 	s2		# Адрес для чтения смещается на размер порции
	b read_loop				# Обработка следующей порции текста из файла
end_loop:
	close(s0)				# Закрытие файла
	mv	t0 	s3			# Адрес буфера в куче
	add 	t0 	t0 	s6		# Адрес последнего прочитанного символа
	addi 	t0 	t0 	1		# Место для нуля
	sb	zero 	(t0)			# Запись нуля в конец текста
	mv 	a0 	s3			# Переношу адрес буффера из s3 в a0
	mv	a1	s6			# Переношу размер прочитанной строки в a1
	
	pop(s6)
	pop(s5)
	pop(s4)
	pop(s3)
	pop(s2)
	pop(s1)
	pop(s0)
	ret



# Параметры
# a1 - Адрес буфера записываемого текста
# a2 - Размер записываемой порции из регистра
# 
save_file:
	push(s0)
	push(s1)
	push(s3)
	push(s6)
	mv s3 a1
	mv s6 a2
	# Сохранение прочитанного файла в другом файле
    	open(file_name, WRITE_ONLY)
    	li		s1 	-1			# Проверка на корректное открытие
    	beq		a0 	s1 	er_name		# Ошибка открытия файла
    	mv   		s0 	a0       		# Сохранение дескриптора файла

	# Запись информации в открытый файл
    	li   		a7, 	64       		# Системный вызов для записи в файл
    	mv   		a0, 	s0 			# Дескриптор файла
	mv 		a1, s3
	mv 		a2, s6
    	ecall             				# Запись в файл
	
	close(s0)
	pop(s6)
	pop(s3)
	pop(s1)
	pop(s0)
	
    	ret
    
er_name:
	# Сообщение об ошибочном имени файла
    	la		a0 	er_name_mes
    	li		a7 	4
    	ecall
    	# И завершение программы
    	exit
er_read:
    	# Сообщение об ошибочном чтении
    	la		a0 	er_read_mes
    	li		a7 	4
    	ecall
    	# И завершение программы
    	exit

# Алгоритм для копирования строки.
strcpy:
loop_copy:
	lb	t0, (a5)
	sb	t0, (a6)
	beqz	t0, end
	addi	a5, a5, 1
	addi	a6, a6, 1
	b	loop_copy
	
end:
	ret




# Параметры
# 
# a0 -  Результат 1 или 0.
# 
check_choice:
	push(s0)
	push(s1)
	la s0 Yes
	la s1 No
loop_input_choice:	
	read_str(solution,TEXT_SIZE)	# Считываю ответ пользователя
	la a0 solution
	lb t0 (a0)
	lb t1 (s0)
	lb t2 (s1)
	beq t0 t1 yes			# Сравниваю с Y и N если ответ не соответствует, то повторяю запрос ответа до корректного ввода
	beq t0 t2 no
	j incorrect_input
	


incorrect_input:
	print_str(er_choice_mes)
	j loop_input_choice
yes:
	mv a0 zero 			# Если ответ да возвращаю 1 иначе 0
	addi a0 a0 1
	j fin
no:	
	mv a0 zero 
	j fin
fin:
	
	pop(s1)
	pop(s0)
	ret



choice:
	push(ra)
	newline
	print_str(choice_outres)
	la t6 check_choice	# Переход в подпрограмму для запросу выбора у пользователя.
	jalr t6
	beqz a0 finish
	
	# Вывод результатов программы в консоль, если пользователь захочет.
	newline
	print_str(output_nstr1)
	newline
	print_str(newstr1)	# Вывод первой строки результатов
	newline
	print_str(output_nstr2)
	newline
	print_str(newstr2)	# Вывод второй строки результатов
	newline
	newline
finish:
	pop(ra)
	ret


# Подпрограмма для очистки буфферов.
clear_buffers:
	clear_buf(array_chars1, TEXT_SIZE)
	clear_buf(array_chars2, TEXT_SIZE)
	clear_buf(newstr1, TEXT_SIZE)
	clear_buf(newstr2, TEXT_SIZE)	

	ret


