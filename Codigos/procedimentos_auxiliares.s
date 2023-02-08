.text

# ====================================================================================================== # 
# 					PROCEDIMENTOS AUXILIARES				         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo contém uma coleção de procedimentos auxiliares com o objetivo de facilitar a execução de  # 
# certas tarefas ao longo da execução do programa.							 #
#													 #
# ====================================================================================================== #

PRINT_TELA:
	# Procedimento que imprime uma imagem de 320 x 240 no frame de escolha
	#
	# Argumentos: 
	# 	a0 = endereço da imgagem		
	# 	a1 = endereço do frame
	
	li t0, 76800		# area total da imagem -> 320 x 240 = 76800 pixels
	addi a0, a0, 8		# pula para onde começa os pixels no .data
	li t1, 0		# contador de quantos pixels já foram impressos

	LOOP_PRINT_IMG: 
		beq t0, t1, FIM_PRINT_IMG	# verifica se todos os pixels foram colocados
		lw t3, 0(a0)			# pega 4 pixels do .data e coloca em t3
		sw t3, 0(a1)			# pega os pixels de t3 e coloca no bitmap
		addi a0, a0, 4			# vai para os próximos pixels da imagem
		addi a1, a1, 4			# vai para os próximos pixels do bitmap
		addi t1, t1, 4			# incrementa contador com os pixels colocados
		j LOOP_PRINT_IMG		# reinicia o loop

	FIM_PRINT_IMG:
		ret 

# ====================================================================================================== #

PRINT_IMG:
	# Procedimento que imprime imagens de tamanho variado, menores que 320 x 240, no frame de escolha.
	# Esse procedimento também é equipado para lidar com imagens que contém pixels de cor transparente
	# (0xC7), nesse caso PRINT_IMG vai verificar se algum pixel tem essa cor, e os que tiverem não
	# serão renderizados na tela. Isso precisa ser feito ao invés de simplesmente renderizar os
	# os pixels transparentes por conta de alguns bugs visuais, sobretudo no RARS. 
	# Geralmente esse procedimento é usado para imprimir imagens pequenas, cosias muito grandes são
	# divididas e impressas com o PRINT_TILES
	#
	# Argumentos: 
	# 	a0 = endereço da imagem		
	# 	a1 = endereço de onde, no frame escolhido, a imagem deve ser renderizada
	# 	a2 = numero de colunas da imagem
	#	a3 = numero de linhas da imagem
	
	li t0, 0xC7		# t0 tem o valor da cor de um pixel transparente
	
	PRINT_IMG_LINHAS:
		mv t1, a2		# copia do numero de a2 para usar no loop de colunas
			
		PRINT_IMG_COLUNAS:
			lbu t2, 0(a0)			# pega 1 pixel do .data e coloca em t2
			
			# Se o valor do pixel do .data (t2) for 0xC7 (pixel transparente), 
			# o pixel não é armazenado no bitmap, e por consequência não é renderizado na tela
			beq t2, t0, NAO_ARMAZENAR_PIXEL
				sb t2, 0(a1)			# pega o pixel de t2 e coloca no bitmap
	
			NAO_ARMAZENAR_PIXEL:
			addi t1, t1, -1			# decrementa o numero de colunas restantes
			addi a0, a0, 1			# vai para o próximo pixel da imagem
			addi a1, a1, 1			# vai para o próximo pixel do bitmap
			bne t1, zero, PRINT_IMG_COLUNAS	# reinicia o loop se t1 != 0
			
		addi a3, a3, -1			# decrementando o numero de linhas restantes
		
		sub a1, a1, a2			# volta o endeço do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endereço do bitmap para a proxima linha
		
		bne a3, zero, PRINT_IMG_LINHAS	# reinicia o loop se a3 != 0
			
	ret

# ====================================================================================================== #
	
