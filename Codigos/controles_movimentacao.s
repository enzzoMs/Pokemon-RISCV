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
			la a4, red_cima		# carrega como argumento o sprite do RED virada para cima		
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
	bne t0, t1, MOVER_TELA_W		# deve se mover é o personagem
	
	
	# Com tudo feito agora é possivel chamar o procedimento de movimentação para o personagem
		# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
		# de acordo com o valor de s8		
		la a5, red_cima_passo_direito
							
		beq s8, zero, MOVER_RED_W		
			la a5, red_cima_passo_esquerdo
						
		MOVER_RED_W:				
		la a4, red_cima	# carrega a imagem do RED parado
		# a5 tem a a imagem do RED dando um passo	
		mv a6, s0		# a animação vai começar onde o RED está (s0)
		li a7, 0		# a3 = 0 = animação para cima																
		call MOVER_PERSONAGEM																																																															
		
	mv s0, a0		# De acordo com o retorno de MOVER_PERSONAGEM a0 tem o endereço de s0 
				# atualizado pela movimentação feita
	
	sub s5, s5, s3		# atualizando o lugar do personagem na matriz de tiles para a posição uma linha
				# acima

	sub s6, s6, s7		# atualiza o valor de s6 para o endereço uma linha acima da atual na matriz 
				# de movimentação 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o próximo
				# será direito e vice-versa
	
	j FIM_MOVIMENTACAO_W									
		
	# -------------------------------------------------------------------------------------------------																				
	
	MOVER_TELA_W:
	# Caso a tela ainda permita movimento é ela que tem que se mover
	# O movimento da tela tem como base o loop abaixo, que tem 4 partes: 
	#	(1) -> move toda a imagem da área que está na tela em um 1 pixel para baixo
	#	(2) -> limpar o sprite antigo do RED do frame
	#  	(3) -> imprime os sprites de movimentação do RED
	#	(4) -> imprime a linha anterior da subsecção da área 1 pixel para baixo
	# Com esses passos é possível passar a sensação de que a tela está se movendo para baixo e revelando
	# uma nova parte da área
	
	li t5, 1		# contador para o número de loops realizados
	li t6, 0x00100000	# t6 será usado para fazer a troca entre frames no loop abaixo	
	
	LOOP_MOVER_TELA_W:
				
		# Parte (1) -> move toda a imagem da área que está na tela em um 1 pixel para baixo
		# Para fazer isso é possível simplesmente trocar os pixels de uma linha do frame com os pixels
		# da proxima linha através do loop abaixo
		
		li t0, 240		# número de linhas de um frame, ou seja, a quantidade de loops abaixo
		sub t0, t0, t5		# o número de loops é controlado pelo número da iteração atual (t5)
		addi t0, t0, 1		# adiciona + 1 porque t5 começa no 1 e não no 0

		li t1, 0xFF012980	# endereço da penultima linha da 1a coluna do frame 0
				
		add t1, t1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# será impressa	
								
		MOVER_TELA_W_LOOP_LINHAS:
			li t2, 320		# número de colunas de um frame
			
		MOVER_TELA_W_LOOP_COLUNAS:		
			lw t3, 0(t1)		# pega 4 pixels do bitmap e coloca em t3
		
			# Na 1a iteração os pixels serão armazenados proxima linha (320), mas nas 
			# iterações seguintes serão armazenados 2 linhas para frente (640)
			
			li t4, 1
			beq t5, t4, MOVER_TELA_W_PRIMEIRA_ITERACAO
				sw t3, 640(t1)	# armazena os 4 pixels de t5 na 2 linhas para frente (640) do 
						# endereço apontado por t1
				j MOVER_TELA_W_PROXIMA_ITERACAO	
				
			MOVER_TELA_W_PRIMEIRA_ITERACAO:	
			
			sw t3, 320(t1)		# armazena os 4 pixels de t5 na proxima linha (320) do endereço
						# apontado por t1
						
			MOVER_TELA_W_PROXIMA_ITERACAO:			
			addi t1, t1, 4		# passa o endereço do bitmap para os próximos pixels
			addi t2, t2, -4		# decrementa o número de colunas restantes
			bne t2, zero, MOVER_TELA_W_LOOP_COLUNAS		# reinicia o loop se t2 != 0    
		
		addi t1, t1, -640		# volta o endereço de t1 duas linhas para trás	
		addi t0, t0, -1			# decrementa o número de linhas restantes
		bne t0, zero, MOVER_TELA_W_LOOP_LINHAS	# reinicia o loop se t0 != 0 
		
		# Parte (2) -> limpar o sprite antigo do RED do frame
		# Para limpar os sprites antigos é possível usar o PRINT_TILES imprimindo 1 coluna
		# 3 linhas (2 tiles do RED + 1 tile de folga)
		
		mv a0, s5	# endereço, na matriz de tiles, de onde começam os tiles a ser impressos,
				# nesse caso, o começo é o tile onde o RED está
		mv a1, s0	# a imagem será impressa onde o RED está (s0)
		
		li t0, 4161	# o endereço do RED na verdade está um pouco abaixo do inicio do tile,
		sub a1, a1, t0	# portanto é necessário voltar o endereço de a1 em 4164 pixels (13 linhas * 
				# 320 + 1 coluna)
		
		li t0, 320	# o endereço de onde os tiles vão ser impressos também muda de acordo com a
		mul t0, t0, t5	# iteração, já que o pixels da tela serão trocados para fazer a imagem "descer"
		add a1, a1, t0	# portanto, 320 * t5 retorna quantos pixels é necessário avançar para encontrar
				# a linha certa onde devem ser impressos os tiles nessa iteração
		
		add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde os tiles
					# será impressa	
					
		li a2, 1		# número de colunas de tiles a serem impressas
		li a3, 3		# número de linhas de tiles a serem impressas
		call PRINT_TILES
		
		# Parte (3) -> imprime o sprite do RED
		# O próximo sprite do RED vai ser decidido de acordo com o número da interação (t3)
		# de modo que a animação siga o seguinte padrão:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		# a0 vai receber o endereço da próxima imagem do RED dependendo do número da iteração (t5)	
		la a0, red_cima
		li t0, 14
		bgt t5, t0, PRINT_RED_MOVER_TELA_W
		
		# Se 2 < t5 <= 14 a imagem a ser impressa é a do RED dando um passo, que é decidida a 
		# partir do valor de s8
		la a0, red_cima_passo_direito
							
		beq s8, zero, PROXIMO_RED_MOVER_TELA_W		
			la a0, red_cima_passo_esquerdo
	
		PROXIMO_RED_MOVER_TELA_W:
		
		li t0, 2
		bgt t5, t0, PRINT_RED_MOVER_TELA_W
		la a0, red_cima
		
		PRINT_RED_MOVER_TELA_W:					
		# Agora imprime a imagem do RED no frame
			# a0 tem o endereço da próxima imagem do RED 			
			mv a1, s0		# s0 possui o endereço do RED no frame 0
			add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
						# será impressa		
			lw a2, 0(a0)		# numero de colunas de uma imagem do RED
			lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG	
		
		# Parte (4) -> imprime a linha anterior da subsecção da área 1 pixel para baixo
		# O que tem que ser feito é imprimir os tiles dessa linha de modo que só vão ser impressas uma 
		# parte da imagem de cada tile de forma a dar a impressão de que a linha desceu 1 pixel e que
		# uma nova parte da área está sendo lentamente revelada
						
		li t3, 0		# contador para o número de tiles impressos
		li t4, 0xFF000000	# t4 vai guardar o endereço de onde os tiles vão ser impressos, sendo
					# que ele é incrementado a cada loop abaixo. Esse endereço aponta
					# para o começo do frame 0
		add t4, t4, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# será impressa		
							
		LOOP_PRINT_PROXIMA_AREA_W:
		
		# Encontrando a imagem do tile	
		sub t0, s2, s3	# basta fazer s2 - s3 para encontrar o endereço de início da linha 
				# anterior da subsecção de tiles que está na tela
			
		add t0, t0, t3	# decide qual o tile a ser impresso de acordo com t3 (número da iteração atual)
		
		lb t0, 0(t0)	# pega o valor do elemento da matriz de tiles apontado por t0
		
		li t1, 256	# t1 recebe 16 * 16 = 256, ou seja, a área de um tile							
		mul t0, t0, t1	# t0 (número do tile) * (16 * 16) retorna quantos pixels esse tile está do 
				# começo da imagem dos tiles
		
		addi t0, t0, 256	# adiciona mais 256 em t0 porque na verdade as imagens são impressas
					# de baixo para cima nesse caso	
						
		li t1, 16		# 16 é o tamanho de uma linha de um tile
		mul t1, t1, t5		# 16 * t5 retorna quantos pixels é necessário voltar para encontrar
		sub t0, t0, t1		# o endereço da linha certa do tile a ser impresso nessa iteração
									
		# Imprimindo a imagem do tile		
		add a0, s4, t0	# a0 recebe o endereço do tile a ser impresso a partir de s4 (imagem dos tiles)
		mv a1, t4	# a1 recebe o endereço de onde imprimir o tile
		li a2, 16	# a2 = numero de colunas de um tile
		mv a3, t5	# a3 tem o número de linhas a serem impressas = o valor de t5 (iteração atual)
		call PRINT_IMG
	
		addi t4, t4, 16		# incrementando o endereço onde os tiles vão ser impressos em 16 pixels
					# porque o tile que acabou de ser impresso tem 16 colunas
		addi t3, t3, 1		# incrementando o número de tiles impressos
		
		li t0, 20
		bne t3, t0, LOOP_PRINT_PROXIMA_AREA_W	# reinicia o loop se t3 != 20
		
	
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP	
		
		call TROCAR_FRAME	# inverte o frame sendo mostrado		
				
		li t0, 0x00100000	# fazendo essa operação xor se t4 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# trocar entre esses valores
		
		addi t5, t5, 1		# incrementa o número de loops realizados						
		li t0, 16
		bne t5, t0, LOOP_MOVER_TELA_W	# reinicia o loop se t3 != 16
	
																																																																																																															
	sub s2, s2, s3		# atualizando a subsecção da área para a linha anterior da atual (s2) 
	
	# Pela maneira que o loop acima é executado na verdade só são feitas 15 iterações e não 16, 
	# portanto, é necessário imprimir novamente as imagem da área em ambos os frames + o sprite do RED 
	# no frame 0 para que tudo fique no lugar certo
		
		# Imprimindo a imagem da área no frame 0
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF000000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES	

		# Imprimindo o sprite do RED no frame 0
		la a0, red_cima		# carrega a imagem do sprite			
		mv a1, s0		# s0 tem a posição do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	

	call TROCAR_FRAME	# inverte o frame sendo mostrado
				# é necessário inverter o frame mais 1 vez para que o frame sendo mostrado
				# seja o 0		
					
		# Imprimindo a imagem da área no frame 1
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF100000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES			
						
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
			la a4, red_esquerda	# carrega como argumento o sprite do RED virada para a esquerda		
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
	bne t0, t1, MOVER_TELA_A		# deve se mover é o personagem
						
	# Com tudo feito agora é possivel chamar o procedimento de movimentação para o personagem
		# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
		# de acordo com o valor de s8		
		la a5, red_esquerda_passo_direito
							
		beq s8, zero, MOVER_RED_A		
			la a5, red_esquerda_passo_esquerdo
						
		MOVER_RED_A:				
		la a4, red_esquerda	# carrega a imagem do RED parado
		# a5 tem a a imagem do RED dando um passo	
		mv a6, s0		# a animação vai começar onde o RED está (s0)
		li a7, 1		# a3 = 1 = animação para a esquerda																
		call MOVER_PERSONAGEM																																																															
		
	mv s0, a0		# De acordo com o retorno de MOVER_PERSONAGEM a0 tem o endereço de s0 
				# atualizado pela movimentação feita
	
	addi s5, s5, -1		# atualizando o lugar do personagem na matriz de tiles para a posição anterior

	addi s6, s6, -1		# atualiza o valor de s6 para o endereço anterior da matriz de movimentação 
						
	xori s8, s8, 1		# inverte o valor de s8, ou seja, se o RED deu um passo esquerdo o próximo
				# será direito e vice-versa
	
	j FIM_MOVIMENTACAO_A									
		
	# -------------------------------------------------------------------------------------------------																				
	
	MOVER_TELA_A:
	# Caso a tela ainda permita movimento é ela que tem que se mover
	# O movimento da tela tem como base o loop abaixo, que tem 4 partes: 
	#	(1) -> move toda a imagem da área que está na tela em um 1 pixel para a direita
	#	(2) -> limpar o sprite antigo do RED do frame
	#  	(3) -> imprime os sprites de movimentação do RED
	#	(4) -> imprime a coluna anterior da subsecção da área 1 pixel para a direita
	# Com esses passos é possível passar a sensação de que a tela está se movendo para a direita e revelando
	# uma nova parte da área
	
	li t5, 1		# contador para o número de loops realizados
	li t6, 0x00100000	# t6 será usado para fazer a troca entre frames no loop abaixo	
	
	LOOP_MOVER_TELA_A:
				
		# Parte (1) -> move toda a imagem da área que está na tela em um 1 pixel para a direita
		# Para fazer isso é possível simplesmente trocar os pixels de uma coluna do frame com os pixels
		# da proxima coluna através do loop abaixo
		
		li t0, 240		# número de linhas de um frame, ou seja, a quantidade de loops abaixo
		
		li t1, 0xFF00013E	# endereço da penultima coluna da primeira linha do frame 0
			
		# Na primeira iteração (t5 == 1) a troca de pixels do frame vai acontecer a partir da penultima
		# coluna da 1 linha (0xFF00013E), mas nas próximas a troca vai acontecer a partir da 
		# antepenúltima coluna (0xFF00013D) porque a troca vai ser alternada entre os frame 0 e 1
		    
		li t2, 1
		beq t5, t2, INICIO_MOVER_TELA_A
			li t1, 0xFF00013D	# endereço da antepenúltima coluna da primeira linha do frame 0
				
		INICIO_MOVER_TELA_A:		
		add t1, t1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# será impressa	
								
		MOVER_TELA_A_LOOP_LINHAS:
			li t2, 320	# número de colunas de um frame
			sub t2, t2, t5	# o número de loops é controlado pelo número da iteração atual (t5)
			
		MOVER_TELA_A_LOOP_COLUNAS:		
			lb t3, 0(t1)		# pega 1 pixel do bitmap e coloca em t3
			
			# Na 1a iteração os pixels serão armazenados na proxima coluna (1), mas nas 
			# iterações seguintes serão armzenados 2 colunas para frente (2)
			
			li t4, 1
			beq t5, t4, MOVER_TELA_A_PRIMEIRA_ITERACAO
				sb t3, 2(t1)	# armazena o pixel de t5 2 colunas para frente (2) do 
						# endereço apontado por t1
				j MOVER_TELA_A_PROXIMA_ITERACAO	
				
			MOVER_TELA_A_PRIMEIRA_ITERACAO:	
			sb t3, 1(t1)		# armazena o pixel de t5 na proxima colunas (-1) ao endereço
						# apontado por t1
						
			MOVER_TELA_A_PROXIMA_ITERACAO:
			addi t1, t1, -1		# passa o endereço do bitmap para o pixel anterior
			addi t2, t2, -1		# decrementa o número de colunas restantes
			bne t2, zero, MOVER_TELA_A_LOOP_COLUNAS		# reinicia o loop se t2 != 0    
		
		li t3, 640		# O loop acima só é feito 320 - t5 vezes, portanto o endereço
		sub t3, t3, t5		# de t1 precisa ser voltado por 320 - t5 colunas e passado
		add t1, t1, t3		# para a proxima linha (320)
						
		addi t0, t0, -1			# decrementa o número de linhas restantes
		bne t0, zero, MOVER_TELA_A_LOOP_LINHAS	# reinicia o loop se t0 != 0 
		
		# Parte (2) -> limpar o sprite antigo do RED do frame
		# Diferente dos outros casos a limpeza do sprite vai acontecer por outra abordagem.
		# Como PRINT_TILES utiliza lw e sw, além de que esse MOVER_TELA_D move a tela 1 pixel por vez,
		# em certos momentos o endereço de onde imprimir os tiles não vai estar alinhado para o 
		# store word, portanto não é possível usar o PRINT_TILES aqui.
		# Para a limpeza será usado o endereço do personagem (s0) junto do PRINT_IMG (que usa lb e sb)
		# imprimindo novamente os 2 tiles onde o RED está e os 2 tiles atrás como uma folga
		
		# Primeiro limpa o tile da cabeça do RED 
		mv a0, s0	# endereço de onde o RED está no frame 0
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endereço da imagem do 
				# tile correspondente
		add a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endereço de inicio do tile
				# no frame 0. Além disso, é necessário avançar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa iteração
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile será impresso	
		li a2, 16		# número de colunas de tiles a serem impressas
		li a3, 16		# número de linhas de tiles a serem impressas
		call PRINT_IMG

		# Limpa o tile do corpo do RED
		addi a0, s0, 960	# somando s0 com 960 passa o endereço de onde o RED está 
					# para o inicio do tile abaixo dele
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endereço da imagem do 
				# tile correspondente
		add a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endereço de inicio do tile
				# no frame 0. Além disso, é necessário avançar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa iteração
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile será impresso	
		li a2, 16		# número de colunas de tiles a serem impressas
		li a3, 16		# número de linhas de tiles a serem impressas
		call PRINT_IMG


		# Limpa o tile a esquerda da cabeça do RED
		addi a0, s0, -16	# somando s0 com -16 passa o endereço de onde o RED está 
					# para o inicio do tile a esquerda dele
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endereço da imagem do 
				# tile correspondente
		add a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endereço de inicio do tile
				# no frame 0. Além disso, é necessário avançar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa iteração
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile será impresso	
		li a2, 16		# número de colunas de tiles a serem impressas
		li a3, 16		# número de linhas de tiles a serem impressas
		call PRINT_IMG
		
		# Limpa o tile na diagonal inferior esquerda da cabeça do RED
		addi a0, s0, -16	# somando s0 com -16 passa o endereço de onde o RED está 
					# para o inicio do tile a esquerda dele
		addi a0, a0, 960	# somando a0 com 960 passa o endereço de a0 para o inicio do tile 
					# abaixo dele
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endereço da imagem do 
				# tile correspondente
		add a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endereço de inicio do tile
				# no frame 0. Além disso, é necessário avançar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa iteração
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile será impresso	
		li a2, 16		# número de colunas de tiles a serem impressas
		li a3, 16		# número de linhas de tiles a serem impressas
		call PRINT_IMG
		
		# Parte (3) -> imprime o sprite do RED
		# O próximo sprite do RED vai ser decidido de acordo com o número da interação (t3)
		# de modo que a animação siga o seguinte padrão:
		# RED PARADO -> RED DANDO UM PASSO -> RED PARADO
		
		# a0 vai receber o endereço da próxima imagem do RED dependendo do número da iteração (t5)	
		la a0, red_esquerda
		li t0, 14
		bgt t5, t0, PRINT_RED_MOVER_TELA_A
		
		# Se 2 < t5 <= 14 a imagem a ser impressa é a do RED dando um passo, que é decidida a 
		# partir do valor de s8
		la a0, red_esquerda_passo_direito
							
		beq s8, zero, PROXIMO_RED_MOVER_TELA_A		
			la a0, red_esquerda_passo_esquerdo
	
		PROXIMO_RED_MOVER_TELA_A:
		
		li t0, 2
		bgt t5, t0, PRINT_RED_MOVER_TELA_A
		la a0, red_esquerda
		
		PRINT_RED_MOVER_TELA_A:					
		# Agora imprime a imagem do RED no frame
			# a0 tem o endereço da próxima imagem do RED 			
			mv a1, s0		# s0 possui o endereço do RED no frame 0
			add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
						# será impressa		
			lw a2, 0(a0)		# numero de colunas de uma imagem do RED
			lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG	
		
		# Parte (4) -> imprime a coluna anterior da subsecção da área 1 pixel para a direita
		# O que tem que ser feito é imprimir os tiles dessa coluna de modo que só vão ser impressas uma 
		# parte da imagem de cada tile de forma a dar a impressão de que a coluna avançou 1 pixel e que
		# uma nova parte da área está sendo lentamente revelada
		
		# O procedimento PRINT_IMG tem uma limitação: ele não é capaz de imprimir partes de imagens se
		# essas partes tem um número de colunas diferente da imagem completa, por exemplo: imprimir 
		# uma parte 6 x 15 de uma imagem 10 x 15, para imprimir uma parte de imagem é necessário que essa 
		# parte tenha o mesmo número de colunas que a imagem original 				
		# Essa limitação dificulta essa parte do procedimneto, portanto a abordagem será diferente:
		# Para cada 1 dos 20 tiles da coluna serão impressas individualmente as 16 linhas do tile
																														
		li t3, 0		# contador para o número de tiles impressos
						
		LOOP_TILES_PROXIMA_AREA_A:
		
		li t4, 0		# contador para o número de linhas de cada tile impressas

		LOOP_LINHAS_PROXIMA_AREA_A:	
					
		# Encontrando a imagem do tile	
		addi t0, s2, -1		# s2 - 1 retorna o endereço de início da coluna anterior da
					# subsecção de tiles que está na tela 
		
		mul t1, s3, t3		# decide qual o tile da coluna que será impresso de acordo com 
		add t0, t0, t1		# t3 (número do tile atual)		
		
		lb t0, 0(t0)	# pega o valor do elemento da matriz de tiles apontado por t0
			
		li t1, 256	# t1 recebe 16 * 16 = 256, ou seja, a área de um tile							
		mul t0, t0, t1	# t0 (número do tile) * (16 * 16) retorna quantos pixels esse tile está do 
				# começo da imagem dos tiles
		
		li t1, 16	# decide qual a coluna do tile que será impressa de acordo com t5 (número
		sub t1, t1, t5 	# da iteração atual)
		add t0, t0, t1	
		
		li t1, 16	# decide qual a linha do tile que será impressa de acordo com 
		mul t1, t1, t4	# t4 (número da linha atual do tile)	
		add t0, t0, t1		
												
		# Imprimindo a linha do tile		
		add a0, s4, t0	# a0 recebe o endereço da linha do tile a ser impresso a partir 
				# de s4 (imagem dos tiles)
		
		li a1, 0xFF000000	# a1 recebe o endereço do 1o pixel da primaira linha do frame 0,
					# ou seja, onde o 1o tile dessa coluna será impresso 
						
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
		bne t4, t0, LOOP_LINHAS_PROXIMA_AREA_A		# reinicia o loop se t4 != 16
			
		addi t3, t3, 1		# incrementando o número de tiles impressos
		li t0, 15	
		bne t3, t0, LOOP_TILES_PROXIMA_AREA_A		# reinicia o loop se t3 != 15
		
	
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP	
		
		call TROCAR_FRAME	# inverte o frame sendo mostrado		
				
		li t0, 0x00100000	# fazendo essa operação xor se t4 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# trocar entre esses valores
		
		addi t5, t5, 1		# incrementa o número de loops realizados						
		li t0, 16
		bne t5, t0, LOOP_MOVER_TELA_A	# reinicia o loop se t3 != 16
	
																																																																																																															
	addi s2, s2, -1		# atualizando a subsecção da área para a coluna anterior da atual (s2) 
	
	# Pela maneira que o loop acima é executado na verdade só são feitas 15 iterações e não 16, 
	# portanto, é necessário imprimir novamente as imagem da área em ambos os frames + o sprite do RED 
	# no frame 0 para que tudo fique no lugar certo
		
		# Imprimindo a imagem da área no frame 0
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF000000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES	
	
		# Imprimindo o sprite do RED no frame 0
		la a0, red_esquerda	# carrega a imagem do sprite			
		mv a1, s0		# s0 tem a posição do RED no frame 0
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
	
	call TROCAR_FRAME	# inverte o frame sendo mostrado
				# é necessário inverter o frame mais 1 vez para que o frame sendo mostrado
				# seja o 0		
					
		# Imprimindo a imagem da área no frame 1
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF100000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
		call PRINT_TILES			
						
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
			la a4, red_baixo	# carrega como argumento o sprite do RED virada para baixo		
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
								
	# Com tudo feito agora é possivel chamar o procedimento de movimentação para o personagem
		# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
		# de acordo com o valor de s8		
		la a5, red_baixo_passo_direito
							
		beq s8, zero, MOVER_RED_S		
			la a5, red_baixo_passo_esquerdo
						
		MOVER_RED_S:				
		la a4, red_baixo	# carrega a imagem do RED parado
		# a5 tem a a imagem do RED dando um passo	
		mv a6, s0		# a animação vai começar onde o RED está (s0)
		li a7, 2		# a3 = 2 = animação para baixo																
		call MOVER_PERSONAGEM																																																															
		
	mv s0, a0		# De acordo com o retorno de MOVER_PERSONAGEM a0 tem o endereço de s0 
				# atualizado pela movimentação feita
	
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
		# Para limpar os sprites antigos é possível usar o PRINT_TILES imprimindo 1 coluna
		# 3 linhas (2 tiles do RED + 1 tile de folga)
		
		mv a0, s5	# endereço, na matriz de tiles, de onde começam os tiles a ser impressos,
				# nesse caso, o começo é o tile onde o RED está
		mv a1, s0	# a imagem será impressa onde o RED está (s0)
		
		li t0, 4161	# o endereço do RED na verdade está um pouco abaixo do inicio do tile,
		sub a1, a1, t0	# portanto é necessário voltar o endereço de a1 em 4164 pixels (13 linhas * 
				# 320 + 1 coluna)
		
		li t0, 320	# o endereço de onde os tiles vão ser impressos também muda de acordo com a
		mul t0, t0, t5	# iteração, já que o pixels da tela serão trocados para fazer a imagem "subir"
		sub a1, a1, t0	# portanto, 320 * t5 retorna quantos pixels é necessário voltar para encontrar
				# a linha certa onde devem ser impressos os tiles nessa iteração
		
		add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde os tiles
					# será impressa	
					
		li a2, 1		# número de colunas de tiles a serem impressas
		li a3, 3		# número de linhas de tiles a serem impressas
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
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF000000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
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
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF100000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
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
			la a4, red_direita	# carrega como argumento o sprite do RED virada para a direita		
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
	
								
	# Com tudo feito agora é possivel chamar o procedimento de movimentação para o personagem
		# Decide se o RED vai ser renderizado dando o passo com o pé esquedo ou direito
		# de acordo com o valor de s8		
		la a5, red_direita_passo_direito
							
		beq s8, zero, MOVER_RED_D		
			la a5, red_direita_passo_esquerdo
						
		MOVER_RED_D:				
		la a4, red_direita	# carrega a imagem do RED parado
		# a5 tem a a imagem do RED dando um passo	
		mv a6, s0		# a animação vai começar onde o RED está (s0)
		li a7, 3		# a3 = 3 = animação para a direita																
		call MOVER_PERSONAGEM																																																															
		
	mv s0, a0		# De acordo com o retorno de MOVER_PERSONAGEM a0 tem o endereço de s0 
				# atualizado pela movimentação feita
	
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
		# Diferente dos outros casos a limpeza do sprite vai acontecer por outra abordagem.
		# Como PRINT_TILES utiliza lw e sw, além de que esse MOVER_TELA_D move a tela 1 pixel por vez,
		# em certos momentos o endereço de onde imprimir os tiles não vai estar alinhado para o 
		# store word, portanto não é possível usar o PRINT_TILES aqui.
		# Para a limpeza será usado o endereço do personagem (s0) junto do PRINT_IMG (que usa lb e sb)
		# imprimindo novamente os 2 tiles onde o RED está e os 2 tiles a frente como uma folga
		
		# Primeiro limpa o tile da cabeça do RED 
		mv a0, s0	# endereço de onde o RED está no frame 0
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endereço da imagem do 
				# tile correspondente
		sub a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endereço de inicio do tile
				# no frame 0. Além disso, é necessário voltar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa iteração
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile será impresso	
		li a2, 16		# número de colunas de tiles a serem impressas
		li a3, 16		# número de linhas de tiles a serem impressas
		call PRINT_IMG

		# Limpa o tile do corpo do RED
		addi a0, s0, 960	# somando s0 com 960 passa o endereço de onde o RED está 
					# para o inicio do tile abaixo dele
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endereço da imagem do 
				# tile correspondente
		sub a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endereço de inicio do tile
				# no frame 0. Além disso, é necessário voltar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa iteração
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile será impresso	
		li a2, 16		# número de colunas de tiles a serem impressas
		li a3, 16		# número de linhas de tiles a serem impressas
		call PRINT_IMG


		# Limpa o tile a direita da cabeça do RED
		addi a0, s0, 16		# somando s0 com 16 passa o endereço de onde o RED está 
					# para o inicio do tile a direita dele
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endereço da imagem do 
				# tile correspondente
		sub a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endereço de inicio do tile
				# no frame 0. Além disso, é necessário voltar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa iteração
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile será impresso	
		li a2, 16		# número de colunas de tiles a serem impressas
		li a3, 16		# número de linhas de tiles a serem impressas
		call PRINT_IMG
		
		# Limpa o tile na diagonal inferior direita da cabeça do RED
		addi a0, s0, 16		# somando s0 com 16 passa o endereço de onde o RED está 
					# para o inicio do tile a direta dele
		addi a0, a0, 960	# somando a0 com 960 passa o endereço de a0 para o inicio do tile 
					# abaixo dele
		call CALCULAR_ENDERECO_DE_TILE
		
		mv a0, a2 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a2 tem o endereço da imagem do 
				# tile correspondente
		sub a1, a1, t5 	# Pelo retorno de CALCULAR_ENDERECO_DE_TILE a1 tem o endereço de inicio do tile
				# no frame 0. Além disso, é necessário voltar a1 por t5 colunas para imprimir
				# o tile no lugar certo nessa iteração
		add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde o tile será impresso	
		li a2, 16		# número de colunas de tiles a serem impressas
		li a3, 16		# número de linhas de tiles a serem impressas
		call PRINT_IMG
														
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
												
		# Imprimindo a linha do tile		
		add a0, s4, t0	# a0 recebe o endereço da linha do tile a ser impresso a partir 
				# de s4 (imagem dos tiles)
		
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
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF000000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
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
		mv a0, s2		# endereço, na matriz de tiles, de onde começa a imagem a ser impressa
		li a1, 0xFF100000	# a imagem será impressa no frame 0
		li a2, 20		# número de colunas de tiles a serem impressas
		li a3, 15		# número de linhas de tiles a serem impressas
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
	# 	 a4 = endereço base da imagem do RED na orientação desejada
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
			
	# Primeiro é necessário "limpar" o antigo sprite do RED dos frames. Isso é feito imprimindo novamente
	# os dois tiles onde o RED está através de PRINT_TILES
		
	# Imprimindo os tiles e limpando a tela no frame 1
		mv a0, s0		# a0 recebe o endereço de onde o RED está no frame 0 (s0)
		call CALCULAR_ENDERECO_DE_TILE	# encontra o endereço do tile onde o RED está na matriz e o 
						# no frame 0
		
		mv t4, a0	# salva o retorno a0 em t4
		mv t5, a1	# salva o retorno a1 em t5
		
		# o a0 retornado tem o endereço do tile cnde o RED está
		li t0, 0x00100000	# o a1 retornado tem o endereço de inicio do tile a0 no frame 0, ou seja, 
		add a1, a1, t0 		# o endereço onde os tiles vão começar a ser impressos para a limpeza
					# através da soma com t0 o endereço de a1 passa para o frame 1
		li a2, 1	# a limpeza vai ocorrer em 1 coluna
		li a3, 3	# a limpeza vai ocorrer em 3 linhas (2 onde o RED está e mais 1 de folga)
		call PRINT_TILES
				
	# Agora imprime a nova imagem do RED no frame 0
		mv a0, a4		# a4 tem o endereço da imagem a ser impressa
		mv a1, s0		# s0 possui o endereço do RED no frame 0
		li t0, 0x00100000 	# através da soma com t0 o endereço de a1 passa para o frame 1
		add a1, a1, t0		
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
	
	call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
	
	# Imprimindo os tiles e limpando a tela no frame 0
		mv a0, t4	# t4 tem salvo o endereço do tile cnde o RED está
		mv a1, t5	# t5 tem salvo o endereço de inicio do tile a0 no frame 0, ou seja, o 
				# endereço onde os tiles vão começar a ser impressos para a limpeza
		li a2, 1	# a limpeza vai ocorrer em 1 coluna
		li a3, 3	# a limpeza vai ocorrer em 3 linhas (2 onde o RED está e mais 1 de folga)
		call PRINT_TILES
				
	# Agora imprime a nova imagem do RED no frame 0
		mv a0, a4		# a4 tem o endereço da imagem a ser impressa
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

