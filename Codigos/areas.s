.text

# ====================================================================================================== # 
# 						   AREAS				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo possui os procedimentos necesários para renderizar as diferentes áreas do jogo, fazendo   #
# as alterações necessárias nos registradores salvos s0 - s7						 #
#            												 #	 
# Além disso, esse arquivo também contém os procedimentos para realizar as transições entre área.	 #
# A transição entre uma área e outra acontece quando o jogador se encontra em uma posição especial na	 #
# matriz de movimentação de uma área.									 #
# O procedimento VERIFICAR_MATRIZ_DE_MOVIMENTACAO vai verificar o valor da próxima posição do personagem #
# na matriz de movimentação, caso o valor dessa posição seja maior ou igual a 64 (1_0_000_00 em binário) #
# os procedimentos de transição de área serão chamados.							 #		 #
# A razão para esse número é que o valor desses elementos especiais é codificado em binário no seguinte  #
# formato 1_M_AAA_PP, onde:									         #
# 	 1... -> 1 bit fixo que indica que essa posição se trata de uma transição para outra área +  	 #
#	    M -> 1 bit que indica o tipo de mensagem que será impressa na tela durante a transição (sair #
#		 ou entrar na área)									 #
# 	  AAA -> 3 bits identificando a área para onde o personagem está indo +				 #
#	   PP -> 2 bits que indicam por qual ponto de entrada o personagem vai entrar na área 		 #
#													 #
# Então cada elemento de transição da matriz guarda as informações necessárias para que os procedimentos #
# saibam o que fazer.											 #
# Os possíveis valores de AAA e YY podem ser encontrados abaixo:					 #
# 	Áreas (AAA): 										 	 #
#		Casa do do RED -> 000									 #
#		Pallet -> 010										 #
#		Laboratório -> 011									 #
# 													 #
# Já os valores de PP variam dependendo da área. Algumas áreas possuem mais de uma maneira de acessa-las #
# A sala do RED, por exemplo, pode ser acessada tanto pelo quarto do RED ou pela porta da frente, nesse  #
# caso PP indica por qual entrada o personagem vai acessar a área:					 #
#	Casa do RED:											 #
#		PP = 00 -> Entrada por lugar nenhum (quando o jogo começa)				 #							 #
#		PP = 01 -> Entrada pela porta da frente							 #
#	Pallet:												 #
#		PP = 00 -> Entrada pela casa do RED							 #
#		PP = 01 -> Entrada pelo laboratorio							 #
#	Laboratório:											 #
#		PP = 00 -> Entrada pela porta								 #
#            												 #	 
# ====================================================================================================== #

RENDERIZAR_AREA:
	# Procedimento principal de areas.s, coordena a renderização de áreas e a transição entre elas
	# Argumentos:
	# 	a4 = número codificando as informações de renderização de área, ou seja, um número em que 
	# 	todos os bits são 0, exceto o 7 bits menos significativo, que seguem o formato 1_AAA_PP onde 
	# 	AAA é o código da área a ser renderizada e PP o ponto de entrada na área.
	# 	Para mais explicações ler texto acima.
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Antes de renderizar a próxima área é necessário imprimir uma pequena seta indicando que o jogador
	# está prester a sair de uma área, além disso é necessário perguntar se o jogador quer mesmo sair
		# A única exceção para esse caso é se a0 = 1_0_000_00, em que a próxima área é o quarto do RED
		# entrando por lugar nenhum, ou seja, o jogo está começando
		
		li t0, 64	# 64 = 1_0_000_00 em binário
		beq a4, t0, ESCOLHER_PROXIMA_AREA
	
	andi a0, a4, 32		# Preparando o argumento de TRANSICAO_ENTRE_AREAS indicando o tipo de mensagem
				# a se impressa. 
				# Fazendo o AND de a4 com 32, 1000000 em binário, deixa somente o bit 
				# de a4 que deve ser de M intacto, enquanto o restante fica todo 0		
	call TRANSICAO_ENTRE_AREAS
		
	ESCOLHER_PROXIMA_AREA:

	# Agora é necessário verificar a área a ser renderizada (AAA)
		# Para usar como argumento nos procedimentos de renderização de áreas é necessário
		# separar também o PP (ponto de entrada da área)
	
		andi t0, a4, 3		# fazendo o AND de a4 com 3, 011 em binário, deixa somente os dois 
					# primeiros bits de a4 intactos, enquanto o restante fica todo 0
		
		# Agora Separando o campo AAA
			
		andi t1, a4, 0x1C	# fazendo o AND de a0 com 0x1C, 01_1100 em binário, deixa somente os 
					# bits de a4 que devem ser de AAA intactos, enquanto o restante 
					# fica todo 0	
	
		# Agora o procedimento de renderização de área adequado será chamado de acordo com AAA
		mv a0, t0	# move para a0 o valor de PP para que a0 possa ser usado como 
				# argumento nos procedimentos de renderização de área
		
		# se t1 (AAA) = 000 renderiza a casa do RED
		beq t1, zero, RENDERIZAR_CASA_RED
	
		li t0, 8	# 8 ou 010 00 em binário é o código da área de Pallet
		# se t1 (AAA) = 010 00 renderiza Pallet
		beq t1, t0, RENDERIZAR_PALLET
		
		li t0, 12	# 12 ou 011 00 em binário é o código da área de Pallet
		# se t1 (AAA) = 011 00 renderiza o laboratorio
		beq t1, t0, RENDERIZAR_LABORATORIO

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #

RENDERIZAR_CASA_RED:
	# Procedimento que imprime a imagem da casa do RED e o sprite do RED no frame 0 e no frame 1 de 
	# acordo com o ponto de entrada, além de atualizar os registradores salvos
	# Argumentos:
	# 	a0 = indica o ponto de entrada na área, ou seja, por onde o RED está entrando nessa área
	#	Para essa área os pontos de entrada possíveis são:
	#		PP = 00 -> Entrada por lugar nenhum (quando o jogo começa)	
	#		PP = 01 -> Entrada pela porta da frente

	# OBS: não é necessário empilhar o valor de ra pois a chegada a este procedimento é por meio
	# de uma instrução de branch e a saída é pelo ra empilhado por RENDERIZAR_AREA
 	
 	# Primeiro verifica qual o ponto de entrada (PP = a0)		
	bne a0, zero, CASA_RED_PP_PORTA	
		
	# Se a0 == 00 então o ponto de entrada é por lugar nenhum
					
	# Atualizando os registradores salvos para essa área
		# Atualizando o valor de s0 (posição atual do RED no frame 0)
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			li a2, 65 			# numero da coluna do RED = 65
			li a3, 77			# numero da linha do RED = 77
			call CALCULAR_ENDERECO	
		
			mv s0, a0		# move o endereço retornado para s0
	
		# Atualizando o valor de s1 (orientação do personagem)
			li s1, 2	# inicialmente virado para cima
		
		# Atualizando o valor de s2 (endereço da subsecção na matriz de tiles ques está sendo 
		# mostrada) e s3 (tamanho de uma linha da matriz de tiles)
			la s2, matriz_tiles_casa_red	# carregando em s2 o endereço da matriz
		
			lw s3, 0(s2)		# s3 recebe o tamanho de uma linha da matriz
		
			addi s2, s2, 8		# pula para onde começa os pixels no .data
		
			addi s2, s2, 23		# pula para onde começa a subsecção que será mostrada na tela
						
		# Atualizando o valor de s4 (endereço da imagem com os tiles da área)
			la s4, tiles_casa_red				
			addi s4, s4, 8		# pula para onde começa os pixels no .data			
		
		# Atualizando o valor de s5 (posição atual do personagem na matriz de tiles)						
			la t0, matriz_tiles_casa_red
			addi t0, t0, 8			# pula para onde começa os pixels no .data
			addi s5, t0, 115		# o RED começa na linha 5 e coluna 5 da matriz
							# de tiles, então é somado (5 * 22(tamanho de
							# uma linha da matriz)) + 5		
																																												
		# Atualizando o valor de s6 (posição atual na matriz de movimentação da área) e 
		# s7 (tamanho de linha na matriz de movimentação)	
		la t0, matriz_movimentacao_casa_red	
		
		lw s7, 0(t0)			# s7 recebe o tamanho de uma linha da matriz da área
				
		addi t0, t0, 8
	
		addi s6, t0, 42		# o personagem começa na linha 3 e coluna 1 da matriz
					# então é somado o endereço base da matriz (t0) a 
		addi s6, s6, 1		# 3 (número da linha) * 14 (tamanho de uma linha da matriz) 
					# e a 1 (número da coluna) 
											
	# Imprimindo as imagens da área e o sprite inicial do RED no frame 0
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
											
		# Imprimindo a imagem do quarto do RED no frame 0
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF000000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES_AREA				
						
		# Imprimindo a imagem do RED virado para cima no frame 0
		la a0, red_cima		# carrega a imagem				
		mv a1, s0		# s0 tem a posição do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
		
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
	# Imprimindo a imagem da área no frame 1	
		# Imprimindo a imagem do quarto do RED no frame 1
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF100000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES_AREA		
										
		# Imprimindo a imagem do RED virado para cima no frame 0
		
		la a0, red_cima		# carrega a imagem			
			
		mv a1, s0		# s0 tem a posição do RED no frame 0
		li t0, 0x00100000	# passando o endereço de s0 para o seu endereço correspondente no
		add a1, a1, t0		# frame 1
		
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
		
		j FIM_RENDERIZAR_CASA_RED
	
	
	CASA_RED_PP_PORTA:
	# Se a0 == 01 (ou != 0) então o ponto de entrada é pela porta da frente	
	
	# Atualizando os registradores salvos para essa área
		# Atualizando o valor de s0 (posição atual do RED no frame 0)
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			li a2, 113 			# numero da coluna do RED = 113
			li a3, 173			# numero da linha do RED = 173
			call CALCULAR_ENDERECO	
		
			mv s0, a0		# move o endereço retornado para s0
	
		# Atualizando o valor de s1 (orientação do personagem)
			li s1, 2	# inicialmente virado para cima
		
		# Atualizando o valor de s2 (endereço da subsecção na matriz de tiles que está sendo 
		# mostrada) e s3 (tamanho de uma linha da matriz de tiles)
			la s2, matriz_tiles_casa_red	# carregando em s2 o endereço da matriz
		
			lw s3, 0(s2)		# s3 recebe o tamanho de uma linha da matriz
		
			addi s2, s2, 8		# pula para onde começa os pixels no .data
		
			addi s2, s2, 23		# pula para onde começa a subsecção que será mostrada na tela
						
		# Atualizando o valor de s4 (endereço da imagem com os tiles da área)
			la s4, tiles_casa_red				
			addi s4, s4, 8		# pula para onde começa os pixels no .data			
		
		# Atualizando o valor de s5 (posição atual do personagem na matriz de tiles)						
			la t0, matriz_tiles_casa_red
			addi t0, t0, 8			# pula para onde começa os pixels no .data
			addi s5, t0, 250		# o RED começa na linha 11 e coluna 8 da matriz
							# de tiles, então é somado (11 * 22(tamanho de
							# uma linha da matriz)) + 8		
																																												
		# Atualizando o valor de s6 (posição atual na matriz de movimentação da área) e 
		# s7 (tamanho de linha na matriz de movimentação)	
		la t0, matriz_movimentacao_casa_red	
		
		lw s7, 0(t0)			# s7 recebe o tamanho de uma linha da matriz da área
				
		addi t0, t0, 8
	
		addi s6, t0, 126	# o personagem começa na linha 9 e coluna 4 da matriz
					# então é somado o endereço base da matriz (t0) a 
		addi s6, s6, 4		# 9 (número da linha) * 14 (tamanho de uma linha da matriz) 
					# e a 4 (número da coluna) 
											
		# Imprimindo as imagens da área no frame 0	
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
							
		# Imprimindo a imagem da sala do RED no frame 0
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF000000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES_AREA
						
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
								
		# Imprimindo a imagem da área no frame 1	
		# Imprimindo a imagem da sala do RED no frame 1
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF100000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES_AREA																				
						
	FIM_RENDERIZAR_CASA_RED:									
																												
	# Mostra o frame 0		
	li t0, 0xFF200604		# t0 = endereço para escolher frames 
	sb zero, (t0)			# armazena 0 no endereço de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #	

