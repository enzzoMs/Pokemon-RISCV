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
		call INICIAR_COMBATE
	
	FIM_VERIFICAR_COMBATE:
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #

INICIAR_COMBATE:
	# Procedimento que vai imprimir um balão de exclamação sobre o RED indicando que um combate vai acontecer,
	# imprimir a tela de combate ...

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
	
	# Agora imprime a tela de combate no frame 0 e 1
		# Imprimindo a tela no frame 1
		la a0, matriz_tiles_tela_combate	# carrega a matriz de tiles
		la a1, tiles_tela_combate		# carrega a imagem com os tiles
		li a2, 0xFF100000			# os tile serão impressos no frame 1
		call PRINT_TILES

		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 1

		# Imprimindo a tela no frame 0
		la a0, matriz_tiles_tela_combate	# carrega a matriz de tiles
		la a1, tiles_tela_combate		# carrega a imagem com os tiles
		li a2, 0xFF000000			# os tile serão impressos no frame 0
		call PRINT_TILES

		call TROCAR_FRAME		# inverte o frame sendo mostrado, ou seja, mostra o frame 0
		
	a: j a

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #																																			
.data
	.include "../Imagens/combate/matriz_tiles_tela_combate.data"
	.include "../Imagens/combate/tiles_tela_combate.data"				