MOVER_PERSONAGEM:
	# Procedimento que realiza uma animação de movimentação para um personagem.
	# Esse procedimento existe para que possa ser usado tanto para a animação do RED quanto do 
	# professor Carvalho, portanto parte do pressuposto de que os sprites tem no máximo 2 tiles de tamanho,
	# de modo que executa a aniamação pixel por pixel, de um tile para o outro.
	# A animação sempre segue o padrão: PERSONAGEM PARADO -> PERSONAGEM DANDO UM PASSO -> PERSONAGEM PARADO.
	# O procedimento funciona imprimindo os sprites do personagem de maneira alternada entres os 
	# frames 0 e 1. Para fazer corretamente a troca entre frames o endereço de a6 precisa ser do
	# frame 0. Além disso, esse procedimento sempre é chamado com o frame 0 sendo msotrado e, apesar
	# das tracas de frames, sempre retorna com o frame 0 na tela.  
	#
	# Argumentos:
	# 	a4 = sprite do personagem parado (qualquer direção)
	# 	a5 = sprite do personagem dando um passo (seja esquerdo ou direito para qualquer direção)
	# 	a6 = endereço no frame 0 de onde começar a movimentação
	# 	a7 = qual a direção da movimentação, de modo que:
	#		[ 0 ] -> movimentação para cima
	#		[ 1 ] -> movimentação para a esquerda
	#		[ 2 ] -> movimentação para baixo
	#		[ 3 ] -> movimentação para a direita
	#
	# Retorno:
	#	a0 = endereço de a6 atualizado para a nova posição de acordo com a movimentação feita
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																									
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, 0(sp)		# empilha ra
	
	li t4, 16		# contador para o número de pixels que o personagem vai se deslocar, ou seja,
				# o número de loops a serem executados abaixo
					
	mv t5, a4		# t5 vai guardar o endereço da próxima imagem do personagem
				# o loop de movimentação começa imprimindo a imagem do presonagem parado (a4) 
	
	li t6, 0x00100000	# t6 será usada para fazer a troca entre frames no loop de movimentação	
				# O loop abaixo começa imprimindo os sprites no frame 1 já que se parte
				# do pressuposto de que o frame 0 é o que está sendo mostrado
																																							
	LOOP_MOVER_PERSONAGEM:

		call TROCAR_FRAME		# inverte o frame sendo mostrado
			
		# Primeiro é necessário "limpar" o antigo sprite do personagem da tela. 
		# Isso é feito imprimindo novamente os tiles onde o personagem está através de PRINT_TILES
 		# A quantidade de tiles a serem limpos depende da orientação da movimentação (a7) porque em
		# alguns casos durante o personagem fica na intersecção entre vários tiles diferentes
			
		# Abaixo é decidido a quantidade de pixels em que o endereço de a6 será incrementado 
		# ou decrementado (t0), quantidade de tiles para a limpeza da tela (t1 e t2) e endereço
		# de inicio da limpeza a partir de a6 (t3)
	
		bne a7, zero, MOVER_PERSONAGEM_ESQUERDA
			li t0, -320 	# Caso a7 == 0 a movimentação é para cima, então o endereço de a6 vai ser 
					# decrementado em -320 pixels, ou seja, vai voltar 1 linha
			li t1, 3	# a limpeza vai ocorrer em 3 linhas
			li t2, 1	# a limpeza vai ocorrer em 1 coluna
			li t3, 0	# a limpeza começa no mesmo endereço de a6
			j MOVER_PERSONAGEM_LIMPAR_TELA
		
		MOVER_PERSONAGEM_ESQUERDA:
		li t0, 1
		bne a7, t0, MOVER_PERSONAGEM_BAIXO
			li t0, -1 	# Caso a7 == 1 a movimentação é para a esquerda, então o endereço de a6 
					# vai ser decrementado em -1 pixel, ou seja, vai voltar 1 coluna
			li t1, 2	# a limpeza vai ocorrer em 2 linhas
			li t2, 2	# a limpeza vai ocorrer em 2 colunas
			li t3, 0	# a limpeza começa no mesmo endereço de a6
			j MOVER_PERSONAGEM_LIMPAR_TELA

		MOVER_PERSONAGEM_BAIXO:
		li t0, 2
		bne a7, t0, MOVER_PERSONAGEM_DIREITA
			li t0, 320	# Caso a7 == 2 a movimentação é para baixo, então o endereço de a6 
					# vai ser incrementado em 320 pixels, ou seja, vai avançar 1 coluna
			li t1, 3	# a limpeza vai ocorrer em 3 linhas
			li t2, 1	# a limpeza vai ocorrer em 1 coluna
			li t3, -5120	# t3 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frema),
					# ou seja, a limpeza começa no tile acima de a6
			j MOVER_PERSONAGEM_LIMPAR_TELA
		
		MOVER_PERSONAGEM_DIREITA:
		# Caso a7 == 3 a movimentação é para a direita, então o endereço de a6 vai ser incrementado em 
		# 1 pixels a cada iteração, ou seja, vai avançar 1 coluna
			li t0, 1 	# Caso a7 == 3 a movimentação é para a direita, então o endereço de a6 
					# vai ser incrementado em 1 pixels, ou seja, vai avançar 1 coluna
			li t1, 2	# a limpeza vai ocorrer em 2 linhas
			li t2, 2	# a limpeza vai ocorrer em 2 colunas
			li t3, -16	# a limpeza começa no tile anterior a a6

		MOVER_PERSONAGEM_LIMPAR_TELA:
		
		add a6, a6, t0	# incrementa o endereço de a6 (endereço onde o sprite do personagem será 
		# impresso) para a próxima posição de acordo com o valor calculado em t0		
		
		# Imprimindo os tiles e limpando a tela 
			add t0, a6, t3		# t0 recebe o endereço de a6 atualizado com o valor de t3
						# definido acima
		
			mv t3, t2		# salva t2 em t3
			mv a3, t1		# t1 número de linhas de tiles a serem impressas
		
			mv a0, t0			# encontra o endereço do tile na matriz e o endereço do
			call CALCULAR_ENDERECO_DE_TILE	# frame onde os tiles serão impressos com base no valor 
							# de t0 definido acima
		
			mv a0, a0	# o a0 retornado tem o endereço do tile correspondente
			
			mv a2, t3	# t3 tem o número de colunas de tiles a serem impressas
					
			mv a1, a1	# o a1 tem o endereço de inicio do tile a0 no frame, ou seja, o 
					# endereço onde os tiles vão começar a ser impressos
			add a1, a1, t6	# decide a partir do valor de t6 qual o frame onde os tiles serão
					# impressos
			call PRINT_TILES
																							
		# Agora imprime a imagem do personagem no frame
			mv a0, t5		# t5 tem o endereço da próxima imagem do personagem 			
			mv a1, a6		# a6 possui o endereço de onde renderizar o personagem
			add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
						# será impressa			
			lw a2, 0(a0)		# numero de colunas de uma imagem do personagem
			lw a3, 4(a0)		# numero de linhas de uma imagem do personagem	
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG	
						
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1
		
		li t0, 0x00100000	# com essa operação xor se t6 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# ficar alternando entre esses valores
					
		# Determina qual é o próximo sprite do personagem a ser renderizado,
		# de modo que a animação siga o seguinte padrão:
		# PERSONAGEM PARADO -> PERSONAGEM DANDO UM PASSO -> PERSONAGEM PARADO
		
		addi t4, t4, -1		# decrementa o número de loops restantes
		
		# t5 vai guardar o endereço da próxima imagem do RED		
		mv t5, a4		# a4 tem a imagem do personagem parado
		li t0, 14		
		bgt t4, t0, LOOP_MOVER_PERSONAGEM
		mv t5, a5		# a5 tem o endereço da imagem do personagem dando um passo
		li t0, 2
		bgt t4, t0, LOOP_MOVER_PERSONAGEM
		mv t5, a4		# a4 tem a imagem do personagem parado
		bne t4, zero, LOOP_MOVER_PERSONAGEM
			
	mv a0, a6	# move para a0 o endereço de a6 atualizado durante o loop acima	
				
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
	
	# se t0 >= 64 então essa posição indica uma transição entre área, nesse caso RENDERIZAR_AREA tem
	# que ser chamado e depois os procedimentos de movimentação devem ocorrer
	
	li t1, 64						
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
