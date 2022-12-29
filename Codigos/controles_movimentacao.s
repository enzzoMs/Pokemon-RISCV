.text

# ====================================================================================================== # 
# 				        CONTROLES E MOVIMENTAÇÃO				         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Código responsável por coordenar os procedimentos de animação do personagem de acordo com as teclas	 #
# W, A, S ou D											         # 
#													 #
# Nos procedimentos de movimentação o que se "move" na verdade é a tela, o personagem sempre fica fixo   #
# no centro na posição apontada por s0.									 #															 
#													 #
# Para a movimentação do personagem é utilizado uma matriz para cada área do jogo.			 #
# Cada área é dividida em quadrados de 14 x 14 pixels, de forma que cada elemento dessas matrizes	 #
# representa um desses quadrados. Durante os procedimentos de movimentação a matriz da área		 #
# é consultada e dependendo do valor do elemento referente a próxima posição do personagem é determinado #
# se o jogador pode ou não se mover para lá. Por exemplo, elementos da matriz com a cor 7 indicam que    #
# o quadrado 14 x 14 correspondente está ocupado, então o personagem não pode ser mover para lá.	 #
# Cada procedimento de movimentação, seja para cima, baixo, esquerda ou direita, move a tela por  	 #
# exatamente 14 pixels, ou seja, o personagem passa de uma posição da matriz para outra, sendo que o	 #
# registrador s3 vai acompanhar a posição do personagem nessa matriz.  					 #
# 													 #
# ====================================================================================================== #