PRINT_TILES_AREA:
	# Procedimento auxiliar que tem por objetivo usar uma matriz de tiles para imprimir uma imagem
	# de uma área 
	# As imagens podem ter tamanho variado, sempre medido pelo numero de tiles impressos
	# Cada área do jogo é dividida em quadrados de 16 x 16, cada um desses quadrados únicos configura 
	# um tile diferente. Esses tiles são organizados em uma imagem própria de modo que cada 
	# tile fica um em baixo do outro (ver "../Imagens/areas/tiles_casa_red.bmp" para um exemplo).
	# Cada tile recebe um número diferente que representa a posição do tile nessa imagem, 
	# dessa forma, as imagens das áreas podem simplesmente ser codificadas como uma matriz
	# em que cada elemento representa o número de um tile, com isso, renderizar a imagem de uma
	# área se trata apenas de analisar a matriz e encontrar os tiles correspondentes.
	# Como cada tile tem 16 x 16 eles recebem números de modo que o tile na posição 1
	# está a (16 * 16) * 1 pixels do ínicio da imagem, o tile na posição 5 está a 
	# (16 * 16) * 5 pixels do incio, e assim por diante, facilitando o processo de "traduzir" os números
	# da matriz para o tile correspondente 
	# O procedimento sempre parte do pressuposto que a matriz de tiles que está sendo passada
	# no argumento a5 é a mesma matriz que está em s2, e portanto, o procedimento usa o valor de s3
	# Além disso, é esperado que a matriz faça referência aos tiles que estão na imagem de 
	# s4 (endereço base da imagem contendo os tiles da área atual)
	# Obs: ver a descrição de PRINT_TILES para a diferença entre os dois procedimentos
	# 
	# Argumentos:
	# 	a0 = endereço, na matriz de tiles, de onde começam os tiles a serem impressos
	#	a1 = endereço no frame 0 ou 1 de onde os tiles vão começar a ser impressos
	# 	a2 = número de colunas de tiles a serem impressas
	# 	a3 = número de linhas de tiles a serem impressas
																	
	# o loop abaixo vai imprimir a6 x a7 tiles
																														
	PRINT_TILES_AREA_LINHAS:
		mv t0, a2		# copia de a2 para usar no loop de colunas
				
		PRINT_TILES_AREA_COLUNAS:
			lb t1, 0(a0)	# pega 1 elemento da matriz de tiles e coloca em t1
		
			li t2, 256	# t2 recebe 16 * 16 = 256, ou seja, a área de um tile							
			mul t1, t1, t2	# como dito na descrição do procedimento t1 (número do tile) * (16 * 16)
					# retorna quantos pixels esse tile está do começo da imagem
			
			add t1, t1, s4	# t1 recebe o endereço do tile a ser impresso
						
			# O modo de impressao se baseia em um loop que emula um PRINT_IMG, a diferença é que
			# como PRINT_IMG pode imprimir imagens com uma tamanho arbitrário de colunas e linhas 
			# ele tem que utlizar instruções load e store byte, mas como cada tile sempre tem 
			# 16 x 16 de tamanho é possível usar load e store word para agilizar o processo
		
			li t2, 256	# numero de pixels de um tile (16 x 16)
			
			PRINT_TILE_AREA_COLUNAS:
			lw t3, 0(t1)		# pega 4 pixels do .data do tile (t1) e coloca em t3
			
			sw t3, 0(a1)		# pega os 4 pixels de t3 e coloca no bitmap
	
			addi t1, t1, 4		# vai para os próximos pixels da imagem
			addi a1, a1, 4		# vai para os próximos pixels do bitmap
			addi t2, t2, -4		# decrementa o numero de pixels restantes
			
			li t3, 16		# largura de um tile
			rem t3, t2, t3		# se o resto de t2 / 16 não for 0 então ainda restam pixels
						# da linha atual para serem impressos
			bne t3, zero, PRINT_TILE_AREA_COLUNAS	# reinicia o loop se t3 != 0
			
			addi a1, a1, -16	# volta o endeço do bitmap pelo numero de colunas impressas
			addi a1, a1, 320	# passa o endereço do bitmap para a proxima linha
			bne t2, zero, PRINT_TILE_AREA_COLUNAS	# reinicia o loop se t2 != 0
	
			addi a0, a0, 1		# vai para o próximo elemento da matriz de tiles
			
			li t1, 5120		# t1 recebe 16 (altura de um tile) * 320 
						# (tamanho de uma linha do frame)
			sub a1, a1, t1		# volta o endereço de a5 pelas linhas impressas			
			addi a1, a1, 16		# pula 16 colunas no bitmap já que o tile impresso tem
						# 16 colunas de tamanho 
			
			addi t0, t0, -1			# decrementando o numero de colunas de tiles restantes
			bne t0, zero, PRINT_TILES_AREA_COLUNAS	# reinicia o loop se t0 != 0
			
		sub a0, a0, a2		# volta o endeço da matriz de tiles pelo numero de colunas impressas
		add a0, a0, s3		# passa o endereço da matriz para a proxima linha (s3 tem o tamanho
					# de uma linha na matriz)
	
		li t1, 16		# t1 recebe a largura de um tile
		mul t1, t1, a2		# 16 * a2 retorna o numero de pixels em a1 foi incrementado no loop acima
		sub a1, a1, t1		# volta a1 pelo numero de colunas de tiles impressas

		li t1, 5120		# t1 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frame)
		add a1, a1, t1		# avança o endereço de a5 para a proxima linha de tiles		
			
		addi a3, a3, -1				# decrementando o numero de linhas restantes
		bne a3, zero, PRINT_TILES_AREA_LINHAS	# reinicia o loop se a3 != 0
				
	ret

