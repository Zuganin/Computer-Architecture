

# Печать строки передаваемой в макро.
.macro print_str(%x)
   la a0, %x			
   li a7, 4			
   ecall	
.end_macro

# Ввод строки с консоли
.macro read_str(%str, %bufsize)
    la a0 %str
    li a1 %bufsize
    li a7 8
    ecall
.end_macro


.macro read_str( %bufsize)
    li a1 %bufsize
    li a7 8
    ecall
.end_macro

# Печать символа передаваемой в макро.
.macro print_char(%x)
   push (a0)
   li a7, 11
   mv a0, %x
   ecall
   pop	(a0)
   .end_macro
   
# Перевод строки.
.macro newline
.data
newline: .asciz "\n"
.text
	la a0, newline
   	li a7 4
   	ecall
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

.macro check_unique (%array, %x, %size)
   	# array  - адрес массива
    	# x      - символ для проверки
    	# size   - количество элементов в массиве
		
	push(t0)
	push(t1)
	push(t2)
    	li s11 1            	 # Предполагаем, что символ уникален
    	li t0, 0                 # Счётчик итераций
    	la t1, %array            # Адрес массива

check_loop:
    	beq t0, %size, end_check # Если дошли до конца массива, завершаем
    	lb t2, 0(t1)             # Загружаем символ из массива
    	beq t2, %x, not_unique   # Если символ уже есть, он не уникален
    	addi t1, t1, 4           # Переходим к следующему элементу массива
    	addi t0, t0, 1           # Увеличиваем счётчик
    	j check_loop             # Повторяем цикл

not_unique:
    	li s11, 0            	 # Символ не уникален
	
end_check:
	pop(t2)
	pop(t1)
	pop(t0)
.end_macro



#-------------------------------------------------------------------------------
# Ввод строки в буфер заданного размера с заменой перевода строки нулем
# %strbuf - адрес буфера
# %size - целая константа, ограничивающая размер вводимой строки
.macro str_get(%strbuf, %size)
    la      a0 %strbuf
    li      a1 %size
    li      a7 8
    ecall
    push(s0)
    push(s1)
    push(s2)
    li	s0 '\n'
    la	s1	%strbuf
next:
    lb	s2  (s1)
    beq s0	s2	replace
    addi s1 s1 1
    b	next
replace:
    sb	zero (s1)
    pop(s2)
    pop(s1)
    pop(s0)
.end_macro


# Параметры
# a0 - строка для ввода имени файла.
#
# a0 - возврат дескриптор файла или -1.
#
#-------------------------------------------------------------------------------
# Открытие файла для чтения, записи, дополнения
.eqv READ_ONLY	0	# Открыть для чтения
.eqv WRITE_ONLY	1	# Открыть для записи
.eqv APPEND	    9	# Открыть для добавления
.macro open(%file_name, %opt)
    li   	a7 1024     	# Системный вызов открытия файла
    la      a0 %file_name   # Имя открываемого файла
    li   	a1 %opt        	# Открыть для чтения (флаг = 0)
    ecall             		# Дескриптор файла в a0 или -1)
.end_macro

#-------------------------------------------------------------------------------

# Чтение информации из открытого файла
.macro read(%file_descriptor, %strbuf, %size)
    li   a7, 63       	# Системный вызов для чтения из файла
    mv   a0, %file_descriptor       # Дескриптор файла
    la   a1, %strbuf   	# Адрес буфера для читаемого текста
    li   a2, %size 		# Размер читаемой порции
    ecall             	# Чтение
.end_macro

#-------------------------------------------------------------------------------
# Чтение информации из открытого файла,
# когда адрес буфера в регистре
.macro read_addr_reg(%file_descriptor, %reg, %size)
    li   a7, 63       	# Системный вызов для чтения из файла
    mv   a0, %file_descriptor       # Дескриптор файла
    mv   a1, %reg   	# Адрес буфера для читаемого текста из регистра
    li   a2, %size 		# Размер читаемой порции
    ecall             	# Чтение
.end_macro

#-------------------------------------------------------------------------------
# Закрытие файла
.macro close(%file_descriptor)
    li   a7, 57       # Системный вызов закрытия файла
    mv   a0, %file_descriptor  # Дескриптор файла
    ecall             # Закрытие файла
.end_macro

#-------------------------------------------------------------------------------
# Выделение области динамической памяти заданного размера
.macro allocate(%size)
    li a7, 9
    li a0, %size	# Размер блока памяти
    ecall
.end_macro

#-------------------------------------------------------------------------------
# Макрос для копирования строки
.macro strcpy (%s1, %s2)
	la a5 %s1
	la a6 %s2
	jal strcpy
.end_macro

# Данный макрос зануляет все элементы буфера по необходимым адресам и используется при реализации непрерывной работы программы.
.macro clear_buf(%obj, %size)
    la t0, %obj
    li t1, %size
clear_loop1:
    beqz t1, fin
    sb zero, (t0)
    addi t0, t0, 1
    addi t1, t1, -1
    j clear_loop1
fin:
.end_macro 


# Макрос создает массив уникальных элементов из строки.
.macro create_array_uniq(%array,%str,%size)
	push(s0)
	push(t0)
	push(t3)
	mv 	s0 %str 
	la 	t0 %array 
loop:   
	
	lb      t3 (s0)         	# очередной символ
        beqz    t3 fin          	# нулевой — конец строки
        
        check_unique(%array, t3, %size)		# Проверка элемента на уникальность
        bnez s11, add_uniq
	addi    s0 s0 1         	# следующий символ
        b       loop
        
add_uniq:
        sb 	t3, (t0)		# Загружаем значение а2 по адресу начала массива 1.							
	addi 	t0, t0, 4		# Сдвигаем адрес в регистре t0 для следующего элемента.
	addi    s0 s0 1         	# следующий символ
	addi 	%size, %size 1		# Увеличиваю текущий размер массива уникальных элементов.
        b       loop
fin:	
	pop(t3)
	pop(t0)
	pop(s0)


.end_macro 


# Макрос, который создает строку разности элементов, сравнивая 2 уникальных массива между собой.

.macro compare(%newstr_buf, %array1,%size1, %array2, %size2)
	push(s0)
	push(t0)
	push(t3)
	push(t2)
	push(t1)
	la s0 %newstr_buf
	la t0 %array1
	mv t2 %size1
	mv t1 zero
loop:   
	
	lb      t3 0(t0)         	# очередной символ
	addi 	t0, t0, 4		# Сдвигаем адрес в регистре t0 для следующего элемента.
        beq 	t2, t1 fin          	# нулевой — конец строки
       	addi 	t1  t1 1
        check_unique(%array2, t3, %size2)		# Проверка элемента на уникальность
        bnez 	s11, update_newstr
        b       loop
        
update_newstr:
        sb 	t3, (s0)		# Загружаем значение а2 по адресу начала массива 1.							
	addi    s0 s0 1         	# следующий символ
        b       loop
fin:
	sb 	zero, 0(s0)          # Завершаем строку символом 0
	pop(t1)
	pop(t2)
	pop(t3)
	pop(t0)
	pop(s0)

.end_macro








