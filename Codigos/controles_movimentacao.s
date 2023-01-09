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

	sub s6, s6, s7		# atualiza o valor de s6 para o endereço uma linha acima da atual na matriz 
				# de movimentação 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o próximo
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

	addi s6, s6, -1		# atualiza o valor de s6 para o endereço anterior da matriz de movimentação 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o próximo
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
	bne t0, t1, MOVER_TELA_S		# deve se mover é o personagem
								
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

	add s6, s6, s7		# atualiza o valor de s6 para o endereço uma linha abaixo da atual na matriz 
				# de movimentação 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o próximo
				# será direito e vice-versa
					
	j FIM_MOVIMENTACAO_S									
		
	# -------------------------------------------------------------------------------------------------																				
	
	MOVER_TELA_S:
	# Caso a tela ainda permita movimento é ela que tem que se mover
	# O movimento da tela tem como base o loop abaixo, que tem 4 partes: 
	#	(1) -> move toda a imagem da área que está na tela em um 1 pixel para cima
	#	(2) -> limpar o sprite antigo do RED do frame
	#  	(3) -> imprime os sprites de movimentação do RED
	#	(4) -> imprime a próxima linha da subsecção da área 1 pixel para cima
	# Com esses passos é possível passar a sensação de que a tela está se movendo para cima e revelando
	# uma nova parte da área
	
	li t5, 1		# contador para o número de loops realizados
	li t6, 0x00100000	# t6 será usado para fazer a troca entre frames no loop abaixo	
	
	LOOP_MOVER_TELA_S:
				
		# Parte (1) -> move toda a imagem da área que está na tela em um 1 pixel para cima
		# Para fazer isso é possível simplesmente trocar os pixels de uma linha do frame com os pixels
		# da linha anterior através do loop abaixo
		
		li t0, 240		# número de linhas de um frame, ou seja, a quantidade de loops abaixo
		sub t0, t0, t5		# o número de loops é controlado pelo número da iteração atual (t5)
		
		li t1, 0xFF000140	# endereço da linha 1 do frame 0
		
		# Na primeira iteração (t5 == 1) a troca de pixels do frame vai acontecer a partir da 1a linha
		# (0xFF000140), mas nas próximas a troca vai acontecer a partir da 2a linha (0xFF000280) 
		# porque a troca vai ser alternada entre os frame 0 e 1
		    
		li t2, 1
		beq t5, t2, INICIO_MOVER_TELA_S
			li t1, 0xFF000280		# endereço da linha 2 do frame 0
				
		INICIO_MOVER_TELA_S:
		
		add t1, t1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# será impressa	
								
		MOVER_TELA_S_LOOP_LINHAS:
			li t2, 320		# número de colunas de um frame
			
		MOVER_TELA_S_LOOP_COLUNAS:		
			lw t3, 0(t1)		# pega 4 pixels do bitmap e coloca em t3
			
			# Na 1a iteração os pixels serão armazenados na linha anterior (-320), mas nas 
			# iterações seguintes serão armzenados 2 linhas para trás (-640)
			
			li t4, 1
			beq t5, t4, MOVER_TELA_S_PRIMEIRA_ITERACAO
				sw t3, -640(t1)	# armazena os 4 pixels de t5 na 2 linhas para trás (-640) do 
						# endereço apontado por t1
				j MOVER_TELA_S_PROXIMA_ITERACAO	
				
			MOVER_TELA_S_PRIMEIRA_ITERACAO:	
			sw t3, -320(t1)		# armazena os 4 pixels de t5 na linha anterior (-320) ao endereço
						# apontado por t1
						
			MOVER_TELA_S_PROXIMA_ITERACAO:
			addi t1, t1, 4		# passa o endereço do bitmap para os próximos pixels
			addi t2, t2, -4		# decrementa o número de colunas restantes
			bne t2, zero, MOVER_TELA_S_LOOP_COLUNAS		# reinicia o loop se t2 != 0    
		
		addi t0, t0, -1			# decrementa o número de linhas restantes
		bne t0, zero, MOVER_TELA_S_LOOP_LINHAS	# reinicia o loop se t0 != 0 
		
		# Parte (2) -> limpar o sprite antigo do RED do frame
		# Para limpar os sprites antigos é possível usar o PRINT_TILES (o LIMPAR_TILE não funciona
		# porque ele não permite imprimir os tiles em endereços arbitrários) imprimindo 1 coluna
		# 3 linhas (2 tiles do RED + 1 tile de folga)
		
		mv a4, s5	# endereço, na matriz de tiles, de onde começam os tiles a ser impressos,
				# nesse caso, o começo é o tile onde o RED está
		mv a5, s0	# a imagem será impressa onde o RED está (s0)
		
		li t0, 4161	# o endereço do RED na verdade está um pouco abaixo do inicio do tile,
		sub a5, a5, t0	# portanto é necessário voltar o endereço de a5 em 4164 pixels (13 linhas * 
				# 320 + 1 coluna)
		
		li t0, 320	# o endereço de onde os tiles vão ser impressos também muda de acordo com a
		mul t0, t0, t5	# iteração, já que o pixels da tela serão trocados para fazer a imagem "subir"
		sub a5, a5, t0	# portanto, 320 * t5 retorna quantos pixels é necessário voltar para encontrar
				# a linha certa onde devem ser impressos os tiles nessa iteração
		
		add a5, a5, t6		# decide a partir do valor de t6 qual o frame onde os tiles
					# será impressa	
					
		li a6, 1		# número de colunas de tiles a serem impressas
		li a7, 3		# número de linhas de tiles a serem impressas
		call PRINT_TILES
		
		# Parte (3) -> imprime o sprite do RED
		# O próximo sprite do RED vai ser decidido de acordo com o número da interação (t3)
		# de modo que a animação siga o seguinte padrão:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		# a0 vai receber o endereço da próxima imagem do RED dependendo do número da iteração (t5)	
		la a0, red_baixo
		li t0, 14
		bgt t5, t0, PRINT_RED_MOVER_TELA_S
		
		# Se 2 < t5 <= 14 a imagem a ser impressa é a do RED dando um passo, que é decidida a 
		# partir do valor de s8
		la a0, red_baixo_passo_direito
							
		beq s8, zero, PROXIMO_RED_MOVER_TELA_S		
			la a0, red_baixo_passo_esquerdo
	
		PROXIMO_RED_MOVER_TELA_S:
		
		li t0, 2
		bgt t5, t0, PRINT_RED_MOVER_TELA_S
		la a0, red_baixo
		
		PRINT_RED_MOVER_TELA_S:					
		# Agora imprime a imagem do RED no frame
			# a0 tem o endereço da próxima imagem do RED 			
			mv a1, s0		# s0 possui o endereço do RED no frame 0
			add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
						# será impressa		
			lw a2, 0(a0)		# numero de colunas de uma imagem do RED
			lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG	
		
		# Parte (4) -> imprime a próxima linha da subsecção da área 1 pixel para cima
		# O que tem que ser feito é imprimir os tiles dessa linha de modo que só vão ser impressas uma 
		# parte da imagem de cada tile de forma a dar a impressão de que a linha subiu 1 pixel e que
		# uma nova parte da área está sendo lentamente revelada
						
		li t3, 0		# contador para o número de tiles impressos
		li t4, 0xFF012AC0	# t4 vai guardar o endereço de onde os tiles vão ser impressos, sendo
					# que ele é incrementado a cada loop abaixo. Esse endereço aponta
					# para o começo da última linha do frame 0
		add t4, t4, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# será impressa		
							
		LOOP_PRINT_PROXIMA_AREA_S:
		
		# Encontrando a imagem do tile	
		li t0, 15		# 15 é o nmúmero de linhas de tiles da subsecção da área que está na tela
		mul t0, t0, s3		# s3 * 15 retorna quantos elementos é necessário pular na matriz de tiles
		add t0, s2, t0		# para encontrar o endereço de início da próxima linha da subsecção de
					# tiles que está na tela
			
		add t0, t0, t3	# decide qual o tile a ser impresso de acordo com t3 (número da iteração atual)
		
		lb t0, 0(t0)	# pega o valor do elemento da matriz de tiles apontado por t0
		
		li t1, 256	# t1 recebe 16 * 16 = 256, ou seja, a área de um tile							
		mul t0, t0, t1	# t0 (número do tile) * (16 * 16) retorna quantos pixels esse tile está do 
				# começo da imagem dos tiles
				
		# Imprimindo a imagem do tile		
		add a0, s4, t0	# a0 recebe o endereço do tile a ser impresso a partir de s4 (imagem dos tiles)
		
		mv a1, t4	# a1 recebe o endereço de onde imprimir o tile
		li t0, 320	# t0 tem o tamanho de uma linha do frame
		mul t0, t0, t5	# 320 * t5 (número da iteração atual) retorna quantos pixels é necessário voltar
		sub a1, a1, t0	# para encontrar o endereço de onde imprimir os tiles
				
		li a2, 16	# a2 = numero de colunas de um tile
		addi a3, t5, 1	# a3 tem o número de linhas a serem impressas = o valor de t5 (iteração atual)
				# + 1 porque t5 começa no 1 e não no 0
		call PRINT_IMG
	
		addi t4, t4, 16		# incrementando o endereço onde os tiles vão ser impressos em 16 pixels
					# porque o tile que acabou de ser impresso tem 16 colunas
		addi t3, t3, 1		# incrementando o número de tiles impressos
		
		li t0, 20
		bne t3, t0, LOOP_PRINT_PROXIMA_AREA_S	# reinicia o loop se t3 != 20
		
	
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP	
		
		call TROCAR_FRAME	# inverte o frame sendo mostrado		
				
		li t0, 0x00100000	# fazendo essa operação xor se t4 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# trocar entre esses valores
		
		addi t5, t5, 1		# incrementa o número de loops realizados						
		li t0, 16
		bne t5, t0, LOOP_MOVER_TELA_S	# reinicia o loop se t3 != 16
	
																																																																																																															
	add s2, s2, s3		# atualizando a subsecção da área para uma linha abaixo da atual (s2) 
	
	# Pela maneira que o loop acima é executado na verdade só são feitas 15 iterações e não 16, 
	# portanto, é necessário imprimir novamente as imagem da área em ambos os frames + o sprite do RED 
	# no frame 0 para que tudo fique no lugar certo
		
		# Imprimindo a imagem da área no frame 0
		mv a4, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a5, 0xFF000000	# a imagem será impressa no frame 0
		li a6, 20		# número de colunas de tiles a serem impressas
		li a7, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES	

		# Imprimindo o sprite do RED no frame 0
		la a0, red_baixo	# carrega a imagem do sprite			
		mv a1, s0		# s0 tem a posição do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	

	call TROCAR_FRAME	# inverte o frame sendo mostrado
				# é necessário inverter o frame mais 1 vez para que o frame sendo mostrado
				# seja o 0		
					
		# Imprimindo a imagem da área no frame 1
		mv a4, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a5, 0xFF100000	# a imagem será impressa no frame 0
		li a6, 20		# número de colunas de tiles a serem impressas
		li a7, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES			
						
	add s5, s5, s3		# atualizando o lugar do personagem na matriz de tiles para a posição uma linha
				# abaixo

	add s6, s6, s7		# atualiza o valor de s6 para o endereço uma linha abaixo da atual na matriz 
				# de movimentação 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o próximo
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
	bne t0, t1, MOVER_TELA_D		# deve se mover é o personagem
	
								
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

	addi s6, s6, 1		# atualiza o valor de s6 para o proximo endereço da matriz de movimentação 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o próximo
				# será direito e vice-versa
	
	j FIM_MOVIMENTACAO_D									
		
	# -------------------------------------------------------------------------------------------------																				
	
	MOVER_TELA_D:
	# Caso a tela ainda permita movimento é ela que tem que se mover
	# O movimento da tela tem como base o loop abaixo, que tem 4 partes: 
	#	(1) -> move toda a imagem da área que está na tela em um 1 pixel para a esquerda
	#	(2) -> limpar o sprite antigo do RED do frame
	#  	(3) -> imprime os sprites de movimentação do RED
	#	(4) -> imprime a próxima coluna da subsecção da área 1 pixel para a esquerda
	# Com esses passos é possível passar a sensação de que a tela está se movendo para a esquerda e revelando
	# uma nova parte da área
	
	li t5, 1		# contador para o número de loops realizados
	li t6, 0x00100000	# t6 será usado para fazer a troca entre frames no loop abaixo	
	
	LOOP_MOVER_TELA_D:
				
		# Parte (1) -> move toda a imagem da área que está na tela em um 1 pixel para a esquerda
		# Para fazer isso é possível simplesmente trocar os pixels de uma coluna do frame com os pixels
		# da coluna anterior através do loop abaixo
		
		li t0, 240		# número de linhas de um frame, ou seja, a quantidade de loops abaixo
		
		li t1, 0xFF000001	# endereço da coluna 1 do frame 0
		
		# Na primeira iteração (t5 == 1) a troca de pixels do frame vai acontecer a partir da 1a coluna
		# (0xFF000001), mas nas próximas a troca vai acontecer a partir da 2a coluna (0xFF000002) 
		# porque a troca vai ser alternada entre os frame 0 e 1
		    
		li t2, 1
		beq t5, t2, INICIO_MOVER_TELA_D
			li t1, 0xFF000002		# endereço da coluna 2 do frame 0
				
		INICIO_MOVER_TELA_D:
		
		add t1, t1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# será impressa	
								
		MOVER_TELA_D_LOOP_LINHAS:
			li t2, 320	# número de colunas de um frame
			sub t2, t2, t5	# o número de loops é controlado pelo número da iteração atual (t5)
			
		MOVER_TELA_D_LOOP_COLUNAS:		
			lb t3, 0(t1)		# pega 1 pixel do bitmap e coloca em t3
			
			# Na 1a iteração os pixels serão armazenados na coluna anterior (-1), mas nas 
			# iterações seguintes serão armzenados 2 colunas para trás (-2)
			
			li t4, 1
			beq t5, t4, MOVER_TELA_D_PRIMEIRA_ITERACAO
				sb t3, -2(t1)	# armazena o pixel de t5 na 2 colunas para trás (-2) do 
						# endereço apontado por t1
				j MOVER_TELA_D_PROXIMA_ITERACAO	
				
			MOVER_TELA_D_PRIMEIRA_ITERACAO:	
			sb t3, -1(t1)		# armazena o pixel de t5 na colunas anterior (-1) ao endereço
						# apontado por t1
						
			MOVER_TELA_D_PROXIMA_ITERACAO:
			addi t1, t1, 1		# passa o endereço do bitmap para o próximo pixel
			addi t2, t2, -1		# decrementa o número de colunas restantes
			bne t2, zero, MOVER_TELA_D_LOOP_COLUNAS		# reinicia o loop se t2 != 0    
		
		add t1, t1, t5		# O loop acima só é feito 320 - t5 vezes, portanto o endereço
					# de t1 precisa ser atualizado pelas t5 colunas não impressas	
		addi t0, t0, -1			# decrementa o número de linhas restantes
		bne t0, zero, MOVER_TELA_D_LOOP_LINHAS	# reinicia o loop se t0 != 0 
		
		# Parte (2) -> limpar o sprite antigo do RED do frame
		# Para limpar os sprites antigos é possível usar o PRINT_TILES (o LIMPAR_TILE não funciona
		# porque ele não permite imprimir os tiles em endereços arbitrários) imprimindo 1 coluna e
		# 2 linhas (2 tiles onde o RED está + 2 tiles de folga) 
		
		mv a4, s5	# endereço, na matriz de tiles, de onde começam os tiles a ser impressos,
				# nesse caso, o começo é o tile onde o RED está
		mv a5, s0	# a imagem será impressa onde o RED está (s0)
		
		li t0, 4161	# o endereço do RED na verdade está um pouco abaixo do inicio do tile,
		sub a5, a5, t0	# portanto é necessário voltar o endereço de a5 em 4164 pixels (13 linhas * 
				# 320 + 1 coluna)
		
		sub a5, a5, t5	# o endereço de onde os tiles vão ser impressos também muda de acordo com a
				# iteração, já que o pixels da tela serão trocados para fazer a imagem se "mover"
				# a5 - t5 volta a5 para a coluna certa onde os tiles devem ser impressos
		
		add a5, a5, t6		# decide a partir do valor de t6 qual o frame onde os tiles
					# será impressa	
					
		li a6, 2		# número de colunas de tiles a serem impressas
		li a7, 2		# número de linhas de tiles a serem impressas
		call PRINT_TILES
		
		# Parte (3) -> imprime o sprite do RED
		# O próximo sprite do RED vai ser decidido de acordo com o número da interação (t3)
		# de modo que a animação siga o seguinte padrão:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		# a0 vai receber o endereço da próxima imagem do RED dependendo do número da iteração (t5)	
		la a0, red_direita
		li t0, 14
		bgt t5, t0, PRINT_RED_MOVER_TELA_D
		
		# Se 2 < t5 <= 14 a imagem a ser impressa é a do RED dando um passo, que é decidida a 
		# partir do valor de s8
		la a0, red_direita_passo_direito
							
		beq s8, zero, PROXIMO_RED_MOVER_TELA_D		
			la a0, red_direita_passo_esquerdo
	
		PROXIMO_RED_MOVER_TELA_D:
		
		li t0, 2
		bgt t5, t0, PRINT_RED_MOVER_TELA_D
		la a0, red_direita
		
		PRINT_RED_MOVER_TELA_D:					
		# Agora imprime a imagem do RED no frame
			# a0 tem o endereço da próxima imagem do RED 			
			mv a1, s0		# s0 possui o endereço do RED no frame 0
			add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
						# será impressa		
			lw a2, 0(a0)		# numero de colunas de uma imagem do RED
			lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG	
		
		# Parte (4) -> imprime a próxima coluna da subsecção da área 1 pixel para a esquerda
		# O que tem que ser feito é imprimir os tiles dessa coluna de modo que só vão ser impressas uma 
		# parte da imagem de cada tile de forma a dar a impressão de que a coluna voltou 1 pixel e que
		# uma nova parte da área está sendo lentamente revelada
		
		# O procedimento PRINT_IMG tem uma limitação: ele não é capaz de imprimir partes de imagens se
		# essas partes tem um número de colunas diferente da imagem completa, por exemplo: imprimir 
		# uma parte 6 x 15 de uma imagem 10 x 15, para imprimir uma parte de imagem é necessário que essa 
		# parte tenha o mesmo número de colunas que a imagem original 				
		# Essa limitação dificulta essa parte do procedimneto, portanto a abordagem será diferente:
		# Para cada 1 dos 20 tiles da coluna serão impressas individualmente as 16 linhas do tile
																														
		li t3, 0		# contador para o número de tiles impressos
						
		LOOP_TILES_PROXIMA_AREA_D:
		
		li t4, 0		# contador para o número de linhas de cada tile impressas

		LOOP_LINHAS_PROXIMA_AREA_D:	
					
		# Encontrando a imagem do tile	
		addi t0, s2, 20		# s2 + 20 retorna o endereço de início da próxima coluna da
					# subsecção de tiles que está na tela (20 é o tamanho de uma linha de 
					# tiles que é mostrada na tela)
		
		mul t1, s3, t3		# decide qual o tile da coluna que será impresso de acordo com 
		add t0, t0, t1		# t3 (número do tile atual)		
		
		lb t0, 0(t0)	# pega o valor do elemento da matriz de tiles apontado por t0
			
		li t1, 256	# t1 recebe 16 * 16 = 256, ou seja, a área de um tile							
		mul t0, t0, t1	# t0 (número do tile) * (16 * 16) retorna quantos pixels esse tile está do 
				# começo da imagem dos tiles
		
		li t1, 16	# decide qual a linha do tile que será impressa de acordo com 
		mul t1, t1, t4	# t4 (número da linha atual do tile)	
		add t0, t0, t1		
												
		# Imprimindo a imagem do tile		
		add a0, s4, t0	# a0 recebe o endereço do tile a ser impresso a partir de s4 (imagem dos tiles)
		
		li t0, 0xFF000140	# t0 recebe o endereço do último pixel da primaira linha do frame 0,
					# ou seja, onde o 1o tile dessa coluna será impresso 
						
		sub a1, t0, t5	# a1 recebe o endereço de onde imprimir o 1o tile dessa coluna 
				# t0 - t5 (número da iteração atual) retorna quantos pixels é necessário voltar
				# para encontrar a coluna certa onde imprimir os tiles para essa iteração

		li t0, 5120	# 5120 = 320 (tamanho de uma linha do frame) * 16 (altura de um tile)
		mul t0, t0, t3	# o endereço de a1 vai ser avançado por t3 * 5120 pixels de modo que vai apontar
		add a1, a1, t0	# para o endereço onde o tile dessa iteração (t3) deve ser impresso

		li t0, 320	# 320 é o tamanho de uma linha do frame
		mul t0, t0, t4	# 320 * t4 vai retornar em quantos pixels a1 precisar ser avançado para encontrar
		add a1, a1, t0	# o endereço onde imprimir a linha atual (t4) do tile (t3)
		
		add a1, a1, t6 	# decide a partir do valor de t6 qual o frame onde a imagem será impressa	
		
		mv a2, t5	# o número de colunas a serem impressas = o valor de t5 (iteração atual)					
		li a3, 1	# numero de linhas a serem impressas
		call PRINT_IMG
	
		addi t4, t4, 1		# incrementando o número de linhas do tile impressas
		li t0, 16
		bne t4, t0, LOOP_LINHAS_PROXIMA_AREA_D		# reinicia o loop se t4 != 16
			
		addi t3, t3, 1		# incrementando o número de tiles impressos
		li t0, 15	
		bne t3, t0, LOOP_TILES_PROXIMA_AREA_D		# reinicia o loop se t3 != 15
		
	
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP	
		
		call TROCAR_FRAME	# inverte o frame sendo mostrado		
				
		li t0, 0x00100000	# fazendo essa operação xor se t4 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# trocar entre esses valores
		
		addi t5, t5, 1		# incrementa o número de loops realizados						
		li t0, 16
		bne t5, t0, LOOP_MOVER_TELA_D	# reinicia o loop se t3 != 16
	
																																																																																																															
	addi s2, s2, 1		# atualizando a subsecção da área para uma coluna a frente da atual (s2) 
	
	# Pela maneira que o loop acima é executado na verdade só são feitas 15 iterações e não 16, 
	# portanto, é necessário imprimir novamente as imagem da área em ambos os frames + o sprite do RED 
	# no frame 0 para que tudo fique no lugar certo
		
		# Imprimindo a imagem da área no frame 0
		mv a4, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a5, 0xFF000000	# a imagem será impressa no frame 0
		li a6, 20		# número de colunas de tiles a serem impressas
		li a7, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES	
	
		# Imprimindo o sprite do RED no frame 0
		la a0, red_direita	# carrega a imagem do sprite			
		mv a1, s0		# s0 tem a posição do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
	
	call TROCAR_FRAME	# inverte o frame sendo mostrado
				# é necessário inverter o frame mais 1 vez para que o frame sendo mostrado
				# seja o 0		
					
		# Imprimindo a imagem da área no frame 1
		mv a4, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a5, 0xFF100000	# a imagem será impressa no frame 0
		li a6, 20		# número de colunas de tiles a serem impressas
		li a7, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES			
						
	addi s5, s5, 1		# atualizando o lugar do personagem na matriz de tiles para a próxima posição

	addi s6, s6, 1		# atualiza o valor de s6 para o proximo endereço da matriz de movimentação 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o próximo
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