# ====================================================================================================== #	
	
PRINT_TILES:
	# Procedimento que tem por objetivo usar uma matriz de tiles para imprimir uma imagem arbitrária
	# Esse procedimento segue os mesmos principios do PRINT_TILES_AREA, utilizando as matrizes e fazendo 
	# a impessão dos tiles da mesma forma. A diferença entre um e outro não é que PRINT_TILES_AREA é 
	# exatamente exclusivo para a impressão de áreas (esse PRINT_TILES também pode imprimir imagens
	# de uma área se quiser), mas sim o número de registradores utilizados entre um e outro. PRINT_TILES_AREA
	# é usado nos procedimentos de movimentação, como existem muitos procedimentos encadeados o resultado
	# é que de um jeito ou de outro todos os registradores (inclusive os de argumentos) são usados. Como
	# a movimentação só reimprime imagens da área então PRINT_TILES_AREA usa esse fato para fazer alguns
	# pressupostos (que a matriz passada no argumento faz referência aos tiles que estão na imagem de s4, 
	# por exemplo) para reduzir o número de registradores usados. Mas esses pressupostos fazem com que
	# não dê para usar o PRINT_TILES_AREA para imprimir uma matriz de tiles que não seja a da área atual
	# (s2), então esse PRINT_TILES supre essa necessidade, podendo receber uma matriz de tiles diferente
	# para a impressão.
	# Infelizmente esse procedimento também tem que fazer alguma suposição para usar menos registradores,
	# nesse caso ele supõe que todos os tiles de a0 serão impressos, ou seja, o numero de linhas e colunas
	# de tiles é o que está especificado no .data mesmo. 
	# 
	# Argumentos:
	# 	a0 = endereço base da matriz de tiles com os tiles a serem impressos
	# 	a1 = endereço base com as imagens dos tiles que a matriz em a0 faz referência
	#	a2 = endereço no frame 0 ou 1 de onde os tiles vão começar a ser impressos

	lw t0, 4(a0)	# t0 recebe a altura da matriz, ou seja, o numero de linhas de tiles a serem impressas
	lw t1, 0(a0)	# t1 recebe a largura da matriz, ou seja, o numero de colunas de tiles a serem impressas
			# a cada linha de t0
	
	addi a0, a0, 8				# pula para onde começa os pixels no .data
	addi a1, a1, 8				# pula para onde começa os pixels no .data
		
	PRINT_TILES_LINHAS:
		mv t2, t1		# copia de t1 para usar no loop de colunas
				
		PRINT_TILES_COLUNAS:
			lb t3, 0(a0)	# pega 1 elemento da matriz de tiles e coloca em t3
		
			li t4, 256	# t4 recebe 16 * 16 = 256, ou seja, a área de um tile							
			mul t3, t4, t3	# como dito na descrição do procedimento t3 (número do tile) * (16 * 16)
					# retorna quantos pixels esse tile está do começo da imagem
			
			add t3, t3, a1	# t3 recebe o endereço do tile a ser impresso
	
			# O loop abaixo emula um PRINT_IMG, a diferença é que como PRINT_IMG pode imprimir
			# imagens com uma tamanho arbitrário de colunas e linhas ele tem que utlizar instruções
			# load e store byte, mas como cada tile sempre tem 16 x 16 de tamanho é possível usar
			# load e store word para agilizar o processo
			
			li t4, 256	# numero de pixels de um tile (16 x 16)
			
			PRINT_TILE_COLUNAS:
			lw t5, 0(t3)		# pega 4 pixels do .data do tile (t3) e coloca em t5
			
			sw t5, 0(a2)		# pega os 4 pixels de t5 e coloca no bitmap
	
			addi t3, t3, 4		# vai para os próximos pixels da imagem
			addi a2, a2, 4		# vai para os próximos pixels do bitmap
			addi t4, t4, -4		# decrementa o numero de pixels restantes
			
			li t5, 16		# largura de um tile
			rem t5, t4, t5		# se o resto de t4 / 16 não for 0 então ainda restam pixels
						# da linha atual para serem impressos
			bne t5, zero, PRINT_TILE_COLUNAS	# reinicia o loop se t5 != 0
			
			addi a2, a2, -16	# volta o endeço do bitmap pelo numero de colunas impressas
			addi a2, a2, 320	# passa o endereço do bitmap para a proxima linha
			bne t4, zero, PRINT_TILE_COLUNAS	# reinicia o loop se t4 != 0
	
			addi a0, a0, 1		# vai para o próximo elemento da matriz de tiles
			
			li t3, 5120		# t3 recebe 16 (altura de um tile) * 320 
						# (tamanho de uma linha do frame)
			sub a2, a2, t3		# volta o endereço de a2 pelas linhas impressas			
			addi a2, a2, 16		# pula 16 colunas no bitmap já que o tile impresso tem
						# 16 colunas de tamanho 
			
			addi t2, t2, -1			# decrementando o numero de colunas de tiles restantes
			bne t2, zero, PRINT_TILES_COLUNAS	# reinicia o loop se t2 != 0
			
		li t2, 16		# t2 recebe a largura de um tile
		mul t2, t2, t1		# 16 * t1 retorna o numero de pixels em a2 foi incrementado no loop acima
		sub a2, a2, t2		# volta a2 pelo numero de colunas de tiles impressas

		li t2, 5120		# t2 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frame)
		add a2, a2, t2		# avança o endereço de a2 para a proxima linha de tiles		
			
		addi t0, t0, -1				# decrementando o numero de linhas restantes
		bne t0, zero, PRINT_TILES_LINHAS	# reinicia o loop se t0 != 0
				
	ret

		
