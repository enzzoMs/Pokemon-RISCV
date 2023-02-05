.data

# Matrizes de texto
# Uma matriz de texto é uma matriz em que cada elemento representa um tile de tiles_alfabeto.data, sendo usados
# para imprimir um nome geralmente curto na tela. Os labels estão no formato matriz_texto_Y, onde Y é o texto
# que a matriz se refere

matriz_texto_atacar: .word 6, 1 
		     .byte 39,60,39,36,39,35
			
matriz_texto_defesa: .word 6, 1 
		       .byte 34,22,62,22,30,39

matriz_texto_item: .word 4, 1 
		     .byte 57,60,22,27
		     
matriz_texto_fugir: .word 5, 1 
		     .byte 62,40,61,57,35

matriz_texto_um: .word 3, 1 
		 .byte 40,69,77			# inclui espaço no final
		     
matriz_texto_selvagem: .word 9, 1 
		     .byte 77,71,4,76,11,0,5,4,69	# inclui espaço no começo     	
		     
matriz_texto_apareceu: .word 9, 1 
		     .byte 0,9,0,70,4,2,4,73,74		# inclui exclamação no final 
		     		     
.text
		     			 			 
# ====================================================================================================== # 
# 						 COMBATE				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Código com os procedimentos necessários para renderizar e executar a logica das cenas de batalha	 # 
# do jogo.												 #
#												 	 # 
# ====================================================================================================== #

VERIFICAR_COMBATE:
	# Procedimento principal de combate.s, ele é chamado depois de cada procedimento de movimentação 
	# e verifica se: 1) o RED está em um tile de grama e 2} de acordo com uma certa chance, verificar se 
	# esse tile vai iniciar um combate com um pokemon selvagem. Caso inicie o combate ele vai chamar
	# os outros procedimentos necessários

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
		
	lb t0, 0(s6)			# checa a posição do RED na matriz de movimentação (s6)
	li t1, 7			# 7 é codigo de um tile de grama
	bne t0, t1, FIM_VERIFICAR_COMBATE
	
	li a0, 5				# encontra um numero randomico entre 0 e 4
	call ENCONTRAR_NUMERO_RANDOMICO		
	bne a0, zero, FIM_VERIFICAR_COMBATE	# se o numero encontrado for 0 então esse tile vai iniciar o
						# combate com um pokemon, desse modo o combate tem em teoria 
						# 1/5 chance de acontecer cada vez que o RED passa pela grama
		call EXECUTAR_COMBATE
	
	FIM_VERIFICAR_COMBATE:
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #

EXECUTAR_COMBATE:
	# Procedimento que vai coordenar o combate do jogo, chamado todos os outros procedimentos necessários
	
	call INICIAR_TELA_DE_COMBATE		# inicia a tela de combate

	call INICIAR_POKEMON_INIMIGO	# imprime os sprites e outros elementos relacionados ao pokemon inimigo

	a: j a
	
# ====================================================================================================== #

