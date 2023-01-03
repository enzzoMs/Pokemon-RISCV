.text

# ====================================================================================================== # 
# 				        CONTROLES E MOVIMENTAÇÃO				         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Código responsável por coordenar os procedimentos de animação do personagem de acordo com as teclas	 #
# W, A, S ou D											         # 
#													 #
# Existem duas modalidades de movimentação diferente, ou a tela se move ou o RED se move, cada um desses #
# acontece dependendo da matriz de tiles da área. Isso acontece porque a área aberta do jogo tem um 	 #
# tamanho maior do que pode ser mostrado na tela (320 x 240), então se a área ainda tem espaço para ser  #
# movida quem se move é ela, senão o RED que se move							 # 															 
#													 #
# Para a movimentação do personagem é utilizado uma matriz para cada área do jogo.			 #
# Cada área é dividida em quadrados de 16 x 16 pixels, de forma que cada elemento dessas matrizes	 #
# representa um desses quadrados. Durante os procedimentos de movimentação a matriz da área		 #
# é consultada e dependendo do valor do elemento referente a próxima posição do personagem é determinado #
# se o jogador pode ou não se mover para lá. Por exemplo, elementos da matriz com valor 0 indicam que    #
# o quadrado 16 x 16 correspondente está ocupado, então o personagem não pode ser mover para lá.	 #
# Cada procedimento de movimentação, seja para cima, baixo, esquerda ou direita, move a tela/RED por  	 #
# exatamente 16 pixels, ou seja, o personagem passa de uma posição da matriz para outra, sendo que o	 #
# registrador s6 vai acompanhar a posição do personagem nessa matriz.  					 #
# 													 #
# ====================================================================================================== #

VERIFICAR_TECLA_MOVIMENTACAO:
	# Este procedimento é responsável por coordenar a movimentação do personagem,
	# ele chama VERIFICAR_TECLA e decide a partir do retorno os procedimentos adequados

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	call VERIFICAR_TECLA
	
	ESCOLHER_PROCEDIMENTO_DE_MOVIMENTACAO:
	
	# Verifica se alguma tecla (a, w, s ou d) foi apertada, chamando o procedimento adequado
		li t0, 'w'
		beq a0, t0, MOVIMENTACAO_TECLA_W
		li t0, 'a'
		beq a0, t0, MOVIMENTACAO_TECLA_A
		li t0, 's'
		beq a0, t0, MOVIMENTACAO_TECLA_S
		li t0, 'd'
		beq a0, t0, MOVIMENTACAO_TECLA_D
	
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #	