# ====================================================================================================== #																																																									
																																																																																																																																																																									
CALCULAR_ENDERECO:
	# Procedimento que calcula um endereço no frame de escolha ou em uma imagem
	# Argumentos: 
	#	a1 = endereço do frame ou imagem
	# 	a2 = numero da coluna
	# 	a3 = numero da linha
	# a0 = retorno com o endereço
	
	li t0, 320			# t0 = 320
	
	mul t1, a3, t0			# linha x 320	
	add a0, a1, t1			# enderço base + (linha x 320)
	add a0, a0, a2			# a0 = enderço base + (linha x 320) + coluna
	
	ret 

# ====================================================================================================== #

CALCULAR_ENDERECO_DE_TILE:
	# Procedimento que recebe um endereço no frame 0 ou 1 e descobre qual é o endereço do tile 
	# correspondente na subsecção da matriz de tiles que está na tela (s2), retornando também o
	# endereço de inicio desse tile no frame e o endereço da imagem correspondente a esse tile
	#
	# Argumentos:
	#	a0 = um endereço no frame 0 ou 1
	#
	# Retorno:
	#	a0 = endereço do tile correspondente a partir de s2
	#	a1 = endereço de inicio do tile no frame
	# 	a2 = endereço da imagem correspondente a esse tile com base em s4
	
	# Primeiro descobre se o endereço de a0 está no frame 0 ou 1 para que o endereço de a1 já esteja
	# no frame certo
	
	li a1, 0xFF100000
	bge a0, a1, INICIO_CALCULAR_ENDERECO_DE_TILE
		li a1, 0xFF000000
	
	INICIO_CALCULAR_ENDERECO_DE_TILE:
	
	# Para encontrar o endereço do tile é necessário saber o número da coluna e linha desse tile na tela
	
	sub a0, a0, a1	# a0 - endereço base do frame decidido acima retorna a posição de a0 em relação ao 
			# inicio do frame
	
	li t0, 5120	# t0 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frame), ou seja,
			# o tamanho de uma linha de tiles no frame
			
	div t0, a0, t0	# a0 / 5120 retorna o número da linha de tiles onde a0 está 	
	
	li t1, 320	# t1 recebe o tamanho de uma linha do frame
	remu t1, a0, t1	# o resto de a0 / 320 retorna o numero da coluna de a0 no frame			
	li t2, 16 	# t2 recebe a largura de um tile	
	div t1, t1, t2	# o resto de t1 / 16 retorna o número da coluna de a0 na matriz de tiles 
					
	# Com o número da linha (t0) e coluna (t1) é fácil encontrar o tile correspondente na matriz
			
	mul t2, t0, s3	# t0 * s3 (tamanho de uma linha na matriz de tiles) retorna quantos elementos é necessário
			# pular em s2 para encontrar a linha certa do tile correspondente
	
	add a0, t2, t1		# s2 + t2 (número de elementos até a linha certa) + t1 (número de elementos até
	add a0, a0, s2		# a coluna correta) = endereço do tile correspondente na matriz a partir de a0
												
	# Agora e encessário encontrar o endereço de inicio do tile a0 no frame
	
	li t2, 5120	# t2 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frame), ou seja,
			# o tamanho de uma linha de tiles no frame
	
	mul t0, t0, t2	# multiplicando a linha do tile (t0) por t2 retorna a quantos pixels é necessário pular
			# para encontrar a linha do tile a0 no frame 
	
	li t2, 16	# t2 recebe a largura de um tile
	mul t1, t1, t2 	# multiplicando a coluna do tile (t1) por 16 retorna a quantos pixels é necessário pular
			# para encontrar a coluna do tile a0
	
	add a1, a1, t0	# movendo o endereço de a1 para o endereço da linha do tile			
	add a1, a1, t1	# movendo o endereço de a1 para o endereço da coluna do tile

	lb t0, 0(a0)	# armazena o valor do tile a0 em t0
		
	li t1, 256	# t1 recebe 16 * 16 = 256, ou seja, a área de um tile							
	mul t0, t0, t1	# t0 (número do tile) * (16 * 16) retorna quantos pixels esse tile está do começo 
			# da imagem dos tiles
	add a2, s4, t0	# a2 recebe o endereço de inicio da imagem correspondente ao tile a0		

	ret
	