RENDERIZAR_PALLET:
	# Procedimento que imprime a imagem de pallet no frame 0 e no frame 1
	# de acordo com o ponto de entrada, além de atualizar os registradores salvos
	# Argumentos:
	# 	a0 = indica o ponto de entrada na área, ou seja, por onde o RED está entrando nessa área
	#	Para essa área os pontos de entrada possíveis são:
	#		PP = 00 -> Entrada pela casa do RED						

	# OBS: não é necessário empilhar o valor de ra pois a chegada a este procedimento é por meio
	# de uma instrução de branch e a saída é pelo ra empilhado por RENDERIZAR_AREA
	
	# Primeiro verifica qual o ponto de entrada (PP = a0)		
	beq a0, zero, PALLET_PP_CASA_RED		
	# Se a0 == 01 (ou != 0) então o ponto de entrada é pelo laboratorio

	# Atualizando os registradores salvos para essa área
		# Atualizando o valor de s0 (posição atual do RED no frame 0)
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			li a2, 193 			# numero da coluna do RED = 193
			li a3, 141			# numero da linha do RED = 141
			call CALCULAR_ENDERECO	
		
			mv s0, a0		# move o endereço retornado para s0
	
		# Atualizando o valor de s1 (orientação do personagem)
			li s1, 3	# inicialmente virado para baixo
		
		# Atualizando o valor de s2 (endereço da subsecção na matriz de tiles ques está sendo 
		# mostrada) e s3 (tamanho de uma linha da matriz de tiles)
			la s2, matriz_tiles_pallet	# carregando em s2 o endereço da matriz
		
			lw s3, 0(s2)		# s3 recebe o tamanho de uma linha da matriz
		
			addi s2, s2, 8		# pula para onde começa os pixels no .data
		
			addi s2, s2, 1175	# pula para onde começa a subsecção que será mostrada na tela
						# (5a coluna e 45a linha da matriz de tiles)
						
		# Atualizando o valor de s4 (endereço da imagem com os tiles da área)
			la s4, tiles_pallet				
			addi s4, s4, 8		# pula para onde começa os pixels no .data			
		
		# Atualizando o valor de s5 (posição atual do personagem na matriz de tiles)						
			la t0, matriz_tiles_pallet
			addi t0, t0, 8			# pula para onde começa os pixels no .data
			addi s5, t0, 1395		# o RED começa na linha 53 e coluna 17 da matriz
							# de tiles, então é somado (53 * 26(tamanho de
							# uma linha da matriz)) + 17		
																																												
		# Atualizando o valor de s6 (posição atual na matriz de movimentação da área) e 
		# s7 (tamanho de linha na matriz de movimentação)	
		la t0, matriz_movimentacao_pallet	
		
		lw s7, 0(t0)			# s7 recebe o tamanho de uma linha da matriz da área
				
		addi t0, t0, 8
	
		addi s6, t0, 1272	# o personagem começa na linha 53 e coluna 16 da matriz
					# então é somado o endereço base da matriz (t0) a 
		addi s6, s6, 16		# 53 (número da linha) * 24 (tamanho de uma linha da matriz) 
					# e a 16 (número da coluna) 		

		j FIM_RENDERIZAR_PALLET

	PALLET_PP_CASA_RED:
	# Se a0 == 00 então o ponto de entrada é pela casa do RED
		
	# Atualizando os registradores salvos para essa área
		# Atualizando o valor de s0 (posição atual do RED no frame 0)
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			li a2, 97 			# numero da coluna do RED = 97
			li a3, 109			# numero da linha do RED = 109
			call CALCULAR_ENDERECO	
		
			mv s0, a0		# move o endereço retornado para s0
	
		# Atualizando o valor de s1 (orientação do personagem)
			li s1, 3	# inicialmente virado para baixo
		
		# Atualizando o valor de s2 (endereço da subsecção na matriz de tiles ques está sendo 
		# mostrada) e s3 (tamanho de uma linha da matriz de tiles)
			la s2, matriz_tiles_pallet	# carregando em s2 o endereço da matriz
		
			lw s3, 0(s2)		# s3 recebe o tamanho de uma linha da matriz
		
			addi s2, s2, 8		# pula para onde começa os pixels no .data
		
			addi s2, s2, 1067	# pula para onde começa a subsecção que será mostrada na tela
						# (1a coluna e 41a linha da matriz de tiles)
						
		# Atualizando o valor de s4 (endereço da imagem com os tiles da área)
			la s4, tiles_pallet				
			addi s4, s4, 8		# pula para onde começa os pixels no .data			
		
		# Atualizando o valor de s5 (posição atual do personagem na matriz de tiles)						
			la t0, matriz_tiles_pallet
			addi t0, t0, 8			# pula para onde começa os pixels no .data
			addi s5, t0, 1229		# o RED começa na linha 47 e coluna 7 da matriz
							# de tiles, então é somado (47 * 26(tamanho de
							# uma linha da matriz)) + 7		
																																												
		# Atualizando o valor de s6 (posição atual na matriz de movimentação da área) e 
		# s7 (tamanho de linha na matriz de movimentação)	
		la t0, matriz_movimentacao_pallet	
		
		lw s7, 0(t0)			# s7 recebe o tamanho de uma linha da matriz da área
				
		addi t0, t0, 8
	
		addi s6, t0, 1128	# o personagem começa na linha 47 e coluna 6 da matriz
					# então é somado o endereço base da matriz (t0) a 
		addi s6, s6, 6		# 47 (número da linha) * 24 (tamanho de uma linha da matriz) 
					# e a 6 (número da coluna) 		
	
	FIM_RENDERIZAR_PALLET:
																															
	# Imprimindo as imagens da área no frame 0	
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
							
		# Imprimindo a imagem de pallet no frame 0
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF000000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES_AREA				
		
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
									
	# Imprimindo a imagem da área no frame 1	
		# Imprimindo a imagem de pallet no frame 1
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF100000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES_AREA
																				
	# Mostra o frame 0		
	li t0, 0xFF200604		# t0 = endereço para escolher frames 
	sb zero, (t0)			# armazena 0 no endereço de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
		
			