MOVIMENTACAO_TECLA_W:
	# Procedimento que coordena a movimentação do personagem para cima
	
	# OBS: não é necessário empilhar o valor de ra pois a chegada a este procedimento é por meio
	# de uma instrução de branch
	
	# Primeiro verifica se o personagem está virado para cima
		li t0, 2
		beq s1, t0, INICIO_MOVIMENTACAO_W
			la a6, red_cima		# carrega como argumento o sprite do RED virada para cima		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s1, 2	# atualiza o valor de s1 dizendo que agora o RED está virado 
					# para cima
							
	INICIO_MOVIMENTACAO_W:
	# Primeiro é preciso verificar a posição acima da atual na matriz de movimentação da área em relação ao
	# personagem (s6). 
	
	sub a0, s6, s7		# verifica a posição uma linha acima (s7 tem o tamanho de uma linha na
				# na matriz) da atual a partir de s6
				
	call VERIFICAR_MATRIZ_DE_MOVIMENTACAO
	
	# Como retorno a0 tem comandos para o procedimento de movimentação.
	# Se a0 == 0 então a movimentação deve ocorrer
	
	bne a0, zero, FIM_MOVIMENTACAO_W
	
	# É necessário decidir se o que vai se mover é a tela ou o personagem
	# O personagem se move se a tela não permitir movimento. No caso da tecla W isso acontece quando o 
	# endereço uma linha acima da área atual de tiles for -1. 
		
	sub t0, s2, s3	# t0 recebe o endereço da linha anterior a s2
	
	lb t0, (t0)	# checa se a matriz da área permite movimento		
		
	li t1, -1				# se t0 for -1 a tela não permite movimento, então o que								
	bne t0, t1, FIM_MOVIMENTACAO_W		# deve se mover é o personagem
	
	
	# Com tudo feito agora começa o procedimento de movimentação para o personagem
	
	li t3, 16		# contador para o número de pixels que o personagem vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
					
	la t4, red_cima		# t4 vai guardar o endereço da próxima imagem do RED
					# o loop de movimentação começa imprimindo a imagem do RED 
					# virado para cima normalmente	
	
	li t5, 0x00100000		# t5 será usada para fazer a troca entre frames no loop de movimentação				
													
	# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
	# de acordo com o valor de s8
		
	la t6, red_cima_passo_direito
							
	beq s8, zero, LOOP_MOVIMENTACAO_W		
		la t6, red_cima_passo_esquerdo
												

	LOOP_MOVIMENTACAO_W:
		addi s0, s0, -320	# decrementa o endereço de s0 (endereço do RED no frame 0) para 
					# a linha anterior
	
		call TROCAR_FRAME		# inverte o frame sendo mostrado
			
		# Primeiro é necessário "limpar" o antigo sprite do RED da tela. Isso é feito imprimindo novamente
		# os dois tiles onde o RED está através de LIMPAR_TILE
		# Como o RED ocupa dois tiles é necessário limpar o tile onde está a cabeça dele (s6)
		# e o tile onde está o corpo (s5 + s3)
				
			# Limpando o tile da cabeça do RED
			mv a4, s5		# o tile a ser limpo é o tile onde o RED está
			li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
			add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# será impressa			
			call LIMPAR_TILE
		
			# Limpando o tile do corpo do RED 
			add a4, s5, s3		# o tile a ser limpo é o tile uma linha abaixo onde o RED está
			li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
			add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# será impressa			
			call LIMPAR_TILE		
								
		PRINT_RED_LOOP_MOVIMENTACAO_W:					
		# Agora imprime a imagem do RED no frame
			mv a0, t4		# t4 tem o endereço da próxima imagem do RED 			
			mv a1, s0		# s0 possui o endereço do RED no frame 0
			add a1, a1, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# será impressa			
			lw a2, 0(a0)		# numero de colunas de uma imagem do RED
			lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG	
						
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
		
		li t0, 0x00100000	# fazendo essa operação xor se t5 for 0 ele recebe 0x0010000
		xor t5, t5, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# trocar entre esses valores
							
		# Determina qual é o próximo sprite do RED a ser renderizado,
		# de modo que a animação siga o seguinte padrão:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		addi t3, t3, -1		# decrementa o número de loops restantes
		
		# t4 vai guardar o endereço da próxima imagem do RED		
		la t4, red_cima
		li t0, 14
		bgt t3, t0, LOOP_MOVIMENTACAO_W
		mv t4, t6				# t6 tem o endereço da imagem do RED dando um passo
		li t0, 2
		bgt t3, t0, LOOP_MOVIMENTACAO_W
		la t4, red_cima
		bne t3, zero, LOOP_MOVIMENTACAO_W
	
	# Pela maneira como os loops acima acontecem o sprite do RED no frame 1 sempre está um pixel abaixo 
	# do sprite no frame 0, para não causar problemas em procedimentos subsequentes é necessário limpar 
	# novamente o tile onde o corpo do RED está no frame 1 
	
		# Limpando o tile do corpo do RED 
		add a4, s5, s3		# o tile a ser limpo é o tile uma linha abaixo onde o RED está
		li a5, 0xFF100000	# a5 recebe o endereço base do frame 1
		call LIMPAR_TILE	
	
	sub s5, s5, s3		# atualizando o lugar do personagem na matriz de tiles para a posição uma linha
				# acima

	sub s6, s6, s7		# atualiza o valor de s6s para o endereço uma linha acima da atual na matriz 
				# de movimentação 
						
	xori s8, s8, 1		# inverte o valor de s6, ou seja, se o RED deu um passo esquerdo o próximo
				# será direito e vice-versa
											
	FIM_MOVIMENTACAO_W:
													
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #

MOVIMENTACAO_TECLA_A:
	# Procedimento que coordena a movimentação do personagem para a esquerda
	
	# OBS: não é necessário empilhar o valor de ra pois a chegada a este procedimento é por meio
	# de uma instrução de branch
	
	# Primeiro verifica se o personagem está virado para a esquerda
		beq s1, zero, INICIO_MOVIMENTACAO_A
			la a6, red_esquerda	# carrega como argumento o sprite do RED virada para a esquerda		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s1, 0	# atualiza o valor de s0 dizendo que agora o RED está virado 
					# para a esquerda
							
	INICIO_MOVIMENTACAO_A:
	# Primeiro é preciso verificar a proxima posição anterior na matriz de movimentação da área em relação ao
	# personagem (s6). 
	
	addi a0, s6, -1		# verifica a posição anterior na matriz a partir de s6
	call VERIFICAR_MATRIZ_DE_MOVIMENTACAO
	
	# Como retorno a0 tem comandos para o procedimento de movimentação.
	# Se a0 == 0 então a movimentação deve ocorrer
	
	bne a0, zero, FIM_MOVIMENTACAO_A
	
	# É necessário decidir se o que vai se mover é a tela ou o personagem
	# O personagem se move se a tela não permitir movimento. No caso da tecla A isso acontece quando o 
	# endereço anterior de s2 (subsecçãõ de tiles atual) for -1	
	
	lb t0, -1(s2)		# checa se a matriz da área permite movimento		
		
	li t1, -1				# se t0 for -1 a tela não permite movimento, então o que								
	bne t0, t1, FIM_MOVIMENTACAO_A		# deve se mover é o personagem
						
	# Com tudo feito agora começa o procedimento de movimentação para o personagem
	
	li t3, 16		# contador para o número de pixels que o personagem vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
					
	la t4, red_esquerda		# t4 vai guardar o endereço da próxima imagem do RED
					# o loop de movimentação começa imprimindo a imagem do RED 
					# virado para a esquerda normalmente	
	
	li t5, 0x00100000		# t5 será usada para fazer a troca entre frames no loop de movimentação				
													
	# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
	# de acordo com o valor de s8
		
	la t6, red_esquerda_passo_direito
							
	beq s8, zero, LOOP_MOVIMENTACAO_A		
		la t6, red_esquerda_passo_esquerdo

	LOOP_MOVIMENTACAO_A:
		addi s0, s0, -1		# decrementa o endereço de s0 (endereço do RED no frame 0) para 
					# a coluna anterior
	
		call TROCAR_FRAME		# inverte o frame sendo mostrado
			
		# Primeiro é necessário "limpar" o antigo sprite do RED da tela. Isso é feito imprimindo novamente
		# os dois tiles onde o RED está através de LIMPAR_TILE
		# Como o RED ocupa dois tiles é necessário limpar o tile onde está a cabeça dele (s6)
		# e o tile onde está o corpo (s5 + s3)
				
			# Limpando o tile da cabeça do RED
			mv a4, s5		# o tile a ser limpo é o tile onde o RED está
			li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
			add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# será impressa			
			call LIMPAR_TILE
		
			# Limpando o tile do corpo do RED 
			add a4, s5, s3		# o tile a ser limpo é o tile uma linha abaixo onde o RED está
			li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
			add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# será impressa			
			call LIMPAR_TILE		
			
			# Como o personagem se move gradualmente, 1 pixel por vez, em determinados momentos
			# ele vai estar entre 4 tiles diferentes, os dois tiles onde ele está e os dois tiles
			# para onde ele vai, portanto depois de um ponto (t3 <= 6) é necessário limpar também
			# os tiles para onde ele está indo		
			li t0, 6
			bgt t3, t0, PRINT_RED_LOOP_MOVIMENTACAO_A
				# Limpando o tile superior para onde o RED vai
				addi a4, s5, -1 	# o tile a ser limpo é o anterior a partir de s5
				li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
				add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a
							# imagem será impressa			
				call LIMPAR_TILE
		
				# Limpando o tile inferior para onde o RED vai
				add a4, s5, s3		# o tile a ser limpo é o tile uma linha abaixo 
				addi a4, a4, -1		# onde o RED está e uma coluna para trás

				li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
				add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a 
							# imagem será impressa			
				call LIMPAR_TILE			
					
					
		PRINT_RED_LOOP_MOVIMENTACAO_A:					
		# Agora imprime a imagem do RED no frame
			mv a0, t4		# t4 tem o endereço da próxima imagem do RED 			
			mv a1, s0		# s0 possui o endereço do RED no frame 0
			add a1, a1, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# será impressa			
			lw a2, 0(a0)		# numero de colunas de uma imagem do RED
			lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG	
						
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
		
		li t0, 0x00100000	# fazendo essa operação xor se t5 for 0 ele recebe 0x0010000
		xor t5, t5, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# trocar entre esses valores
					
		# Determina qual é o próximo sprite do RED a ser renderizado,
		# de modo que a animação siga o seguinte padrão:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		addi t3, t3, -1		# decrementa o número de loops restantes
		
		# t4 vai guardar o endereço da próxima imagem do RED		
		la t4, red_esquerda
		li t0, 14
		bgt t3, t0, LOOP_MOVIMENTACAO_A
		mv t4, t6				# t6 tem o endereço da imagem do RED dando um passo
		li t0, 2
		bgt t3, t0, LOOP_MOVIMENTACAO_A
		la t4, red_esquerda
		bne t3, zero, LOOP_MOVIMENTACAO_A
	
	addi s5, s5, -1		# atualizando o lugar do personagem na matriz de tiles para a posição anterior

	addi s6, s6, -1		# atualiza o valor de s4 para o endereço anterior da matriz de movimentação 
						
	xori s8, s8, 1		# inverte o valor de s6, ou seja, se o RED deu um passo esquerdo o próximo
				# será direito e vice-versa
												
	FIM_MOVIMENTACAO_A:
													
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #

MOVIMENTACAO_TECLA_S:
	# Procedimento que coordena a movimentação do personagem para baixo
	
	# OBS: não é necessário empilhar o valor de ra pois a chegada a este procedimento é por meio
	# de uma instrução de branch
	
	# Primeiro verifica se o personagem está virado para baixo
		li t0, 3
		beq s1, t0, INICIO_MOVIMENTACAO_S
			la a6, red_baixo	# carrega como argumento o sprite do RED virada para baixo		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s1, 3	# atualiza o valor de s1 dizendo que agora o RED está virado 
					# para baixo
							
	INICIO_MOVIMENTACAO_S:
	# Primeiro é preciso verificar a posição abaixo da atual na matriz de movimentação da área em relação ao
	# personagem (s6). 
	
	add a0, s6, s7		# verifica a proxima posição uma linha abaixo (s7 tem o tamanho de uma linha na
				# na matriz) da atual a partir de s6
	call VERIFICAR_MATRIZ_DE_MOVIMENTACAO
	
	# Como retorno a0 tem comandos para o procedimento de movimentação.
	# Se a0 == 0 então a movimentação deve ocorrer
	
	bne a0, zero, FIM_MOVIMENTACAO_S
	
	# É necessário decidir se o que vai se mover é a tela ou o personagem
	# O personagem se move se a tela não permitir movimento. No caso da tecla S isso acontece quando o 
	# endereço uma linha abaixo da área atual de tiles for -1. 
	
	li t0, 15	# t0 recebe o tamanho em tiles de uma linha da área sendo mostrada na tela
	mul t0, s3, t0	# t0 * s3 retorna quantos tiles é necessário pular para encontrar a próxima linha
			# da subsecção de tiles
	
	add t0, t0, s2	# t0 recebe o endereço da próxima linha depois da área atual de tiles que está na tela
	
	lb t0, (t0)	# checa se a matriz da área permite movimento		
		
	li t1, -1				# se t0 for -1 a tela não permite movimento, então o que								
	bne t0, t1, FIM_MOVIMENTACAO_S		# deve se mover é o personagem
								
	# Com tudo feito agora começa o procedimento de movimentação para o personagem
	
	li t3, 16		# contador para o número de pixels que o personagem vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
					
	la t4, red_baixo		# t4 vai guardar o endereço da próxima imagem do RED
					# o loop de movimentação começa imprimindo a imagem do RED 
					# virado para baixo normalmente	
	
	li t5, 0x00100000		# t5 será usada para fazer a troca entre frames no loop de movimentação				
													
	# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
	# de acordo com o valor de s8
		
	la t6, red_baixo_passo_direito
							
	beq s8, zero, LOOP_MOVIMENTACAO_S		
		la t6, red_baixo_passo_esquerdo
												

	LOOP_MOVIMENTACAO_S:
		addi s0, s0, 320	# incrementa o endereço de s0 (endereço do RED no frame 0) para 
					# a próxima linha
	
		call TROCAR_FRAME		# inverte o frame sendo mostrado
			
		# Primeiro é necessário "limpar" o antigo sprite do RED da tela. Isso é feito imprimindo novamente
		# os dois tiles onde o RED está através de LIMPAR_TILE
		# Como o RED ocupa dois tiles é necessário limpar o tile onde está a cabeça dele (s6)
		# e o tile onde está o corpo (s5 + s3)
				
			# Limpando o tile da cabeça do RED
			mv a4, s5		# o tile a ser limpo é o tile onde o RED está
			li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
			add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# será impressa			
			call LIMPAR_TILE
		
			# Limpando o tile do corpo do RED 
			add a4, s5, s3		# o tile a ser limpo é o tile uma linha abaixo onde o RED está
			li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
			add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# será impressa			
			call LIMPAR_TILE		
			
			# Como o personagem se move gradualmente, 1 pixel por vez, em determinados momentos
			# ele vai estar entre 3 tiles diferentes, os dois tiles onde ele está e o tile
			# para onde ele vai, portanto depois de um ponto (t3 <= 6) é necessário limpar também
			# esse tile para onde ele está indo		
			li t0, 6
			bgt t3, t0, PRINT_RED_LOOP_MOVIMENTACAO_S
				# Limpando o tile superior para onde o RED vai
				add a4, s5, s3 		# o tile a ser limpo é o que está duas linhas para 
				add a4, a4, s3 		# baixo de s5				
				li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
				add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a
							# imagem será impressa			
				call LIMPAR_TILE					
					
		PRINT_RED_LOOP_MOVIMENTACAO_S:					
		# Agora imprime a imagem do RED no frame
			mv a0, t4		# t4 tem o endereço da próxima imagem do RED 			
			mv a1, s0		# s0 possui o endereço do RED no frame 0
			add a1, a1, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# será impressa			
			lw a2, 0(a0)		# numero de colunas de uma imagem do RED
			lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG	
						
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
		
		li t0, 0x00100000	# fazendo essa operação xor se t5 for 0 ele recebe 0x0010000
		xor t5, t5, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# trocar entre esses valores
					
					
		# Determina qual é o próximo sprite do RED a ser renderizado,
		# de modo que a animação siga o seguinte padrão:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		addi t3, t3, -1		# decrementa o número de loops restantes
		
		# t4 vai guardar o endereço da próxima imagem do RED		
		la t4, red_baixo
		li t0, 14
		bgt t3, t0, LOOP_MOVIMENTACAO_S
		mv t4, t6				# t6 tem o endereço da imagem do RED dando um passo
		li t0, 2
		bgt t3, t0, LOOP_MOVIMENTACAO_S
		la t4, red_baixo
		bne t3, zero, LOOP_MOVIMENTACAO_S

	add s5, s5, s3		# atualizando o lugar do personagem na matriz de tiles para a posição uma linha
				# abaixo

	add s6, s6, s7		# atualiza o valor de s4 para o endereço uma linha abaixo da atual na matriz 
				# de movimentação 
						
	xori s8, s8, 1		# inverte o valor de s6, ou seja, se o RED deu um passo esquerdo o próximo
				# será direito e vice-versa
											
	FIM_MOVIMENTACAO_S:

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret	