# ====================================================================================================== #

PRINT_COR:
	# Procedimento que imprime uma área de a2 x a3 pixels com a cor a0 a partir de um endereço em algum frame
	# Esse procedimento geralamente é usado para "limpar" a tela em alguns momentos, como retirar certas
	# imagens de menus ou limpar caixas de diálogo, por exemplo.
	#
	# Argumentos: 
	# 	a0 = cor que será impressa 	
	# 	a1 = endereço de onde, no frame escolhido, a impressao deve começar
	# 	a2 = numero de colunas da área a ser impressa
	#	a3 = numero de linhas da área a ser impressa
	# Obs: por algum motivo esse procedimento não funciona no RARS exceto se o endereço de a1 estiver
	# especificamente no frame que está na tela

	PRINT_COR_LINHAS:
		mv t0, a2		# copia do numero de a2 para usar no loop de colunas
			
		PRINT_COR_COLUNAS:
			sb a0, 0(a1)			# pega a cor de a0 e coloca no bitmap
	
			addi a1, a1, 1			# vai para o próximo pixel do bitmap
			addi t0, t0, -1			# decrementa o numero de colunas restantes			
			bne t0, zero, PRINT_COR_COLUNAS	# reinicia o loop se t0 != 0
			
		addi a3, a3, -1			# decrementando o numero de linhas restantes
		
		sub a1, a1, a2			# volta o endeço do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endereço do bitmap para a proxima linha
		
		bne a3, zero, PRINT_COR_LINHAS	# reinicia o loop se a3 != 0		
	ret

# ====================================================================================================== #

REPLICAR_FRAME:
	# Procedimento que faz uma copia de uma área em um frame para outro frame
	# 
	# Argumentos: 
	# 	a0 = endereço no frame do inicio da area que será copiada
	#	a1 = endereço no frame que vai receber a copia
	#	a2 = numero de colunas que serão copiadas de a0 para a1
	#	a3 = numero de linhas que serão copiadas de a0 para a1	
	# 
	# OBS: se parte do pressuposto que a0 e a1 estão alinhados para usar lw e sw, e que a área a ser copiada
	# tem largura e altura (a2 e a3) multiplos de 4
	
	REPLICAR_FRAME_LINHAS:
		mv t0, a2	# copia do numero de colunas para o loop abaixo
			
		REPLICAR_FRAME_COLUNAS:
			lw t1, 0(a0)			# pega 4 pixels do frame em a0
			sw t1, 0(a1)			# armazena os 4 pixels no frame a1	
	
			addi a0, a0, 4			# vai para os próximos pixels do bitmap a0
			addi a1, a1, 4			# vai para os próximos pixels do bitmap a1
						
			addi t0, t0, -4			# decrementa o numero de colunas de pixels restantes			
			bne t0, zero, REPLICAR_FRAME_COLUNAS	# reinicia o loop se t0 != 0

		sub a0, a0, a2			# volta o endeço do bitmap pelo numero de colunas impressas
		addi a0, a0, 320		# passa o endereço do bitmap para a proxima linha
		
		sub a1, a1, a2			# volta o endeço do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endereço do bitmap para a proxima linha
														
		addi a3, a3, -1			# decrementando o numero de linhas restantes	
		bne a3, zero, REPLICAR_FRAME_LINHAS	# reinicia o loop se t0 != 0		
	ret