INICIAR_TELA_DE_COMBATE:
	# Procedimento que vai imprimir um balão de exclamação sobre o RED indicando que um combate vai acontecer,
	# e imprimir a tela de combate com todos os textos iniciais do menu de opções

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	

	# Imprimindo o balão de exclamação sobre a cabeça do RED no frame 0
	# O balão funciona que nem um tile normal, a diferença é que tem fundo transparente
	
	mv a0, s0			# calcula o endereço de inicio do tile onde a cabeça do RED está (s0)
	call CALCULAR_ENDERECO_DE_TILE	# no frame 0
	
	# Imprimindo o balão de exclamação no frame 0			
		la a0, balao_exclamacao		# carrega a imagem
		addi a0, a0, 8			# pula para onde começa os pixels no .data
		# do retorno do procedimento CALCULAR_ENDERECO_DE_TILE a1 já tem o endereço de inicio 
		# do tile onde a cabeça do RED está 
		li a2, 16			# a2 = numero de colunas de um tile
		li a3, 16			# a3 = numero de linhas de um tile
		call PRINT_IMG

	# Espera alguns milisegundos	
		li a0, 1200			# sleep 1.2 s
		call SLEEP			# chama o procedimento SLEEP	
	
	li t6, 0x00000000		# t6 vai ser usado no loop abaixo para imprimir as mesmas coisas
					# nos dois frames
					
	LOOP_IMPRIMIR_TELA_DE_COMBATE_FRAMES:
	
	# Agora imprime a tela de combate no frame 0 e 1 com os textos necessários
		# Imprimindo a tela no frame 1
		la a0, matriz_tiles_tela_combate	# carrega a matriz de tiles
		la a1, tiles_tela_combate		# carrega a imagem com os tiles
		li a2, 0xFF000000			# os tile serão impressos no frame indicado por t6
		add a2, a2, t6
		call PRINT_TILES

		# Imprimindo os textos do menu de combate no frame 1
			# Calculando o endereço de onde imprimir o primeiro texto (ATACAR) no frame 1
			li a1, 0xFF000000	# seleciona o frame indicado por t6
			add a1, a1, t6
			li a2, 195		# numero da coluna 
			li a3, 185		# numero da linha
			call CALCULAR_ENDERECO	
			
			mv a1, a0		# move o retorno para a1
			
			# Imprime o texto com o ATACAR
			# a1 já tem o endereço de onde imprimir o texto
			la a4, matriz_texto_atacar 	
			call PRINT_TEXTO
			
			# Imprime o texto com o FUGIR
			addi a1, a1, 18		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde
						# imprimiu o tile, de modo que está a 18 colunas do proximo texto
			la a4, matriz_texto_fugir 	
			call PRINT_TEXTO
			
			# Imprime o texto com o DEFESA
			addi a1, a1, -95	# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde
			li t0, 5440		# imprimiu o tile, de modo que está a -95 colunas e +17 linhas
			add a1, a1, t0		# do proximo texto (5440 = 17 * 320)
			la a4, matriz_texto_defesa 	
			call PRINT_TEXTO
			
			# Imprime o texto com o ITEM
			addi a1, a1, 18		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde
						# imprimiu o tile, de modo que está a 18 colunas do proximo texto
			la a4, matriz_texto_item 	
			call PRINT_TEXTO
												
		call TROCAR_FRAME		# inverte o frame sendo mostrado

		li t0, 0x00100000	# fazendo essa operação xor se t6 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# trocar entre esses valores
		bne t6, zero, LOOP_IMPRIMIR_TELA_DE_COMBATE_FRAMES

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #																																			