# ====================================================================================================== #

MOVIMENTACAO_TECLA_D:
	# Procedimento que coordena a movimentação do personagem para a direita
	
	# OBS: não é necessário empilhar o valor de ra pois a chegada a este procedimento é por meio
	# de uma instrução de branch
	
	# Primeiro verifica se o personagem está virado para a direita
		li t0, 1
		beq s1, t0, INICIO_MOVIMENTACAO_D
			la a6, red_direita	# carrega como argumento o sprite do RED virada para a direita		
			call MUDAR_ORIENTACAO_PERSONAGEM

			li s1, 1	# atualiza o valor de s1 dizendo que agora o RED está virado 
					# para a direita	
					
	INICIO_MOVIMENTACAO_D:																																				
	# Primeiro é preciso verificar a proxima posição da matriz de movimentação da área em relação ao
	# personagem (s6). 
	
	addi a0, s6, 1		# verifica a proxima posição na matriz a partir de s6
	call VERIFICAR_MATRIZ_DE_MOVIMENTACAO
	
	# Como retorno a0 tem comandos para o procedimento de movimentação.
	# Se a0 == 0 então a movimentação deve ocorrer
	
	bne a0, zero, FIM_MOVIMENTACAO_D
	
	# É necessário decidir se o que vai se mover é a tela ou o personagem
	# O personagem se move se a tela não permitir movimento. No caso da tecla D isso acontece quando o 
	# próximo endereço de s2 (subsecçãõ de tiles atual) + 20 (largura em tiles da área sendo mostrada na tela) 
	# for -1	
	
	lb t0, 20(s2)		# checa se a matriz da área permite movimento		
		
	li t1, -1				# se t0 for -1 a tela não permite movimento, então o que								
	bne t0, t1, FIM_MOVIMENTACAO_D		# deve se mover é o personagem
	
								
	# Com tudo feito agora começa o procedimento de movimentação para o personagem
																						
	li t3, 16		# contador para o número de pixels que o personagem vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
					
	la t4, red_direita		# t4 vai guardar o endereço da próxima imagem do RED
					# o loop de movimentação começa imprimindo a imagem do RED 
					# virado para a direita normalmente	
	
	li t5, 0x00100000		# t5 será usada para fazer a troca entre frames no loop de movimentação				
													
	# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
	# de acordo com o valor de s8
		
	la t6, red_direita_passo_direito
							
	beq s8, zero, LOOP_MOVIMENTACAO_D		
		la t6, red_direita_passo_esquerdo
																											
	LOOP_MOVIMENTACAO_D:
		addi s0, s0, 1		# incrementa o endereço de s0 (endereço do RED no frame 0) para 
					# a próxima coluna
	
		call TROCAR_FRAME		# inverte o frame sendo mostrado
			
		# Primeiro é necessário "limpar" o antigo sprite do RED da tela. Isso é feito imprimindo novamente
		# os dois tiles onde o RED está através de LIMPAR_TILE
		# Como o RED ocupa dois tiles é necessário limpar o tile onde está a cabeça dele (s6)
		# e o tile onde está o corpo (s5 + s3)
				
			# Limpando o tile da cabeça do RED
			mv a4, s5		# o tile a ser limpo é o tile onde o RED está
			li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
			add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# será impressa			
			call LIMPAR_TILE
		
			# Limpando o tile do corpo do RED 
			add a4, s5, s3		# o tile a ser limpo é o tile uma linha abaixo onde o RED está
			li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
			add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# será impressa			
			call LIMPAR_TILE		
			
			# Como o personagem se move gradualmente, 1 pixel por vez, em determinados momentos
			# ele vai estar entre 4 tiles diferentes, os dois tiles onde ele está e os dois tiles
			# para onde ele vai, portanto depois de um ponto (t3 <= 6) é necessário limpar também
			# os tiles para onde ele está indo		
			li t0, 6
			bgt t3, t0, PRINT_RED_LOOP_MOVIMENTACAO_D
				# Limpando o tile superior para onde o RED vai
				addi a4, s5, 1 		# o tile a ser limpo é próximo a partir de s5
				li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
				add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a
							# imagem será impressa			
				call LIMPAR_TILE
		
				# Limpando o tile inferior para onde o RED vai
				add a4, s5, s3		# o tile a ser limpo é o tile uma linha abaixo 
				addi a4, a4, 1		# onde o RED está e uma coluna a frente

				li a5, 0xFF000000	# a5 recebe o endereço base do frame 0
				add a5, a5, t5		# decide a partir do valor de t5 qual o frame onde a 
							# imagem será impressa			
				call LIMPAR_TILE			
					
					
		PRINT_RED_LOOP_MOVIMENTACAO_D:					
		# Agora imprime a imagem do RED no frame
			mv a0, t4		# t4 tem o endereço da próxima imagem do RED 			
			mv a1, s0		# s0 possui o endereço do RED no frame 0
			add a1, a1, t5		# decide a partir do valor de t5 qual o frame onde a imagem
						# será impressa			
			lw a2, 0(a0)		# numero de colunas de uma imagem do RED
			lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG	
						
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
		
		li t0, 0x00100000	# fazendo essa operação xor se t5 for 0 ele recebe 0x0010000
		xor t5, t5, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# trocar entre esses valores
					
		# Determina qual é o próximo sprite do RED a ser renderizado,
		# de modo que a animação siga o seguinte padrão:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		addi t3, t3, -1		# decrementa o número de loops restantes
		
		
		# t4 vai guardar o endereço da próxima imagem do RED		
		la t4 red_direita
		li t0, 14
		bgt t3, t0, LOOP_MOVIMENTACAO_D
		mv t4, t6				# t6 tem o endereço da imagem do RED dando um passo
		li t0, 2
		bgt t3, t0, LOOP_MOVIMENTACAO_D
		la t4, red_direita
		bne t3, zero, LOOP_MOVIMENTACAO_D
	
	addi s5, s5, 1		# atualizando o lugar do personagem na matriz de tiles para a próxima posição

	addi s6, s6, 1		# atualiza o valor de s4 para o proximo endereço da matriz de movimentação 
						
	xori s8, s8, 1		# inverte o valor de s6, ou seja, se o RED deu um passo esquerdo o próximo
				# será direito e vice-versa
							
	FIM_MOVIMENTACAO_D:
													
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #									