# ====================================================================================================== #

TROCAR_FRAME:
	# Procedimento que troca o frame que está sendo mostrado de 0 -> 1 e de 1 -> 0
	
	li t0, 0xFF200604		# t0 = endereço para escolher frames 
	lb t1, (t0)			# t1 = valor armazenado em t0
	xori t1, t1, 1			# inverte o valor de t1
	sb t1, (t0)			# armazena t1 no endereço de t0

	ret

# ====================================================================================================== #

VERIFICAR_TECLA:
	# Procedimento que verifica se alguma tecla foi apertada
	# Retorna a0 com o valor da tecla ou a0 = -1 caso nenhuma tecla tenha sido apertada		
	
	li a0, -1 		# a0 = -1
	 
	li t0, 0xFF200000	# carrega em t0 o endereço de controle do KDMMIO
 	lw t1, 0(t0)		# carrega em t1 o valor do endereço de t0
   	andi t1, t1, 0x0001	# t1 = 0 = não tem tecla, t1 = 1 = tem tecla. 
   				# realiza operação andi de forma a deixar em t0 somente o bit necessario para análise
   	
    	beq t1, zero, FIM_VERIFICAR_TECLA	# t1 = 0 = não tem tecla pressionada então vai para fim
   	lw a0, 4(t0)				# le o valor da tecla no endereço 0xFF200004
   		 	
	FIM_VERIFICAR_TECLA:					
		ret
		
# ====================================================================================================== #

SLEEP:	
	# Procedimento que fica em loop, parando a execução do programa, por alguns milissegundos
	# Argumentos:
	# 	a0 = durancao em ms do sleep
	
	csrr t0, time	# le o tempo atual do sistema
	add t0, t0, a0	# adiciona a t0 a durancao do sleep
	
	LOOP_SLEEP:
		csrr t1, time			# le o tempo do sistema
		sltu t1, t1, t0			# t1 recebe 1 se (t1 < t0) e 0 caso contrário
		bne t1, zero, LOOP_SLEEP 	# se o tempo de t1 != 0 reinicia o loop
		
	ret
				
# ====================================================================================================== #

ENCONTRAR_NUMERO_RANDOMICO:	
	# Procedimento que encontra um numero "randomico" entre 0 e a0 (nao inclusivo)
	# Argumentos:
	# 	a0 = limite superior para o numero randomico (nao inclusivo)
	# Retorno:
	# 	a0 = número "rândomico" entre 0 e a0 - 1
 		
	csrr t0, time		# le o tempo atual do sistema
	
	remu a0, t0, a0		# encontra o resto da divisão do tempo do sistema por a0 de modo que a0 
				# tem um numero entre 0 e a0 - 1 
			
	ret
	
# ====================================================================================================== #
			