VERIFICAR_TECLA_MOVIMENTACAO:
	# Este procedimento é responsável por coordenar a movimentação do personagem,
	# ele chama VERIFICAR_TECLA e decide a partir do retorno os procedimentos adequados

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	call VERIFICAR_TECLA
	
	
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
		beq s1, t0, VERIFICAR_MATRIZ_W
			la a5, red_cima		# carrega como argumento o sprite do RED virada para cima		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s1, 2	# atualiza o valor de s1 dizendo que agora o RED está virado 
					# para cima
							
	VERIFICAR_MATRIZ_W:

	# Agora é preciso verificar as 2 posições acima na matriz de movimentação da área em relação 
	# ao personagem (s4). Uma posição diretamente acima do personagem e outra na diagonal direita
	# Caso a matriz indique que existe uma posição válida ali o personagem pode se mover.
	
	# è necessário verificar especificamente essas 2 posições porque o personagem 
	# ocupa na verdade 2 posições da matriz, e o endereço de s4 indica somente 
	# a posição onde o personagem começa						
									
	sub t0, s4, s5		# t0 recebe o endereço da posição da matriz que está uma linha acima de s4 
				# (s5 é o tamanho de uma linha da matriz) 	
						
	lbu  t0, 0(t0)		# lê a posição da matriz que está uma linha acima de s4 
	
	# Primerio verifica se t0 == t1, ou seja, de acordo com o convencionado em areas.s, verifica se t0
	# se trata de uma posição em que ocorre a transição para uma área
	li t1, 128
	blt t0, t1, VERIFICAR_MATRIZ_POSICAO_LIVRE_W
		# se nesse posição deve acontecer uma transição de área então a0 recebe o valor dessa
		# posição na matriz e o procedimento adequado é chamado
		mv a0, t0
		call RENDERIZAR_AREA
		j INICIO_MOVIMENTACAO_W
	
	VERIFICAR_MATRIZ_POSICAO_LIVRE_W:
	
	li t1, 1		# 1 é código da cor que representa que a posição está livre																																			
	bne t0, t1, FIM_MOVIMENTACAO_W	# se a posição não está livre pula para o final do procedimento
	
	
	INICIO_MOVIMENTACAO_W:
	
	# Se a posição for válida então começa os procedimentos de movimentação 
	
	li t4, 14		# número de pixels que a tela vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
				
	la t2, red_cima		# t2 vai guardar o endereço da próxima imagem do RED
				# o loop de movimentação começa imprimindo a imagem do RED 
				# virado para cima normalmente

	li t5, 0x00100000		# t5 será usada para fazer a troca entre frames no loop de movimentação				
											
	# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
	# de acordo com o valor de s6
		
	la t6, red_cima_passo_direito
							
	beq s6, zero, LOOP_MOVIMENTACAO_W		
		la t6, red_cima_passo_esquerdo
	
														
	LOOP_MOVIMENTACAO_W:
		sub s2, s2, s3		# atualiza o endereço de s2 para a linha anterior
					# da subsecção da imagem da área atual (s3 tem o tamanho
					# de uma linha da imagem da área atual)
						
		# Imprimindo as imagens da área e do RED no frame 			
			# Imprime a imagem da subsecção da área no frame 
			mv a0, s2		# s2 tem o endereço da subsecção da área
			
			li a1, 0xFF000000	# decide qual será o frame onde a imagem será impressa de
			add a1, a1, t5		# acordo com o valor atual de t5
			
			li a2, 240		# numero de linhas da sub imagem a ser impressa
			li a3, 320		# numero de colunas da sub imagem a ser impressa
			mv a4, s3		# s3 = tamanho de uma linha da imagem dessa área
			call PRINT_AREA		

			# Imprime o sprite do RED no frame 
			mv a0, t2		# t2 tem o endereço da próxima imagem do RED
			mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0
			
			add a1, a1, t5		# decide qual será o frame onde a imagem será impressa de
						# acordo com o valor atual de t5
					
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
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
		
		addi t4, t4, -1		# decrementa o número de loops restantes
		
		# t2 vai guardar o endereço da próxima imagem do RED		
		la t2, red_cima
		li t0, 13
		bgt t4, t0, LOOP_MOVIMENTACAO_W
		mv t2, t6				# t6 tem o endereço da imagem do RED dando um passo
		li t0, 1
		bgt t4, t0, LOOP_MOVIMENTACAO_W
		la t2, red_cima
		bne t4, zero, LOOP_MOVIMENTACAO_W
		
	sub s4, s4, s5		# atualiza o valor de s4 para o endereço 1 linha acima da atual na matriz 
				# (s5 tem o tamanho de uma linha da matriz)		
						
	xori s6, s6, 1		# inverte o valor de s6, ou seja, se o RED deu um passo esquerdo o próximo
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
		beq s1, zero, VERIFICAR_MATRIZ_A
			la a5, red_esquerda	# carrega como argumento o sprite do RED virada para a esquerda		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s1, 0	# atualiza o valor de s2 dizendo que agora o RED está virado 
					# para a esquerda
							
	VERIFICAR_MATRIZ_A:
	# Agora é preciso verificar a posição anteiror na matriz de movimentação da área em relação 
	# ao personagem (s4). 
	# Caso a matriz indique que existe uma posição válida ali o personagem pode se mover.
	
	lbu t0, -1(s4)		

	# Primerio verifica se t0 == t1, ou seja, de acordo com o convencionado em areas.s, verifica se t0
	# se trata de uma posição em que ocorre a transição para uma área
	li t1, 128
	blt t0, t1, VERIFICAR_MATRIZ_POSICAO_LIVRE_A
		# se nesse posição deve acontecer uma transição de área então a0 recebe o valor dessa
		# posição na matriz e o procedimento adequado é chamado
		mv a0, t0
		call RENDERIZAR_AREA
		j INICIO_MOVIMENTACAO_A
	
	VERIFICAR_MATRIZ_POSICAO_LIVRE_A:
							
	beq t0, zero, FIM_MOVIMENTACAO_A	# se a posição for 0 ela não está livre, então pula para o 
						# final do procedimento
	INICIO_MOVIMENTACAO_A:
	
	# Se a posição for válida então começa os procedimentos de movimentação 
	
	li t4, 14		# número de pixels que a tela vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
		
	la t2, red_esquerda		# t2 vai guardar o endereço da próxima imagem do RED
					# o loop de movimentação começa imprimindo a imagem do RED 
					# virado para a esquerda normalmente

	li t5, 0x00100000		# t5 será usada para fazer a troca entre frames no loop de movimentação				
											
	# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
	# de acordo com o valor de s6
		
	la t6, red_esquerda_passo_direito
							
	beq s6, zero, LOOP_MOVIMENTACAO_A		
		la t6, red_esquerda_passo_esquerdo
	
														
	LOOP_MOVIMENTACAO_A:
		addi s2, s2, -1		# atualiza o endereço de s2 para a coluna anterior
 					# da subseção da imagem da área atual
						
		# Imprimindo as imagens da área e do RED no frame 		
			# Imprime a imagem da subseção da área no frame 
			mv a0, s2		# s2 tem o endereço da subsecção da área
			
			li a1, 0xFF000000	# decide qual será o frame onde a imagem será impressa de
			add a1, a1, t5		# acordo com o valor atual de t5
			
			li a2, 240		# numero de linhas da sub imagem a ser impressa
			li a3, 320		# numero de colunas da sub imagem a ser impressa
			mv a4, s3		# s3 = tamanho de uma linha da imagem dessa área
			call PRINT_AREA		

			# Imprime o sprite do RED no frame 
			mv a0, t2		# t2 tem o endereço da próxima imagem do RED
			mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0
			
			add a1, a1, t5		# decide qual será o frame onde a imagem será impressa de
						# acordo com o valor atual de t5
					
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
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
		
		addi t4, t4, -1		# decrementa o número de loops restantes
		
		# t2 vai guardar o endereço da próxima imagem do RED		
		la t2, red_esquerda
		li t0, 13
		bgt t4, t0, LOOP_MOVIMENTACAO_A
		mv t2, t6				# t6 tem o endereço da imagem do RED dando um passo
		li t0, 1
		bgt t4, t0, LOOP_MOVIMENTACAO_A
		la t2, red_esquerda
		bne t4, zero, LOOP_MOVIMENTACAO_A
		
	addi s4, s4, -1		# atualiza o valor de s4 para o endereço anterior da matriz 
						
	xori s6, s6, 1		# inverte o valor de s6, ou seja, se o RED deu um passo esquerdo o próximo
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
		beq s1, t0, VERIFICAR_MATRIZ_S
			la a5, red_baixo	# carrega como argumento o sprite do RED virada para baixo		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s1, 3	# atualiza o valor de s1 dizendo que agora o RED está virado 
					# para baixo
							
	VERIFICAR_MATRIZ_S:
	
	# Agora é preciso verificar as 2 posições abaixo na matriz de movimentação da área em relação 
	# ao personagem (s4). Uma posição diretamente abaixo do personagem e outra na diagonal direita
	# Caso a matriz indique que existe uma posição válida ali o personagem pode se mover.
	
	# è necessário verificar especificamente essas 2 posições porque o personagem 
	# ocupa na verdade 2 posições da matriz, e o endereço de s4 indica somente 
	# a posição onde o personagem começa	
	
	add t0, s4, s5		# t0 recebe o endereço da posição da matriz que está uma linha abaixo de s4 
				# (s5 é o tamanho de uma linha da matriz) 	
						
	lbu t0, 0(t0)		# lê a posição da matriz que está uma linha abaixo de s4 
	
	# Primerio verifica se t0 == t1, ou seja, de acordo com o convencionado em areas.s, verifica se t0
	# se trata de uma posição em que ocorre a transição para uma área
	li t1, 128
	blt t0, t1, VERIFICAR_MATRIZ_POSICAO_LIVRE_S
		# se nesse posição deve acontecer uma transição de área então a0 recebe o valor dessa
		# posição na matriz e o procedimento adequado é chamado
		mv a0, t0
		call RENDERIZAR_AREA
		j INICIO_MOVIMENTACAO_S
	
	VERIFICAR_MATRIZ_POSICAO_LIVRE_S:
					
	li t1, 1		# 1 é código da cor que representa que a posição está livre																																			
	bne t0, t1, FIM_MOVIMENTACAO_S	# se a posição não está livre pula para o final do procedimento
	
	INICIO_MOVIMENTACAO_S:
	
	# Se a posição for válida então começa os procedimentos de movimentação 
	
	li t4, 14		# número de pixels que a tela vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
		
				
	la t2, red_baixo		# t2 vai guardar o endereço da próxima imagem do RED
					# o loop de movimentação começa imprimindo a imagem do RED 
					# virado para a direita normalmente
	
	li t5, 0x00100000		# t5 será usada para fazer a troca entre frames no loop de movimentação				
										
	# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
	# de acordo com o valor de s6
		
	la t6, red_baixo_passo_direito
							
	beq s6, zero, LOOP_MOVIMENTACAO_S		
		la t6, red_baixo_passo_esquerdo

	LOOP_MOVIMENTACAO_S:
		add s2, s2, s3		# atualiza o endereço de s2 para a próxima linha
					# da subsecção da imagem da área atual (s3 tem o tamanho
					# de uma linha da imagem da área atual)
						
		# Imprimindo as imagens da área e do RED no frame 			
			# Imprime a imagem da subsecção da área no frame 
			mv a0, s2		# s2 tem o endereço da subsecção da área
			
			li a1, 0xFF000000	# decide qual será o frame onde a imagem será impressa de
			add a1, a1, t5		# acordo com o valor atual de t5
			
			li a2, 240		# numero de linhas da sub imagem a ser impressa
			li a3, 320		# numero de colunas da sub imagem a ser impressa
			mv a4, s3		# s3 = tamanho de uma linha da imagem dessa área
			call PRINT_AREA		

			# Imprime o sprite do RED no frame 
			mv a0, t2		# t2 tem o endereço da próxima imagem do RED
			mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0
			
			add a1, a1, t5		# decide qual será o frame onde a imagem será impressa de
						# acordo com o valor atual de t5
					
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
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
		
		addi t4, t4, -1		# decrementa o número de loops restantes
		
		# t2 ai guardar o endereço da próxima imagem do RED		
		la t2, red_baixo
		li t0, 13
		bgt t4, t0, LOOP_MOVIMENTACAO_S
		mv t2, t6				# t6 tem o endereço da imagem do RED dando um passo
		li t0, 1
		bgt t4, t0, LOOP_MOVIMENTACAO_S
		la t2, red_baixo
		bne t4, zero, LOOP_MOVIMENTACAO_S
	
	add s4, s4, s5		# atualiza o valor de s4 para o endereço 1 linha abaixo do atual na matriz 
				# (s5 tem o tamanho de uma linha da matriz)		
						
	xori s6, s6, 1		# inverte o valor de s6, ou seja, se o RED deu um passo esquerdo o próximo
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
		beq s1, t0, VERIFICAR_MATRIZ_D
			la a5, red_direita	# carrega como argumento o sprite do RED virada para a direita		
			call MUDAR_ORIENTACAO_PERSONAGEM

			li s1, 1	# atualiza o valor de s1 dizendo que agora o RED está virado 
					# para a direita
					
	VERIFICAR_MATRIZ_D:																																				
	# Primeiro é preciso verificar a proxima posição da matriz de movimentação da área em relação ao personagem (s4). 
	# Caso a matriz indique que existe uma posição válida ali o personagem pode se mover.
	
	lbu t0, 1(s4)		# verificar proxima posição na matriz			
	
	# Primerio verifica se t0 < t1, ou seja, de acordo com o convencionado em areas.s, verifica se t0
	# se trata de uma posição em que ocorre a transição para uma área
	li t1, 128
	blt t0, t1, VERIFICAR_MATRIZ_POSICAO_LIVRE_D
		# se nesse posição deve acontecer uma transição de área então a0 recebe o valor dessa
		# posição na matriz e o procedimento adequado é chamado
		mv a0, t0
		call RENDERIZAR_AREA
		j INICIO_MOVIMENTACAO_D
	
	VERIFICAR_MATRIZ_POSICAO_LIVRE_D:
			
	beq t0, zero, FIM_MOVIMENTACAO_D	# se a posição for 0 ela não está livre, então pula para o 
						# final do procedimento
	
	INICIO_MOVIMENTACAO_D:
	
	# Se a posição for válida então começa os procedimentos de movimentação 
	
	li t4, 14		# número de pixels que a tela vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
		
	la t2, red_direita		# t2 vai guardar o endereço da próxima imagem do RED
					# o loop de movimentação começa imprimindo a imagem do RED 
					# virado para a direita normalmente
	
	li t5, 0x00100000		# t5 será usada para fazer a troca entre frames no loop de movimentação				
													
	# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
	# de acordo com o valor de s6
		
	la t6, red_direita_passo_direito
							
	beq s6, zero, LOOP_MOVIMENTACAO_D		
		la t6, red_direita_passo_esquerdo
																											
	LOOP_MOVIMENTACAO_D:
		addi s2, s2, 1		# atualiza o endereço de s2 para a próxima coluna
					# da subseção da imagem da área atual
						
		# Imprimindo as imagens da área e do RED no frame		
			# Imprime a imagem da subseção da área no frame 
			mv a0, s2		# s2 tem o endereço da subsecção da área
			
			li a1, 0xFF000000	# decide qual será o frame onde a imagem será impressa de
			add a1, a1, t5		# acordo com o valor atual de t5

			li a2, 240		# numero de linhas da sub imagem a ser impressa
			li a3, 320		# numero de colunas da sub imagem a ser impressa
			mv a4, s3		# s3 = tamanho de uma linha da imagem dessa área
			call PRINT_AREA		

			# Imprime o sprite do RED no frame 
			mv a0, t2		# t2 tem o endereço da próxima imagem do RED
			mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0
			
			add a1, a1, t5		# decide qual será o frame onde a imagem será impressa de
						# acordo com o valor atual de t5
					
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
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
		
		addi t4, t4, -1		# decrementa o número de loops restantes
		
		# t5 vai guardar o endereço da próxima imagem do RED		
		la t2, red_direita
		li t0, 13
		bgt t4, t0, LOOP_MOVIMENTACAO_D
		mv t2, t6				# t6 tem o endereço da imagem do RED dando um passo
		li t0, 1
		bgt t4, t0, LOOP_MOVIMENTACAO_D
		la t2, red_direita
		bne t4, zero, LOOP_MOVIMENTACAO_D
	
	addi s4, s4, 1		# atualiza o valor de s4 para o proximo endereço da matriz 
						
	xori s6, s6, 1		# inverte o valor de s6, ou seja, se o RED deu um passo esquerdo o próximo
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
	# 	 a5 = endereço da imagem do RED na orientação desejada
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
			
	# Primeiro é necessário "limpar" o antigo sprite do RED da tela. Isso é feito imprimindo uma
	# sub imagem da área no lugar onde o RED está
		# Para encontrar essa sub área é possível usar s2 (endereço de inicio da sub área atual)
		li t0, 108	# o sprite do RED sempre está a 108 linhas de s2
		mul t0, s3, t0	# t0 recebe s3 (tamanho de uma linha da imagem da área) x 106
		
		addi t0, t0, 153	# de modo similar o sprite do RED sempre está a 153 colunas de diferença
					# de s2
		
		add t0, t0, s2		# fazendo essa soma t0 recebe o endereço de onde o sprite do RED está
					# na imagem da área
									
		# Imprime uma sub imagem da área no frame 0
		mv a0, t0		# t0 tem o endereço da sub imagem que será usada na limpeza da tela
		mv a1, s0		# s0 tem o endereço onde vai acontecer a limpeza, nesse caso o 
					# endereço de onde o sprite do RED está 
		li a2, 19		# numero de linhas de um sprite do RED
		li a3, 14		# numero de colunas de um sprite do RED
		mv a4, s3		# s3 = tamanho de uma linha da imagem dessa área
		call PRINT_AREA		
		
	# Agora o novo sprite do RED pode ser renderizado no frame 0
		mv a0, a5		# a5 tem o endereço da imagem do RED na orientação desejada
		mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0		
		lw a2, 0(a0)		# numero de colunas do sprite
		lw a3, 4(a0)		# numero de linhas do sprite
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG
						
	call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 0
	
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
