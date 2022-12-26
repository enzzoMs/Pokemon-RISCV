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
# Cada área é dividida em quadrados de 20 x 20 pixels, de forma que cada elemento dessas matrizes	 #
# representa um desses quadrados. Durante os procedimentos de movimentação a matriz da área		 #
# é consultada e dependendo do valor do elemento referente a próxima posição do personagem é determinado #
# se o jogador pode ou não se mover para lá. Por exemplo, elementos da matriz com a cor 7 indicam que    #
# o quadrado 20 x 20 correspondente está ocupado, então o personagem não pode ser mover para lá.	 #
# Cada procedimento de movimentação, seja para cima, baixo, esquerda ou direita, move a tela por  	 #
# exatamente 20 pixels, ou seja, o personagem passa de uma posição da matriz para outra, sendo que o	 #
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
		beq s1, t0, INICIO_MOVIMENTACAO_W
			la a4, red_cima		# carrega como argumento o sprite do RED virada para cima		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s1, 2	# atualiza o valor de s1 dizendo que agora o RED está virado 
					# para cima
							
	INICIO_MOVIMENTACAO_W:

	# Agora é preciso verificar as 2 posições acima na matriz de movimentação da área em relação 
	# ao personagem (s4). Uma posição diretamente acima do personagem e outra na diagonal direita
	# Caso a matriz indique que existe uma posição válida ali o personagem pode se mover.
	
	# è necessário verificar especificamente essas 2 posições porque o personagem 
	# ocupa na verdade 2 posições da matriz, e o endereço de s4 indica somente 
	# a posição onde o personagem começa						
									
	sub t0, s4, s5		# t0 recebe o endereço da posição da matriz que está uma linha acima de s4 
				# (s5 é o tamanho de uma linha da matriz) 	
						
	lb t1, 0(t0)		# lê a posição da matriz que está uma linha acima de s4 
	
	lb t2, 1(t0)		# lê a posição da matriz que está uma linha acima de s4 (t0) e uma posição a 
				# frente, ou seja, na diagonal de s4						
	
	and t0, t1, t2		# realiza o AND entre t1 e t2 para fazer a comparação abaixo
	
	li t1, 51		# 51 é código da cor que representa que a posição está livre																																			
	bne t0, t1, FIM_MOVIMENTACAO_W	# se a posição não está livre pula para o final do procedimento
	
	# Se a posição for válida então começa os procedimentos de movimentação 
	
	li t4, 10		# número de pixels que a tela vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
				# Na verdade a tela se desloca 20 pixels, mas em cada iteração
				# do loop abaixo a tela é deslocada 2 pixels (1 vez para o frame 1
				# e 1 vez para o frame 0)
				
	la t5, red_cima		# t5 vai guardar o endereço da próxima imagem do RED
				# o loop de movimentação começa imprimindo a imagem do RED 
				# virado para cima normalmente
					
	# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
	# de acordo com o valor de s6
		
	la t6, red_cima_passo_direito
							
	beq s6, zero, LOOP_MOVIMENTACAO_W		
		la t6, red_cima_passo_esquerdo
	
														
	LOOP_MOVIMENTACAO_W:
		sub s2, s2, s3		# atualiza o endereço de s2 para a linha anterior
					# da subsecção da imagem da área atual (s3 tem o tamanho
					# de uma linha da imagem da área atual)
						
		# Imprimindo as imagens da área e do RED no frame 1			
			# Imprime a imagem da subsecção da área no frame 1
			mv a0, s2		# s2 tem o endereço da subsecção da área
			li a1, 0xFF100000	# selecionando como argumento o frame 1
			mv a2, s3		# s3 = tamanho de uma linha da imagem dessa área
			call PRINT_AREA		

			# Imprime o sprite do RED no frame 1
			mv a0, t5		# t5 tem o endereço da próxima imagem do RED
			mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0
			
			li t0, 0x00100000	# passa o endereço de a1 para o equivalente no frame 1
			add a1, a1, t0
					
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG
					
		# Espera alguns milisegundos	
		li a0, 18			# sleep por 18 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
							
		sub s2, s2, s3		# atualiza o endereço de s2 para a linha anterior
					# da subsecção da imagem da área atual (s3 tem o tamanho
					# de uma linha da imagem da área atual)
					
		# Imprimindo as imagens da área e do RED no frame 0					
			# Imprime a imagem da subseção da área no frame 0
			mv a0, s2		# s2 tem o endereço da subsecção da área
			li a1, 0xFF000000	# selecionando como argumento o frame 0
			mv a2, s3		# s3 = tamanho de uma linha da imagem dessa área
			call PRINT_AREA		


			# Imprime o sprite do RED no frame 0
			mv a0, t5		# t5 tem o endereço da próxima imagem do RED
			mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG
	
		# Espera alguns milisegundos	
		li a0, 18			# sleep por 18 ms
		call SLEEP			# chama o procedimento SLEEP	
		
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 0
		
		
		# Determina qual é o próximo sprite do RED a ser renderizado,
		# de modo que a animação siga o seguinte padrão:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		addi t4, t4, -1		# decrementa o número de loops restantes
		
		# t5 vai guardar o endereço da próxima imagem do RED		
		la t5, red_cima
		li t0, 8
		bgt t4, t0, LOOP_MOVIMENTACAO_W
		mv t5, t6				# t6 tem o endereço da imagem do RED dando um passo
		li t0, 2
		bgt t4, t0, LOOP_MOVIMENTACAO_W
		la t5, red_cima
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
		beq s1, zero, INICIO_MOVIMENTACAO_A
			la a4, red_esquerda	# carrega como argumento o sprite do RED virada para a esquerda		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s1, 0	# atualiza o valor de s2 dizendo que agora o RED está virado 
					# para a esquerda
							
	INICIO_MOVIMENTACAO_A:
	# Agora é preciso verificar a posição anteiror na matriz de movimentação da área em relação 
	# ao personagem (s4). 
	# Caso a matriz indique que existe uma posição válida ali o personagem pode se mover.
	
	lb t0, -1(s4)		
	
	li t1, 7		# 7 é código da cor que representa que a posição não está livre																																			
	beq t0, t1, FIM_MOVIMENTACAO_A	# se a posição não está livre pula para o final do procedimento
	
	# Se a posição for válida então começa os procedimentos de movimentação 
	
	li t4, 10		# número de pixels que a tela vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
				# Na verdade a tela se desloca 20 pixels, mas em cada iteração
				# do loop abaixo a tela é deslocada 2 pixels (1 vez para o frame 1
				# e 1 vez para o frame 0)
		
	la t5, red_esquerda		# t5 vai guardar o endereço da próxima imagem do RED
					# o loop de movimentação começa imprimindo a imagem do RED 
					# virado para a esquerda normalmente
					
	# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
	# de acordo com o valor de s6
		
	la t6, red_esquerda_passo_direito
							
	beq s6, zero, LOOP_MOVIMENTACAO_A		
		la t6, red_esquerda_passo_esquerdo
	
														
	LOOP_MOVIMENTACAO_A:
		addi s2, s2, -1		# atualiza o endereço de s2 para a coluna anterior
 					# da subseção da imagem da área atual
						
		# Imprimindo as imagens da área e do RED no frame 1			
			# Imprime a imagem da subseção da área no frame 1
			mv a0, s2		# s2 tem o endereço da subsecção da área
			li a1, 0xFF100000	# selecionando como argumento o frame 1
			mv a2, s3		# s3 = tamanho de uma linha da imagem dessa área
			call PRINT_AREA		

			# Imprime o sprite do RED no frame 1
			mv a0, t5		# t5 tem o endereço da próxima imagem do RED
			mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0
			
			li t0, 0x00100000	# passa o endereço de a1 para o equivalente no frame 1
			add a1, a1, t0
					
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG
					
		# Espera alguns milisegundos	
		li a0, 18			# sleep por 18 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
							
		addi s2, s2, -1		# atualiza o endereço de s2 para a coluna anterior
 					# da subseção da imagem da área atual
					
		# Imprimindo as imagens da área e do RED no frame 0					
			# Imprime a imagem da subseção da área no frame 0
			mv a0, s2		# s2 tem o endereço da subsecção da área
			li a1, 0xFF000000	# selecionando como argumento o frame 0
			mv a2, s3		# s3 = tamanho de uma linha da imagem dessa área
			call PRINT_AREA		

			# Imprime o sprite do RED no frame 0
			mv a0, t5		# t5 tem o endereço da próxima imagem do RED
			mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG
	
		# Espera alguns milisegundos	
		li a0, 18			# sleep por 18 ms
		call SLEEP			# chama o procedimento SLEEP	
		
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 0
		
		
		# Determina qual é o próximo sprite do RED a ser renderizado,
		# de modo que a animação siga o seguinte padrão:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		addi t4, t4, -1		# decrementa o número de loops restantes
		
		# t5 vai guardar o endereço da próxima imagem do RED		
		la t5, red_esquerda
		li t0, 8
		bgt t4, t0, LOOP_MOVIMENTACAO_A
		mv t5, t6				# t6 tem o endereço da imagem do RED dando um passo
		li t0, 2
		bgt t4, t0, LOOP_MOVIMENTACAO_A
		la t5, red_esquerda
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
		beq s1, t0, INICIO_MOVIMENTACAO_S
			la a4, red_baixo	# carrega como argumento o sprite do RED virada para baixo		
			call MUDAR_ORIENTACAO_PERSONAGEM
			
			li s1, 3	# atualiza o valor de s1 dizendo que agora o RED está virado 
					# para baixo
							
	INICIO_MOVIMENTACAO_S:
	
	# Agora é preciso verificar as 2 posições abaixo na matriz de movimentação da área em relação 
	# ao personagem (s4). Uma posição diretamente abaixo do personagem e outra na diagonal direita
	# Caso a matriz indique que existe uma posição válida ali o personagem pode se mover.
	
	# è necessário verificar especificamente essas 2 posições porque o personagem 
	# ocupa na verdade 2 posições da matriz, e o endereço de s4 indica somente 
	# a posição onde o personagem começa	
	
	add t0, s4, s5		# t0 recebe o endereço da posição da matriz que está uma linha abaixo de s4 
				# (s5 é o tamanho de uma linha da matriz) 	
						
	lb t1, 0(t0)		# lê a posição da matriz que está uma linha abaixo de s4 
	
	lb t2, 1(t0)		# lê a posição da matriz que está uma linha abaixo de s4 (t0) e uma posição a 
				# frente, ou seja, na diagonal de s4						
	
	and t0, t1, t2		# realiza o AND entre t1 e t2 para fazer a comparação abaixo
					
	li t1, 51		# 51 é código da cor que representa que a posição está livre																																			
	bne t0, t1, FIM_MOVIMENTACAO_S	# se a posição não está livre pula para o final do procedimento
	
	# Se a posição for válida então começa os procedimentos de movimentação 
	
	li t4, 10		# número de pixels que a tela vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
				# Na verdade a tela se desloca 20 pixels, mas em cada iteração
				# do loop abaixo a tela é deslocada 2 pixels (1 vez para o frame 1
				# e 1 vez para o frame 0)
				
	la t5, red_baixo		# t5 vai guardar o endereço da próxima imagem do RED
					# o loop de movimentação começa imprimindo a imagem do RED 
					# virado para a direita normalmente
					
	# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
	# de acordo com o valor de s6
		
	la t6, red_baixo_passo_direito
							
	beq s6, zero, LOOP_MOVIMENTACAO_S		
		la t6, red_baixo_passo_esquerdo

	LOOP_MOVIMENTACAO_S:
		add s2, s2, s3		# atualiza o endereço de s2 para a próxima linha
					# da subsecção da imagem da área atual (s3 tem o tamanho
					# de uma linha da imagem da área atual)
						
		# Imprimindo as imagens da área e do RED no frame 1			
			# Imprime a imagem da subsecção da área no frame 1
			mv a0, s2		# s2 tem o endereço da subsecção da área
			li a1, 0xFF100000	# selecionando como argumento o frame 1
			mv a2, s3		# s3 = tamanho de uma linha da imagem dessa área
			call PRINT_AREA		

			# Imprime o sprite do RED no frame 1
			mv a0, t5		# t5 tem o endereço da próxima imagem do RED
			mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0
			
			li t0, 0x00100000	# passa o endereço de a1 para o equivalente no frame 1
			add a1, a1, t0
					
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG
					
		# Espera alguns milisegundos	
		li a0, 18			# sleep por 18 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
							
		add s2, s2, s3		# atualiza o endereço de s2 para a próxima linha
					# da subsecção da imagem da área atual (s3 tem o tamanho
					# de uma linha da imagem da área atual)
					
		# Imprimindo as imagens da área e do RED no frame 0					
			# Imprime a imagem da subseção da área no frame 0
			mv a0, s2		# s2 tem o endereço da subsecção da área
			li a1, 0xFF000000	# selecionando como argumento o frame 0
			mv a2, s3		# s3 = tamanho de uma linha da imagem dessa área
			call PRINT_AREA		


			# Imprime o sprite do RED no frame 0
			mv a0, t5		# t5 tem o endereço da próxima imagem do RED
			mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG
	
		# Espera alguns milisegundos	
		li a0, 18			# sleep por 18 ms
		call SLEEP			# chama o procedimento SLEEP	
		
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 0
		
		
		# Determina qual é o próximo sprite do RED a ser renderizado,
		# de modo que a animação siga o seguinte padrão:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		addi t4, t4, -1		# decrementa o número de loops restantes
		
		# t5 vai guardar o endereço da próxima imagem do RED		
		la t5, red_baixo
		li t0, 8
		bgt t4, t0, LOOP_MOVIMENTACAO_S
		mv t5, t6				# t6 tem o endereço da imagem do RED dando um passo
		li t0, 2
		bgt t4, t0, LOOP_MOVIMENTACAO_S
		la t5, red_baixo
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
		beq s1, t0, INICIO_MOVIMENTACAO_D
			la a4, red_direita	# carrega como argumento o sprite do RED virada para a direita		
			call MUDAR_ORIENTACAO_PERSONAGEM

			li s1, 1	# atualiza o valor de s1 dizendo que agora o RED está virado 
					# para a direita
					
	INICIO_MOVIMENTACAO_D:																																				
	# Primeiro é preciso verificar a 2a posição da matriz de movimentação da área em relação ao personagem (s4). 
	# Caso a matriz indique que existe uma posição válida ali o personagem pode se mover.
	
	lb t0, 2(s4)		# è necessário verificar especificamente a 2a posição porque o personagem 
				# ocupa na verdade 2 posições da matriz, e o endereço de s4 indica somente 
				# a posição onde o personagem começa, então é necessário pular mais uma posição
				# adicional para encontrar uma posição livre 				
		
	li t1, 7		# 7 é código da cor que representa que a posição não está livre																																			
	beq t0, t1, FIM_MOVIMENTACAO_D	# se a posição não está livre pula para o final do procedimento
	
	# Se a posição for válida então começa os procedimentos de movimentação 
	
	li t4, 10		# número de pixels que a tela vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
				# Na verdade a tela se desloca 20 pixels, mas em cada iteração
				# do loop abaixo a tela é deslocada 2 pixels (1 vez para o frame 1
				# e 1 vez para o frame 0)
		
	la t5, red_direita		# t5 vai guardar o endereço da próxima imagem do RED
					# o loop de movimentação começa imprimindo a imagem do RED 
					# virado para a direita normalmente
					
	# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
	# de acordo com o valor de s6
		
	la t6, red_direita_passo_direito
							
	beq s6, zero, LOOP_MOVIMENTACAO_D		
		la t6, red_direita_passo_esquerdo
																											
	LOOP_MOVIMENTACAO_D:
		addi s2, s2, 1		# atualiza o endereço de s2 para a próxima coluna
					# da subseção da imagem da área atual
						
		# Imprimindo as imagens da área e do RED no frame 1			
			# Imprime a imagem da subseção da área no frame 1
			mv a0, s2		# s2 tem o endereço da subsecção da área
			li a1, 0xFF100000	# selecionando como argumento o frame 1
			mv a2, s3		# s3 = tamanho de uma linha da imagem dessa área
			call PRINT_AREA		

			# Imprime o sprite do RED no frame 1
			mv a0, t5		# t5 tem o endereço da próxima imagem do RED
			mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0
			
			li t0, 0x00100000	# passa o endereço de a1 para o equivalente no frame 1
			add a1, a1, t0
					
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG
					
		# Espera alguns milisegundos	
		li a0, 18			# sleep por 18 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
							
		addi s2, s2, 1		# atualiza o endereço de s2 para a próxima coluna
					# da subseção da imagem da área atual
					
		# Imprimindo as imagens da área e do RED no frame 0					
			# Imprime a imagem da subseção da área no frame 0
			mv a0, s2		# s2 tem o endereço da subsecção da área
			li a1, 0xFF000000	# selecionando como argumento o frame 0
			mv a2, s3		# s3 = tamanho de uma linha da imagem dessa área
			call PRINT_AREA		


			# Imprime o sprite do RED no frame 0
			mv a0, t5		# t5 tem o endereço da próxima imagem do RED
			mv a1, s0		# s0 tem o endereço de onde o RED fica na tela no frame 0
			lw a2, 0(a0)		# numero de colunas do sprite
			lw a3, 4(a0)		# numero de linhas do sprite
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG
	
		# Espera alguns milisegundos	
		li a0, 18			# sleep por 18 ms
		call SLEEP			# chama o procedimento SLEEP	
		
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 0
		
		
		# Determina qual é o próximo sprite do RED a ser renderizado,
		# de modo que a animação siga o seguinte padrão:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		addi t4, t4, -1		# decrementa o número de loops restantes
		
		# t5 vai guardar o endereço da próxima imagem do RED		
		la t5, red_direita
		li t0, 8
		bgt t4, t0, LOOP_MOVIMENTACAO_D
		mv t5, t6				# t6 tem o endereço da imagem do RED dando um passo
		li t0, 2
		bgt t4, t0, LOOP_MOVIMENTACAO_D
		la t5, red_direita
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
	# 	 a4 = endereço da imagem do RED na orientação desejada
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
			
	# Imprime a imagem da subsecção da área no frame 0
		mv a0, s2		# s2 tem o endereço da subsecção da área
		li a1, 0xFF000000	# selecionando como argumento o frame 0
		li a2, 600		# 600 = tamanho de uma linha da imagem dessa área
		call PRINT_AREA		

		# Imprime o sprite do RED no frame 0
		mv a0, a4		# a4 tem o endereço da imagem do RED na orientação desejada
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