MUDAR_ORIENTACAO_PERSONAGEM:
	# Procedimento que muda a orientação do personagem a depender do argumento, ou seja,
	# imprime o sprite do RED em uma determinada orientação.
	# OBS: O procedimento não altera o valor de s1, apenas imprime o sprite em uma orientação
	# Argumentos:
	# 	 a6 = endereço base da imagem do RED na orientação desejada
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
			
	# Primeiro é necessário "limpar" o antigo sprite do RED da tela. Isso é feito imprimindo novamente
	# os dois tiles onde o RED está através de LIMPAR_TILE
	# Como o RED ocupa dois tiles é necessário limpar o tile onde está a cabeça dele (s6)
	# e o tile onde está o corpo (s5 + s3)
		
		# Limpando o tile da cabeça do RED
		mv a4, s5		# o tile a ser limpo é o tile onde o RED está
		li a5, 0xFF000000	# o tile a ser limpo está no frame 0
		call LIMPAR_TILE
		
		# Limpando o tile do corpo do RED 
		add a4, s5, s3		# o tile a ser limpo é o tile uma linha abaixo onde o RED está
		li a5, 0xFF000000	# o tile a ser limpo está no frame 0
		call LIMPAR_TILE		
				
	# Agora imprime a imagem do RED virado para a direita no frame 0
		mv a0, a6		# a6 tem o endereço da imagem a ser impressa
		mv a1, s0		# s0 possui o endereço do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
		
	call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 0
							
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
	
	
# ====================================================================================================== #									