# ====================================================================================================== #

RENDERIZAR_LABORATORIO:
	# Procedimento que imprime a imagem do laboratorio no frame 0 e no frame 1
	# de acordo com o ponto de entrada, além de atualizar os registradores salvos
	# Argumentos:
	# 	a0 = indica o ponto de entrada na área, ou seja, por onde o RED está entrando nessa área
	#	Para essa área os pontos de entrada possíveis são:
	#		PP = 00 -> Entrada pela porta 						

	# OBS: não é necessário empilhar o valor de ra pois a chegada a este procedimento é por meio
	# de uma instrução de branch e a saída é pelo ra empilhado por RENDERIZAR_AREA
	
	# Não é nem necessário verificar o ponto de entrada por que essa área só tem um (PP = 0) de qualquer forma 	
	
	# Atualizando os registradores salvos para essa área
		# Atualizando o valor de s0 (posição atual do RED no frame 0)
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			li a2, 145 			# numero da coluna do RED = 145
			li a3, 205			# numero da linha do RED = 205
			call CALCULAR_ENDERECO	
		
			mv s0, a0		# move o endereço retornado para s0
	
		# Atualizando o valor de s1 (orientação do personagem)
			li s1, 2	# inicialmente virado para cima
		
		# Atualizando o valor de s2 (endereço da subsecção na matriz de tiles ques está sendo 
		# mostrada) e s3 (tamanho de uma linha da matriz de tiles)
			la s2, matriz_tiles_laboratorio		# carregando em s2 o endereço da matriz
		
			lw s3, 0(s2)		# s3 recebe o tamanho de uma linha da matriz
		
			addi s2, s2, 8		# pula para onde começa os pixels no .data
		
			addi s2, s2, 23		# pula para onde começa a subsecção que será mostrada na tela
						
		# Atualizando o valor de s4 (endereço da imagem com os tiles da área)
			la s4, tiles_laboratorio			
			addi s4, s4, 8		# pula para onde começa os pixels no .data			
		
		# Atualizando o valor de s5 (posição atual do personagem na matriz de tiles)						
			la t0, matriz_tiles_laboratorio
			addi t0, t0, 8			# pula para onde começa os pixels no .data
			addi s5, t0, 296		# o RED começa na linha 13 e coluna 10 da matriz
							# de tiles, então é somado (13 * 22(tamanho de
							# uma linha da matriz)) + 10		
																																												
		# Atualizando o valor de s6 (posição atual na matriz de movimentação da área) e 
		# s7 (tamanho de linha na matriz de movimentação)	
		la t0, matriz_movimentacao_laboratorio
		
		lw s7, 0(t0)			# s7 recebe o tamanho de uma linha da matriz da área
				
		addi t0, t0, 8
	
		addi s6, t0, 208	# o personagem começa na linha 13 e coluna 7 da matriz
					# então é somado o endereço base da matriz (t0) a 
		addi s6, s6, 7		# 13 (número da linha) * 16 (tamanho de uma linha da matriz) 
					# e a 7 (número da coluna) 	
														
	# Imprimindo as imagens da área no frame 0
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
								
		# Imprimindo a imagem da sala do RED no frame 0
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF000000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES_AREA		
				
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
									
	# Imprimindo a imagem da área no frame 1	
		# Imprimindo a imagem da sala do RED no frame 1
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF100000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES_AREA																				
																																																							
	# Mostra o frame 0		
	li t0, 0xFF200604		# t0 = endereço para escolher frames 
	sb zero, (t0)			# armazena 0 no endereço de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #
												
