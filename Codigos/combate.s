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
	
	# Primeiro sorteia qual é o pokemon inimigo, atualiza os primeiros bits de s11 com o codigo correto e
	# t5 recebe o endereço da matriz de texto com o nome do pokemon
	
	li a0, 5				# encontra um numero randomico entre 0 e 4
	call ENCONTRAR_NUMERO_RANDOMICO		

	# se a0 == 0 então é pokemon inimigo será o BULBASAUR 
	li s11, 1089 				# codigo do BULBASAUR
	la t5, matriz_texto_bulbasaur 		# carrega a matriz com o nome do pokemon	
	beq a0, zero, PRINT_TEXTO_POKEMON_INIMIGO
			
	# se a0 == 1 então é pokemon inimigo será o CHARMANDER 
	li t0, 1	
	li s11, 138 				# codigo do CHARMANDER
	la t5, matriz_texto_charmander 		# carrega a matriz com o nome do pokemon		
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
			
	# se a0 == 2 então é pokemon inimigo será o SQUIRTLE 
	li t0, 2	
	li s11, 531 				# codigo do SQUIRTLE
	la t5, matriz_texto_squirtle 		# carrega a matriz com o nome do pokemon		
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
										
	# se a0 == 3 então é pokemon inimigo será o CATERPIE 
	li t0, 3	
	li s11, 100 				# codigo do CATERPIE
	la t5, matriz_texto_caterpie 		# carrega a matriz com o nome do pokemon		
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
	
	# se a0 == 4 então é pokemon inimigo será o DIGLETT 
	li t0, 4	
	li s11, 541 				# codigo do DIGLETT
	la t5, matriz_texto_diglett 		# carrega a matriz com o nome do pokemon	

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
		mv a4, t5		# a4 recebe a matriz de texto do pokemon decidido acima
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
								
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
		
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #

.data
	.include "../Imagens/combate/matriz_tiles_tela_combate.data"
	.include "../Imagens/combate/tiles_tela_combate.data"				