PRINT_DIALOGOS:
	# Procedimento que imprime uma quantidade variavel de caixas de dialogo em ambos os frames
	# Os dialogos são sempre renderizados em uma área fixa da tela
	# O número de dialogos é determinado pelo argumento a5.
	# Caso seja mais de 1 dialogo, para o procedimento funcionar corretamente é necessário que 
	# as imagens estejam em um mesmo arquivo (ver intro_dialogos.bmp para um exemplo)
	
	# Argumentos: 
	# 	a5 = endereço da imagem dos dialogos		
	# 	a6 = número de caixas de dialógos a serem renderizadas		

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
				
	# Calcula o endereço de onde o dialogo vai ser renderizado no frame 0		
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 6 			# coluna = 6
		li a3, 172			# linha = 172
		call CALCULAR_ENDERECO
	
	mv t4, a0	# salva o endereço retornado em t4

	# Calcula o endereço de onde o dialogo vai ser renderizado no frame 1		
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		# os valores de a2 (coluna) e a3 (linha) continuam os mesmos 
		call CALCULAR_ENDERECO
		
	mv t5, a0	# salva o endereço retornado em t5
		
	# O loop abaixo é responsável por renderizar uma caixa de diálogo em ambos os frames.
	# Essas caixas são sempre mostradas em uma área fixa.  
	# Esse loop tem como base o arquivo intro_dialogos.data, verificando o .bmp correspondente 
	# é possível perceber que as imagens foram colocadas de maneira sequencial, nesse sentido, 
	# fica convencionado que o registrador a5 = endereço base da imagem de forma que quando um diálogo 
	# termina de ser renderizado a6 já vai apontar automaticamente para o endereço da próxima caixa 
	# de diálogo.
	 						
	LOOP_PROXIMO_DIALOGO:
	li a2, 308	# numero de colunas de uma caixa de dialogo
	li a3, 64	# numero de linhas de uma caixa de dialogo
		
		mv a0, a5		# move para a0 o endereço da imagem
		mv a1, t4		# move para a1 o endereço de onde o dialogo será renderizado (frame 0)
		call PRINT_IMG
	
		mv a0, a5		# move para a0 o endereço da imagem
		mv a1, t5		# move para a1 o endereço de onde o dialogo será renderizado (frame 1)
		call PRINT_IMG
	
		mv a5, a0		# atualiza o endereço da imagem para o próximo dialogo
	
		call PRINT_SETA_DIALOGO
	
		LOOP_FRAMES_DIALOGO:
		# Troca constantemente de frame até o usuário apertar ENTER para carregar o proximo dialogo
		
			# Espera alguns milisegundos	
				li a7, 32			# selecionando syscall sleep
				li a0, 450			# sleep por 450 ms
				ecall
		
			call TROCAR_FRAME
		
			call VERIFICAR_TECLA			# verifica se alguma tecla foi apertada	
			li t0, 10				# t0 = valor da tecla enter
			bne a0, t0, LOOP_FRAMES_DIALOGO		# se a0 = t0 -> tecla Enter foi apertada
	
		addi a6, a6, -1					# decrementa o numero de loops
		
		bne a6, zero, LOOP_PROXIMO_DIALOGO		# se a6 != 0 reinicia o loop


	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
			
# ====================================================================================================== #

PRINT_SETA_DIALOGO:
	# Procedimento auxiliar a PRINT_DIALOGOS_INTRO
	# Imprime setas nas caixas de dialogos em ambos os frames, sendo que no frame 1 a
	# seta está levemente para cima	
	# As setas sempre estão em posições fixas na tela

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Calcula o endereço de onde a seta vai ser renderizada no frame 0		
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 280 			# coluna = 284
		li a3, 216			# linha = 216
		call CALCULAR_ENDERECO
	
	mv t6, a0			# salva o retorno do procedimento chamado acima em t4
	
	# Calcula o endereço de onde a seta vai ser renderizada no frame 1		
		li t0, 0x00100000	# soma a0 com t0 de forma que o endereço de a0 passa para o 
		add a1, a0, t0		# endereço correspondente no frame 1
		addi a1, a1, -640	# sobe o endereço de a1 em duas linhas
	
	# Imprime a seta no frame 1
		#la a0, seta_dialogo	# carrega a imagem
		# a1 tem o endereço onde a seta será renderizada
		lw a2, 0(a0)		# a1 = numero de colunas da imagem
		lw a3, 4(a0)		# a2 = numero de linhas da imagem
		addi a0, a0, 8		# pula para onde começa os pixels no .data
		call PRINT_IMG

	# Imprime a seta no frame 0
		#la a0, seta_dialogo	# carrega a imagem
		mv a1, t6		# a1 tem o endereço onde a seta será renderizada
		# os valores de a2 (coluna) e a3 (linha) continuam os mesmos 
		addi a0, a0, 8		# pula para onde começa os pixels no .data
		call PRINT_IMG

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
	
# ====================================================================================================== #	