INICIAR_POKEMON_INIMIGO:
	# Procedimento que atualiza o valor de s11 com o pokemon inimigo e imprime todos os sprites,
	# animações e textos relacionados a esse pokemon aparecendo na tela

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Primeiro sorteia qual é o pokemon inimigo, atualiza os primeiros bits de s11 com o codigo correto,
	# t5 recebe o endereço da matriz de texto com o nome do pokemon e t6 recebe o endereço da imagem do 
	# pokemon
	
	li a0, 5				# encontra um numero randomico entre 0 e 4
	call ENCONTRAR_NUMERO_RANDOMICO		

	# se a0 == 0 então é pokemon inimigo será o BULBASAUR 
	li s11, BULBASAUR 			# codigo do BULBASAUR
	la t6, matriz_texto_bulbasaur 		# carrega a matriz com o nome do pokemon
	la t5, pokemons			# t6 tem o inicio da imagem do BULBASAUR
	addi t5, t5, 8			# pula para onde começa os pixels no .data
	beq a0, zero, PRINT_TEXTO_POKEMON_INIMIGO
			
	# se a0 == 1 então é pokemon inimigo será o CHARMANDER 
	li t0, 1	
	li s11, CHARMANDER 			# codigo do CHARMANDER
	la t6, matriz_texto_charmander 		# carrega a matriz com o nome do pokemon
	addi t5, t5, 1482			# 1482 = 38 * 39 = tamanho de uma imagem de um pokemon, ou seja,
						# passa o endereço de t6 para a imagem do CHARMANDER	
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
			
	# se a0 == 2 então é pokemon inimigo será o SQUIRTLE 
	li t0, 2	
	li s11, SQUIRTLE 			# codigo do SQUIRTLE
	la t6, matriz_texto_squirtle 		# carrega a matriz com o nome do pokemon
	addi t5, t5, 1482			# 1482 = 38 * 39 = tamanho de uma imagem de um pokemon, ou seja,
						# passa o endereço de t6 para a imagem do SQUIRTLE			
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
										
	# se a0 == 3 então é pokemon inimigo será o CATERPIE 
	li t0, 3	
	li s11, CATERPIE 			# codigo do CATERPIE
	la t6, matriz_texto_caterpie 		# carrega a matriz com o nome do pokemon	
	addi t5, t5, 1482			# 1482 = 38 * 39 = tamanho de uma imagem de um pokemon, ou seja,
						# passa o endereço de t6 para a imagem do CATERPIE			
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
	
	# se a0 == 4 então é pokemon inimigo será o DIGLETT 
	li t0, 4	
	li s11, DIGLETT 			# codigo do DIGLETT
	la t6, matriz_texto_diglett 		# carrega a matriz com o nome do pokemon	
	addi t5, t5, 1482			# 1482 = 38 * 39 = tamanho de uma imagem de um pokemon, ou seja,
						# passa o endereço de t6 para a imagem do DIGLETT	
	
	PRINT_TEXTO_POKEMON_INIMIGO:
	# Agora imprime o texto "Um YYY selvagem apareceu!", onde YYY é o nome do pokemon
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
	
		# Calculando o endereço de onde imprimir o primeiro texto (Um) no frame 0
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 28		# numero da coluna 
			li a3, 185		# numero da linha
			call CALCULAR_ENDERECO	
			
			mv a1, a0		# move o retorno para a1

		# Imprime o texto com o 'Um '
		# a1 já tem o endereço de onde imprimir o texto
		la a4, matriz_texto_um 	
		call PRINT_TEXTO
		
		# Imprime o texto com o nome do Pokemon
		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o tile,
		# de modo que está na posição exata do proximo texto
		mv a4, t6		# a4 recebe a matriz de texto do pokemon decidido acima
		call PRINT_TEXTO

		# Imprime o texto com o ' selvagem'
		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o tile,
		# de modo que está na posição exata do proximo texto
		la a4, matriz_texto_selvagem 	
		call PRINT_TEXTO
		
		# Calculando o endereço de onde imprimir o ultimo texto ('apareceu!') no frame 0
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 28		# numero da coluna 
			li a3, 201		# numero da linha
			call CALCULAR_ENDERECO	
			
			mv a1, a0		# move o retorno para a1		
					
		# Imprime o texto com o 'apareceu!'
		# a1 já tem o endereço de onde imprimir o texto					
		la a4, matriz_texto_apareceu 	
		call PRINT_TEXTO
			
		# Por fim, imprime uma pequena seta indicando que o jogador pode apertar ENTER para avançar
		# o dialogo						
			# Calculando o endereço de onde imprimir a seta no frame 0
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 159		# numero da coluna 
			li a3, 207		# numero da linha
			call CALCULAR_ENDERECO											
			
			mv t3, a0		# move o retorno para t3		
						
			# Imprimindo a imagem da seta no frame 0
			la a0, seta_proximo_dialogo_combate		# carrega a imagem				
			mv a1, t3		# t3 tem o endereço de onde imprimir a imagem
			lw a2, 0(a0)		# numero de colunas da imagem
			lw a3, 4(a0)		# numero de linhas da imagem
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG																							
																																																											
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
	
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_POKEMON_INIMIGO:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 é o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_POKEMON_INIMIGO
	
	# Limpa a caixa de dialogo no frame 0 somente para indicar que o não mais necessário apertar ENTER					
		# Para retirar a imagem da seta basta imprimir uma área de mesmo tamanho com a cor
		# de fundo do inventario
		li a0, 0xFF		# a0 tem o valor do fundo do menu da caixa de dialogo (branco)
		mv a1, t3		# t3 ainda tem o endereço de onde a seta está		
		li a2, 10		# numero de colunas da imagem da seta
		li a3, 6		# numero de linhas da imagem da seta	
		call PRINT_COR						
							
	# Imprime a imagem do pokemon inimigo aparecendo na tela no frame 0	
		# Calculando o endereço de onde imprimir o pokemon inimigo
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 204		# numero da coluna 
		li a3, 43		# numero da linha
		call CALCULAR_ENDERECO	
		
		mv t3, a0		# move o retorno para t3
		
		# Imprime a silhueta do pokemon inimigo		
		mv a0, t5	# t5 ainda tem a imagem do pokemon inimigo que foi decidido no inicio procedimento				
		mv a1, t3	# t3 tem o endereço de onde imprimir a imagem
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		call PRINT_POKEMON_SILHUETA
	
		# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		# Imprime a imagem completa do pokemon inimigo		
		mv a0, t5	# t5 ainda tem a imagem do pokemon inimigo que foi decidido no inicio procedimento				
		mv a1, t3	# t3 tem o endereço de onde imprimir a imagem
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		call PRINT_IMG
			
					
	# Imprime a imagem da caixa com as informações do pokemon inimigo (nome, vida, etc) no frame 0
		# Calculando o endereço de onde imprimir a caixa
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 32		# numero da coluna 
		li a3, 32		# numero da linha
		call CALCULAR_ENDERECO	
		
		mv a2, a0		# move o retorno para a2
		
		# Imprime a caixa do pokemon inimigo
		la a0, matriz_tiles_caixa_pokemon_combate	# carrega a matriz de tiles
		la a1, tiles_caixa_pokemon_combate		# carrega a imagem com os tiles
		# a2 já tem o endereço de onde imprimir os tiles
		call PRINT_TILES
	
		# Imprime uma pequena seta indicando a orientação dessa caixa 
		# Calculando o endereço de onde imprimir a seta
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 154		# numero da coluna 
		li a3, 55		# numero da linha
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o retorno para a1
		
		# Imprime a seta 
		la a0, seta_direcao_caixa_pokemon_combate	# carrega a imagem
		addi a0, a0, 8					# pula para onde começa os pixels no .data		
		# a1 já tem o endereço de onde imprimir a imagem
		li a2, 15	# numero de colunas da imagem
		li a3, 9	# numero de linhas da imagem
		call PRINT_IMG
		
		# Imprime o nome do pokemon inimigo na caixa
		# Calculando o endereço de onde imprimir o nome na caixa
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 37		# numero da coluna 
		li a3, 35		# numero da linha
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o retorno para a1
		
		# Imprime o texto com o nome do Pokemon
		# a1 tem o endereço de onde imprimir o nome
		mv a4, t6	# a4 recebe a matriz de texto do pokemon decidido anteriormente no procedimento	
		call PRINT_TEXTO							
			
		# Imprime a barra de vida
		# Calculando o endereço de onde imprimir a barra
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 48		# numero da coluna 
		li a3, 50		# numero da linha
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o retorno para a1
		
		# Imprime a imagem da barra de vida
		la a0, combate_barra_de_vida	# carrega a imagem
		# a1 já tem o endereço de onde imprimir a imagem
		lw a2, 0(a0)	# numero de colunas da imagem
		lw a3, 4(a0)	# numero de linhas da imagem
		addi a0, a0, 8			# pula para onde começa os pixels no .data				
		call PRINT_IMG		
		
		# Imprime a vida do pokemon inimigo
		# Todos os pokemons tem uma vida de 45 pontos
		
		# Calculando o endereço de onde imprimir o primeiro numero (4)
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 122		# numero da coluna 
		li a3, 37		# numero da linha
		call CALCULAR_ENDERECO			
		
		mv a1, a0		# move o retorno para a1
		
		# O loop começa imprimindo o numero 4
		la a0, tiles_numeros	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		addi a0, a0, 240 	# 240 = 60 (area de uma imagem de um numero) * 4, ou seja,
					# a0 passa para o inico do tile com o numero 4
					
		li t3, 5		# numero de simbolos a serem impressos 	
				
		LOOP_POKEMON_INIMIGO_PRINT_VIDA:
		# Imprimindo o numero 
		# a0 já tem o endereço da imagem do numero (ou /)			
		# a1 já tem o endereço de onde imprimir o numero
		li a2, 6		# numero de colunas dos tiles a serem impressos
		li a3, 10		# numero de linhas dos tiles a serem impressos	
		call PRINT_IMG										

		addi t3, t3, -1		# decrementa o numero de simbolos restantes

		# Pelo PRINT_IMG o endereço de a0 já está no inicio da imagem do 5
		# pelo PRINT_IMG acima a1 está naturalmente a -10 linhas +7 colunas de onde imprimir o proximo
		# numero
		li t0, -3193		# -3193 = -10 * 320 + 7
		add a1, a1, t0	
		
		# Pelo PRINT_IMG o endereço de a0 já está no inicio da imagem do 5				
		li t0, 4
		beq t3, t0, LOOP_POKEMON_INIMIGO_PRINT_VIDA	# se t3 == 4 imprime o 5
		
		la a0, caractere_barra	
		addi a0, a0, 8		# pula para onde começa os pixels no .data							
		li t0, 3		
		beq t3, t0, LOOP_POKEMON_INIMIGO_PRINT_VIDA	# se t3 == 3 imprime uma imagem de uma barra (/)
			
		la a0, tiles_numeros	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		addi a0, a0, 240 	# 240 = 60 (area de uma imagem de um numero) * 4, ou seja,
					# a0 passa para o inico do tile com o numero 4
		li t0, 2
		beq t3, t0, LOOP_POKEMON_INIMIGO_PRINT_VIDA	# se t3 == 2 imprime o 4	
				
		addi a0, a0, 60 	# Pelos calculos acima o endereço de a0 está a 60 pixels do inicio 
					# da imagem do 5
		bne t3, zero, LOOP_POKEMON_INIMIGO_PRINT_VIDA	# se t3 == 1 imprime o 5
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #

PRINT_POKEMON_SILHUETA:
	# Procedimento que imprime a silhueta de um pokemon na tela. Por silhueta entende-se uma imagem	
	# de um pokemon em pokemons.bmp, só que ao inves de imprimir a imagem normalmente o pokemon será
	# impresso apenas com pixels rosa, imprimindo só o "formato" do pokemon
	#
	# Argumentos: 
	# 	a0 = endereço da imagem	do pokemon	
	# 	a1 = endereço de onde, no frame escolhido, a imagem deve ser renderizada
	# 	a2 = numero de colunas da imagem
	#	a3 = numero de linhas da imagem
	
	PRINT_POKEMON_SILHUETA_LINHAS:
		mv t1, a2		# copia do numero de a2 para usar no loop de colunas
			
		PRINT_POKEMON_SILHUETA_COLUNAS:
			lbu t2, 0(a0)			# pega 1 pixel do .data e coloca em t2
			
			# Se o valor do pixel do .data (t2) for 0xC7 (pixel transparente), 
			# o novo pixel não é armazenado no bitmap, de modo que somente serão impressos os pixels
			# de cor t0 no lugar dos pixels que fazem parte da imagem do pokemon em si
			li t0, 0xC7		# cor do pixel transparente
			beq t2, t0, NAO_IMPRIMIR_PIXEL_DO_POKEMON
				li t0, 231		# t0 tem o valor da cor (rosa) que será usada para fazer a
							# impressão do pokemon
				sb t0, 0(a1)		# pega o pixel de t0 (cor rosa) e coloca no bitmap
	
			NAO_IMPRIMIR_PIXEL_DO_POKEMON:
			addi t1, t1, -1			# decrementa o numero de colunas restantes
			addi a0, a0, 1			# vai para o próximo pixel da imagem
			addi a1, a1, 1			# vai para o próximo pixel do bitmap
			bne t1, zero, PRINT_POKEMON_SILHUETA_COLUNAS	# reinicia o loop se t1 != 0
			
		addi a3, a3, -1			# decrementando o numero de linhas restantes
		
		sub a1, a1, a2			# volta o endeço do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endereço do bitmap para a proxima linha
		
		bne a3, zero, PRINT_POKEMON_SILHUETA_LINHAS	# reinicia o loop se a3 != 0
			
	ret
	
# ====================================================================================================== #

.data
	.include "../Imagens/combate/matriz_tiles_tela_combate.data"
	.include "../Imagens/combate/tiles_tela_combate.data"				
	.include "../Imagens/combate/seta_proximo_dialogo_combate.data"				
	.include "../Imagens/combate/tiles_caixa_pokemon_combate.data"	
	.include "../Imagens/combate/matriz_tiles_caixa_pokemon_combate.data"					
	.include "../Imagens/combate/seta_direcao_caixa_pokemon_combate.data"									
	.include "../Imagens/combate/combate_barra_de_vida.data"																		
	.include "../Imagens/outros/caractere_barra.data"																		