TRANSICAO_ENTRE_AREAS:
	# Procedimento que renderiza uma pequena seta para indicar a transição entre área e pergunta
	# ao jogador se ele deseja sair da área atual
	# As setas sempre são renderizadas em um tile adjacende ao RED dependendo da sua orientação atual
	# e sempre no frame 0
	#
	# Argumentos:
	# 	a0 = número indicando qual o tipo de mensagem deve ser impressa durante a transição
	#		a0 = 0 -> mensagem "Sair" da área
	#		a0 = 1 -> mensagem "Entrar" na área

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Antes é necessário imprimir a mensagem indicando qual tecla apertar e a mensagem para sair ou 
	# entrar na área
		beq a0, zero, MENSAGEM_SAIR_AREA
		# se a0 != 0 a mensagem a ser impressa é a de entrada na área
			la t2, mensagem_entrar_area	# carreaga a imagem
			li a2, 241			# numero da coluna onde a imagem sera impressa
			li a3, 208			# numero da linha onde a imagem sera impressa
			j PRINT_MENSAGEM_TRANSICAO_AREAS
		
		MENSAGEM_SAIR_AREA:
		# se a0 == 0 a mensagem a ser impressa é a de saída da área
			la t2, mensagem_sair_area	# carreaga a imagem
			li a2, 256			# numero da coluna onde a imagem sera impressa
			li a3, 208			# numero da linha onde a imagem sera impressa
			
		PRINT_MENSAGEM_TRANSICAO_AREAS:
		
		# Essa mensagem sempre fica em uma posição fixa no frame 0 que é calculada abaixo
			li a1, 0xFF000000		# seleciona como argumento o frame 0
			# a2 já tem o numero da coluna 
			# a3 já tem o numero da linha 
			call CALCULAR_ENDERECO	
		
		mv a1, a0	# move o endereço retornado para a1
		
		# Imprimindo a mensagem no frame 0				
		mv a0, t2		# t2 tem o endereço da imagem da mensagem escolhida acima
		# a1 já tem o endereço de onde imprimir a mensagem
		lw a2, 0(a0)		# numero de colunas da imagem 
		lw a3, 4(a0)		# numero de linhas da imagem 	
		addi a0, a0, 8		# pula para onde começa os pixels no .data
		call PRINT_IMG
		
	# O procedimento usa a orientação do personagem (s1) para decidir onde e qual seta renderizar 
	
	# Abaixo é decidido o valor de t3 (endereço no frame 0 de onde colocar o tile da seta) e 
	# t0 (qual a imagem da seta)
	
		bne s1, zero, TRANSICAO_SETA_DIREITA
			# se s1 = 0 o personagem está virado para a esquerda	
			addi t3, s0, -17	# o endereço de onde a seta vai estar é o tile a esquerda do RED
						# e uma coluna para a esquerda
			addi t3, t3, 960	# e 3 linhas para baixo (porque s0 tem na verdade o endereço da 
						# cabeça do RED)
			la t0, seta_transicao_esquerda	# carregando a imagem em t0
			j RENDERIZAR_SETA_DE_TRANSICAO
	
	TRANSICAO_SETA_DIREITA:
		li t1, 1
		bne s1, t1, TRANSICAO_SETA_CIMA
			# se s1 = 1 o personagem está virado para a direita
			addi t3, s0, 15	# o endereço de onde a seta vai estar é o tile a direita do RED
					# e uma coluna para a esquerda			
			addi t3, t3, 960	# e 3 linhas para baixo (porque s0 tem na verdade o endereço da 
						# cabeça do RED)	
			la t0, seta_transicao_direita	# carregando a imagem em t0
			j RENDERIZAR_SETA_DE_TRANSICAO
			
	TRANSICAO_SETA_CIMA:
		li t1, 2
		bne s1, t1, TRANSICAO_SETA_BAIXO
			# se s1 = 1 o personagem está virado para cima	
			li t0, 5120	# 5120 = 320 (tamanho de uma linha do frame) * 16 (altura de um tile)
			sub t3, s0, t0		# o endereço de onde a seta vai estar é o tile acima do RED
			addi t3, t3, 960	# 3 linhas para baixo (porque s0 tem na verdade o endereço da 
						# cabeça do RED)
			addi t3, t3, -1		# e uma coluna para a esquerda			
			la t0, seta_transicao_cima	# carregando a imagem em t0
			j RENDERIZAR_SETA_DE_TRANSICAO
						
	TRANSICAO_SETA_BAIXO:
		li t1, 3
		bne s1, t1, RENDERIZAR_SETA_DE_TRANSICAO
			# se s1 = 3 o personagem está virado para baixo	
			li t0, 5120	# 5120 = 320 (tamanho de uma linha do frame) * 16 (altura de um tile)
			add t3, s0, t0		# o endereço de onde a seta vai estar é o tile abaixo do RED
			addi t3, t3, 960	# 3 linhas para baixo (porque s0 tem na verdade o endereço da 
						# cabeça do RED)
			addi t3, t3, -1		# e uma coluna para a esquerda									
			la t0, seta_transicao_baixo	# carregando a imagem em t0			
						
						
	RENDERIZAR_SETA_DE_TRANSICAO:

	# As setas que indicam a transição de área funcionam que nem um tile normal, a diferença é que 
	# tem fundo transparentes
	
	# Imprimindo tile da seta no frame 0				
		mv a0, t0	# t0 tem o endereço da imagem da seta a ser impressa
		addi a0, a0, 8	# pula para onde começa os pixels no .data
		mv a1, t3	# t3 tem o endereço de onde imprimir o tile
		li a2, 16	# a2 = numero de colunas de um tile
		li a3, 16	# a3 = numero de linhas de um tile
		call PRINT_IMG

	# Agora o loop abaixo é executado esperando que o jogador aperte F (sair da área) ou W,A,S,D 
	LOOP_TRANSICAO_ENTRE_AREAS:
		call VERIFICAR_TECLA
		
		# Se o jogador apertar qualquer tecla de movimento (W, S, A ou D) então ele não deseja sair
		# da área, e os procedimentos de movimentação necessários precisam ser chamados.
		# Porém isso só vai acontecer se a tecla apertada não for a da orientação atual do personagem,
		# Por exemplo, se o RED está virado para a direita então não é para checar a tecla D
		
		# Se o personagem está virado para cima não é para checar a tecla W
		li t0, 2
		beq s1, t0, SAIR_DA_AREA_VERIFICAR_A
		li t0, 'w'
		beq a0, t0, NAO_SAIR_DA_AREA
		
		SAIR_DA_AREA_VERIFICAR_A:
		# Se o personagem está virado para a esquerda não é para checar a tecla A
		beq s1, zero, SAIR_DA_AREA_VERIFICAR_S
		li t0, 'a'
		beq a0, t0, NAO_SAIR_DA_AREA
		
		SAIR_DA_AREA_VERIFICAR_S:
		# Se o personagem está virado para baixo não é para checar a tecla S
		li t0, 3
		beq s1, t0, SAIR_DA_AREA_VERIFICAR_D				
		li t0, 's'
		beq a0, t0, NAO_SAIR_DA_AREA
		
		SAIR_DA_AREA_VERIFICAR_D:		
		# Se o personagem está virado para a direita não é para checar a tecla D
		li t0, 1
		beq s1, t0, SAIR_DA_AREA_VERIFICAR_F		
		li t0, 'd'
		beq a0, t0, NAO_SAIR_DA_AREA
		
		SAIR_DA_AREA_VERIFICAR_F:
		# se o jogador apertou 'f' ele deseja sair da área, então o procedimento retorna
		# para RENDERIZAR_AREA
		li t0, 'f'
		bne a0, t0, LOOP_TRANSICAO_ENTRE_AREAS
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
	
	NAO_SAIR_DA_AREA:
	
	# Se o jogador não deseja sair da área é necessário retirar a imagem da seta, retirar a mensagem
	# de transição de área e chamar o procedimento de movimentação adequado
	
	mv t5, a0	# salva a0 (tecla apertada) em t5
		
	# Limpando o tile onde está a seta de transição no frame 0
		mv a0, t3	# dos cálculos acima t3 ainda tem o endereço no frame 0 onde a seta foi impressa
		call CALCULAR_ENDERECO_DE_TILE	# encontra o endereço do tile onde a seta foi impressa 
						# e o endereço no frame 0 
					
		# o a0 retornado tem o endereço do tile cnde a seta está
		# o a1 retornado tem o endereço de inicio do tile a0 no frame 0
		li a2, 1	# a limpeza vai ocorrer em 1 coluna
		li a3, 1	# a limpeza vai ocorrer em 1 linha 
		call PRINT_TILES_AREA
	
	# Limpando mensagem de transição de área
		# Para isso é necessário limpar 10 tiles em 2 linhas, eles sempre são os mesmos independente 
		# da área. O endereço do primeiro deles está na 13a linha e 15a coluna de tiles a partir de s2
		
		# Calcula o endereço de onde a mensagem está
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 240			# numero da coluna 
		li a3, 208			# numero da linha
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o endereço retornado para a1
		
		li t0, 13		# t0 recebe 13 * s3 (tamanho de uma linha da matriz de tiles), ou
		mul t0, t0, s3		# seja, o tamanho de 16 linhas na matriz de tiles
		addi t0, t0, 15		# move t0 por mais 15 colunas
		add a0, s2, t0		# a0 tem o endereço do 1o tile a ser limpo
		
		# Imprime novamente os tiles da área no lugar da mensagem
	 	# a0 já tem o endereço, na matriz de tiles, de onde começam os tiles a serem impressos
		# a1 já tem o endereço onde os tiles vão começar a ser impressos
		li a2, 5		# número de linhas de tiles a serem impressas
		li a3, 2		# número de linhas de tiles a serem impressas
		call PRINT_TILES_AREA						
																						
	# Agora é preciso chamar o procedimento de movimentação adequado para a tecla apertada pelo jogador
	
	# Antes é preciso remover os valores de ra que foram empilhados até aqui
	addi sp, sp, 12		# remove 3 words da pilha, os valores de ra empilhados em 
				# TRANSICAO_ENTRE_AREAS, RENDERIZAR_AREA e VERIFICAR_MATRIZ_DE_MOVIMENTACAO

	# Detalhe que ainda sobrou um valor de ra na pilha, o que veio do procedimento de movimentação
	# que chamou VERIFICAR_MATRIZ_DE_MOVIMENTACAO, mas como a chamada abaixo pula para o meio de 
	# VERIFICAR_TECLA_MOVIMENTACAO é esse valor de ra que será usado para voltar para o LOOP_PRINCIPAL_JOGO
	 
	mv a0, t5	# t5 ainda tem a tecla que foi apertada pelo jogador, elá sera usada em a0 para
			# escolher o procedimento de movimentação
	j ESCOLHER_PROCEDIMENTO_DE_MOVIMENTACAO
			