PRINT_TEXTO:
	# Procedimento similar a PRINT_DIALOGOS que usa uma matriz de tiles para imprimir 1 linha
	# de texto em algum frame.
	# A diferença entre um e outro é que PRINT_TEXTO só imprime uma linha e em um endereço arbitrário
	# na tela
	# Cada texto de um dialogo é codificado em uma matriz de tiles, a diferença é que enquanto 
	# normalmente os tiles do jogo tem 16 x 16, os tiles dos textos tem 8 x 15.
	# Todos os textos são construidos com os tiles em "../Imagens/historia/dialogos/tiles_alfabeto".
	# Para renderizar o dialogo é necessário fornecer uma matriz de tiles, onde cada tile
	# é uma letra desse alfebeto.
	# Esse procedimento só imprime 2 linhas da matriz de tiles do dialogo.
	# 
	# Argumentos:
	# 	a1 = endereço onde começar a imprimir o texto
	#	a4 = matriz de tiles condificando o texto do dialogo de acordo com tiles_alfabeto

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, 0(sp)		# empilha ra

	la t3, tiles_alfabeto	# carrega a imagem com os tiles do alfabeto
	addi t3, t3, 8		# pula para onde começa os pixels no .data

	lw t4, 0(a4)		# t4 recebe o numero de elementos que serão impresso
	addi a4, a4, 8		# pula para onde começa os tiles no .data
				
	PRINT_TEXTO_COLUNAS:
		lb t0, 0(a4)	# pega 1 elemento da matriz de tiles e coloca em t0
		
		# um tile com valor -1 significa um fim de linha, eles são usados porque cada
		# dialogo precisa ter linhas de mesmo tamanho, então tiles com valor -1 completam
		# as linhas para que esse criterio seja cumprido, porém eles não são renderizados
		li t1, -1
		beq t0, t1, PROXIMO_TILE_TEXTO
		
		li t1, 120	# t1 recebe 8 * 15 = 120, ou seja, a área de um tile do alfabeto							
		mul t0, t0, t1	# t0 (número do tile) * (8 * 15) etorna quantos pixels esse tile
				# está do começo da imagem dos tiles do alfabeto
			
		add a0, t0, t3	# a0 recebe o endereço da imagem do tile a ser impresso
		# a1 tem o endereço de onde imprimir a letra			
		li a2, 8		# numero de colunas de um tile do alfabeto
		li a3, 15		# numero de linhas de um tile do alfabeto
		call PRINT_IMG	
			
		li t0, 4800		# t1 recebe 15 (altura de um tile do alfabeto) * 320 
					# (tamanho de uma linha do frame)
		sub a1, a1, t0		# volta o endereço de a1 pelas linhas impressas			
		addi a1, a1, 8		# pula 8 colunas no bitmap já que o tile impresso tem
					# 8 colunas de tamanho 
			
		# Na verdade os tiles do alfabeto não estão ordenados em ordem alfabética, mas sim
		# em determinados grupos.
		# Nem todas as letras tem exatamente 8 x 15 pixels, na verdade esse tamanho é apenas
		# um limite definido pelo tamanho do maior simbolo nesse alfabeto. 
		# Por isso certos tiles acabam ficando com um excesso de colunas em branco, então
		# as letras estão arranjadas em grupos que indicam quantos pixels é necessário voltar
		# antes de imprimir o proximo tile para que cada letra fique mais ou menos uma do lado
		# da outra.
			
		lb t0, 0(a4)	# pega o elemento da matriz de tiles que foi impresso
			
		li t1, 1		# se o numero do tile for menor do que 65	
		li t2, 65		# então é necessário voltar 1 pixel
		blt t0, t2, PROXIMO_TILE_TEXTO
		li t1, 2		# se o numero do tile for maior ou igual a 65 e menor do que 75
		li t2, 75		# então é necessário voltar 2 pixels
		blt t0, t2, PROXIMO_TILE_TEXTO
		li t1, 4		# se o numero do tile for maior que 75 e menor que 77 volta 
		li t2, 77		# 4 pixels
		ble t0, t2, PROXIMO_TILE_TEXTO			
		li t2, 5		# caso contrário volta 5 pixels
									
		PROXIMO_TILE_TEXTO:
			
		sub a1, a1, t1	# atualiza o endereço onde o proximo tile será impresso de acordo com
				# o valor de t1 decidido acima		
						
		addi a4, a4, 1		# vai para o próximo elemento da matriz de tiles
									
		addi t4, t4, -1			# decrementando o numero de colunas de tiles restantes
		bne t4, zero, PRINT_TEXTO_COLUNAS	# reinicia o loop se t4 != 0
					
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
																											
