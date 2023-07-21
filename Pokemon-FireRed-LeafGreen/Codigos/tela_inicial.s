.text

# ====================================================================================================== # 
# 						TELA INICIAL				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Código responsável por renderizar a tela inicial do jogo e música			                 # 
#													 #
# ====================================================================================================== #


INICIALIZAR_TELA_INICIAL:

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, 0(sp)		# empilha ra

	call PRINT_TELA_INICIAL
	
	LOOP_MUSICA_TELA_INICIAL:
		call MUSICA
		
		# se o retorno a0 == 0 reinicia a musica
		beq a0, zero, LOOP_MUSICA_TELA_INICIAL
	
		
	# Mostra o frame 0	
	li t0, 0xFF200604		# t0 = endereço para escolher frames 
	sb zero, (t0)			# armazena 0 no endereço de t0
			
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
	

# ======================================================================================================= #

PRINT_TELA_INICIAL:
	# Procedimento que renderiza a tela inicial
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Mostra o frame 1	
	li t0, 0xFF200604		# t0 = endereço para escolher frames 
	li t1, 1
	sb t1, (t0)			# armazena 1 no endereço de t0
		
	# Imprimindo o fundo da tela no frame 0
	la a0, matriz_tiles_menu_inicial	# carrega a matriz de tiles da intro
	la a1, tiles_menu_inicial		# carrega a imagem com os tiles da intro
	li a2, 0xFF000000			# os tiles serão impressos no frame 0
	call PRINT_TILES 

	# Imprimindo a imagem do pikachu no frame 0
		# Calculando o endereço de onde imprimir a imagem
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 141		# numero da coluna 
		li a3, 71		# numero da linha
		call CALCULAR_ENDERECO	
				
		mv a1, a0		# move o retorno para a1		
				
		# Imprimindo a imagem do pikachu
		la a0, menu_inicial_pikachu	# carrega a imagem		
		# a1 já tem o endereço de onde imprimir a imagem
		lw a2, 0(a0)		# numero de colunas da imagem 
		lw a3, 4(a0)		# numero de linhas daa imagem 	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
	
	# Imprimindo o texto de aperte enter no frame 0
		# Calculando o endereço de onde imprimir a imagem
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 127		# numero da coluna 
		li a3, 193		# numero da linha
		call CALCULAR_ENDERECO	
				
		mv t6, a0		# move o retorno para t6		
				
		# Imprimindo a imagem do texto
		la a0, menu_inicial_texto_aperte_enter	# carrega a imagem		
		mv a1, t6 		# t6 tem o endereço de onde imprimir a imagem
		lw a2, 0(a0)		# numero de colunas da imagem 
		lw a3, 4(a0)		# numero de linhas daa imagem 	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
					
	call TROCAR_FRAME	# inverte o frame sendo mostrado, mostrando o frame 0																																																																																																					
	
	# Replica o frame 0 no frame 1 para que os dois estejam iguais
	li a0, 0xFF000000	# copia o frame 0 no frame 1
	li a1, 0xFF100000
	li a2, 320		# numero de colunas a serem copiadas
	li a3, 240		# numero de linhas a serem copiadas
	call REPLICAR_FRAME	
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																					
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
				
	ret

# ======================================================================================================= #

MUSICA:
	# Dá play na musica da tela inicial e espera o jogador apertar ENTER
	#
	# Retorno:
	#	a0 = [ 0 ] caso o jogador não apertou ENTER e 1 caso contrario 
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	

	la t6, NUM_NOTAS_MUSICA	# define o endereço do número de notas
	lw t5, 0(t6)		# le o numero de notas
	la t6, NOTAS_MUSICA	# define o endereço das notas
	li t2, 0		# zera o contador de notas
	li a2, 68		# define o instrumento
	li a3, 127		# define o volume

LOOP_MUSICA:	
	lw a0, 0(t6)		# le o valor da nota
	lw a1, 4(t6)		# le a duracao da nota
	li a7, 31		# define a chamada de syscall
	ecall			# toca a nota
	mv a0, a1		# passa a duração da nota para a pausa
	li a7, 32		# define a chamada de syscal 
	ecall			# realiza uma pausa de a0 ms
	addi t6, t6, 8		# incrementa para o endereço da próxima nota
	addi t2, t2, 1		# incrementa o contador de notas
	
	# Verifica se apertou ENTER
	call VERIFICAR_TECLA
	
	mv t1, a0		# move o retorno para t1		
	li t0, 10			# 10 é o codigo do ENTER
	li a0, 1			# a0 = 1 porque o jogador apertou ENTER		
	beq t1, t0, FIM_MUSICA

	li a0, 0			# a0 = 0 porque o jogador nao apertou ENTER
	bne t2, t5, LOOP_MUSICA		# contador chegou no final? então vá para FIM
			
FIM_MUSICA:	

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
				
	ret
			