# ====================================================================================================== #	
																																			
.data
	.include "../Imagens/areas/casa_red/tiles_casa_red.data"
	.include "../Imagens/areas/casa_red/matriz_tiles_casa_red.data"
	.include "../Imagens/areas/casa_red/matriz_movimentacao_casa_red.data"
	.include "../Imagens/areas/pallet/tiles_pallet.data"
	.include "../Imagens/areas/pallet/matriz_tiles_pallet.data"
	.include "../Imagens/areas/pallet/matriz_movimentacao_pallet.data"
	.include "../Imagens/areas/laboratorio/tiles_laboratorio.data"
	.include "../Imagens/areas/laboratorio/matriz_tiles_laboratorio.data"
	.include "../Imagens/areas/laboratorio/matriz_movimentacao_laboratorio.data"
	
	.include "../Imagens/areas/transicao_de_areas/seta_transicao_cima.data"
	.include "../Imagens/areas/transicao_de_areas/seta_transicao_baixo.data"
	.include "../Imagens/areas/transicao_de_areas/seta_transicao_esquerda.data"
	.include "../Imagens/areas/transicao_de_areas/seta_transicao_direita.data"
	.include "../Imagens/areas/transicao_de_areas/mensagem_sair_area.data"
	.include "../Imagens/areas/transicao_de_areas/mensagem_entrar_area.data"						