VERIFICAR_MATRIZ_DE_MOVIMENTACAO:
	# Procedimento auxiliar aos procedimentos de movimentação acima.
	# Tem como objetivo receber um endereço de uma matriz de movimentação e partir do valor desse
	# elemento decidir quais procedimentos tem quer ser chamados, como procedimentos de transição
	# de área por exemplo, no fim retorna o controle para o procedimento de movimentação que o chamou
	# Em certos casos o ideal é que não ocorra uma movimentação do personagem, ou que certas ações aconteçam
	# depois da movimentação, por isso também é retornado a0 com algum valor correpondente a um comando 
	# para os procedimentos de movimentação, como explicado abaixo:
	# Argumentos:
	# 	a0 = endereço de uma matriz de movimentação
	# 
	# Retorno:
	#	a0 = -1 se os procedimentos de movimentação NÃO devem acontecer
	#	a0 = 0 se os procedimentos de movimentação DEVEM acontecer
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	lbu t0, (a0)		# le o valor do endereço da matriz de movimentação

	# se t0 == -1 então essa posição da matriz está ocupada e a movimentação não deve ocorrer
	li a0, -1			
	beq t0, zero, FIM_VERIFICAR_MATRIZ_DE_MOVIMENTACAO

	# se t0 == 1 então essa posição da matriz está livre e a movimentação deve ocorrer	
	li a0, 0	
	li t1, 1					
	beq t0, t1, FIM_VERIFICAR_MATRIZ_DE_MOVIMENTACAO
	
	# se t0 >= 32 então essa posição indica uma transição entre área, nesse caso RENDERIZAR_AREA tem
	# que ser chamado e depois os procedimentos de movimentação devem ocorrer
	
	li t1, 32						
	blt t0, t1, FIM_VERIFICAR_MATRIZ_DE_MOVIMENTACAO
		mv a4, t0		# move para o argumento a4 o valor da posição sendo analisada
		call RENDERIZAR_AREA												
		li a0, 0		# a0 = 0 porque a movimentação tem que acontecer
																										
	FIM_VERIFICAR_MATRIZ_DE_MOVIMENTACAO:				

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret

# ====================================================================================================== #									

.data
	.include "../Imagens/red/red_direita.data"
	.include "../Imagens/red/red_direita_passo_esquerdo.data"
	.include "../Imagens/red/red_direita_passo_direito.data"
	.include "../Imagens/red/red_cima.data"
	.include "../Imagens/red/red_cima_passo_esquerdo.data"
	.include "../Imagens/red/red_cima_passo_direito.data"	
	.include "../Imagens/red/red_baixo.data"
	.include "../Imagens/red/red_baixo_passo_esquerdo.data"
	.include "../Imagens/red/red_baixo_passo_direito.data"	
	.include "../Imagens/red/red_esquerda.data"
	.include "../Imagens/red/red_esquerda_passo_esquerdo.data"
	.include "../Imagens/red/red_esquerda_passo_direito.data"	
