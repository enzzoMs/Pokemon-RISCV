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

matriz_texto_escolha_o_seu_pokemon: .word 22, 1 		# inclui exclamação no final 
		     .byte 22,71,2,8,76,6,0,77,8,77,71,4,73,77,24,25,26,29,27,25,28,74	
			
matriz_texto_escolhido: .word 11, 1 		# inclui espaço no começo e ponto no final
		.byte 77,4,71,2,8,76,6,78,3,8,54
		
matriz_texto_o_que_o: .word 8, 1 		# inclui espaço no final
		.byte 25,77,10,73,4,77,8,77		

matriz_texto_vai: .word 4, 1 		# inclui espaço no começo
		.byte 77,11,0,78
		
matriz_texto_fazer: .word 6, 1 		# inclui interrogação no final
		.byte 66,0,15,4,70,55

matriz_texto_tenta_fugir: .word 13, 1 		# inclui espaço no começo e exclamação no final
		.byte 77,72,4,7,72,0,77,66,73,5,78,70,74
		
matriz_texto_tres_pontos: .word 2, 1 		# inclui espaço no final
		.byte 65,77
		
matriz_texto_a_fuga_falhou: .word 14, 1 		# inclui ponto no final
		.byte 39,77,66,73,5,0,77,66,0,76,6,8,73,54
		
matriz_texto_a_fuga_funcionou: .word 17, 1 		# inclui exclamação no final
		.byte 39,77,66,73,5,0,77,66,73,7,2,78,8,7,8,73,74
		
matriz_texto_ataca: .word 7, 1 		# inclui espaço no começo e exclamação no final
		.byte 77,0,72,0,2,0,74	
		
matriz_texto_muito_efetivo: .word 15, 1 		# inclui exclamação e espaço no final
		.byte 27,73,78,72,8,77,4,66,4,72,78,11,8,74,77
		
matriz_texto_pouco_efetivo: .word 15, 1 		# inclui ponto e espaço no final
		.byte 24,8,73,2,8,77,4,66,4,72,78,11,8,54,77											

matriz_texto_o_ataque: .word 8, 1 		
		.byte 25,77,0,72,0,10,73,4

matriz_texto_deu: .word 4, 1 		# inclui espaço no final
		.byte 3,4,73,77
				
matriz_texto_de_dano: .word 8, 1 		# inclui ponto no final
		.byte 3,4,77,3,0,7,8,54
		
matriz_texto_vitoria: .word 7, 1 		
		.byte 31,57,60,25,35,57,39		

matriz_texto_derrota: .word 7, 1 		
		.byte 34,22,35,35,25,60,39
		
matriz_texto_voce_ganhou: .word 12, 1 		# inclui espaço no final	
		.byte 31,8,2,20,77,5,0,7,6,8,73,77
		
matriz_texto_pokebola: .word 8, 1 		
		.byte 24,25,26,29,37,25,38,39	
							
matriz_texto_voce_nao_tem_nenhuma: .word 20, 1 			
		.byte 31,8,2,20,77,7,16,8,77,72,4,69,77,7,4,7,6,73,69,0	
		
matriz_texto_ponto: .word 1, 1 			# so o tile de um ponto		
		.byte 54
									
matriz_texto_inventario_cheio: .word 17, 1 			# inclui ponto no final	
		.byte 57,7,11,4,7,72,19,70,78,8,77,2,6,4,78,8,54

matriz_texto_a_captura_falhou: .word 17, 1 		# inclui ponto no final
		.byte 39,77,2,0,9,72,73,70,0,77,66,0,76,6,8,73,54
		
matriz_texto_a_captura_funcionou: .word 20, 1 		# inclui exclamação no final
		.byte 39,77,2,0,9,72,73,70,0,77,66,73,7,2,78,8,7,8,73,74
																																														
# Essa matriz de tiles em especial representa uma parte da tela de combate e será usada durante a ação de ataque
# para limpar o sprite do pokemon inimigo e do RED da tela
matriz_tiles_combate_limpar_pokemon:
		.word 4, 4 		
		.byte 2,2,2,2,
		      2,2,2,2,
		      5,6,7,8,
		      13,14,15,16
												
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
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
		
	call INICIAR_TELA_DE_COMBATE		# inicia a tela de combate

	call INICIAR_POKEMON_INIMIGO	# imprime os sprites e outros elementos relacionados ao pokemon inimigo

	call INICIAR_POKEMON_RED	# imprime os sprites e outros elementos relacionados ao pokemon do RED

	LOOP_TURNOS_COMBATE:
	
		call TURNO_JOGADOR
		# como retorno a0 tem um numero especificando o que fazer (continuar, parar combate, etc)
		
		# se a0 == 1 o combate deve parar
		li t0, 1
		beq a0, t0, FIM_LOOP_TURNOS_COMBATE

		# se a0 == 2 o RED venceu
		li t0, 2
		beq a0, t0, COMBATE_RED_GANHOU

		call TURNO_COMPUTADOR	
		
		# se a0 == 1 o computador ganhou
		li t0, 1
		beq a0, t0, COMBATE_COMPUTADOR_GANHOU
																							
		j LOOP_TURNOS_COMBATE
	
	COMBATE_RED_GANHOU:
		li a5, 0		# a5 == 0 porque o RED ganhou
		call COMBATE_VITORIA_OU_DERROTA
		j FIM_LOOP_TURNOS_COMBATE
	
	COMBATE_COMPUTADOR_GANHOU:
		li a5, 1		# a5 == 1 porque o computador ganhou	
		call COMBATE_VITORIA_OU_DERROTA
			
	FIM_LOOP_TURNOS_COMBATE:
	# indenpendente do que aconteceu no combate a área e o sprite do RED precisam ser impressos novamente
	# para que o jogo possa continuar
	
	call REIMPRIMIR_RED_E_AREA	
		
	FIM_EXECUTAR_COMBATE:
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 	
	
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

	call TROCAR_FRAME	# troca o frame sendo mostrado, mostrando o frame 1

	# De inicio é necessário imprimir alguns retangulos com a cor 190, isso porque os tiles do inventario
	# e combate são compartilhados para economizar memoria, então especificamente os cantos da caixa
	# onde os dialogos e menu de ação estarão são transparentes, mas o ideal é que apareça a cor do fundo
	# da tela de combate (190)

	# Calculando o endereço de onde imprimir o primeiro retangulo
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 16 			# numero da coluna 
		li a3, 176			# numero da linha
		call CALCULAR_ENDERECO		
			
		mv a1, a0	# move o retorno para a1
			
		# Imprimindo o rentangulo com a cor
		li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
		# a1 já tem o endereço de onde começar a impressao		
		li a2, 4		# numero de colunas da imagem da seta
		li a3, 48		# numero de linhas da imagem da seta			
		call PRINT_COR

		# Imprimindo o rentangulo com a cor
		li a0, 182		# a0 tem o valor do fundo do menu do inventario
		li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
		li t0, -15075 		# -15075 = -48 * 320 + 285			
		add a1, a1, t0		# o proximo retangulo começa a -48 linhas e 285 colunas de onde o ultimo
					# terminou de ser impresso
		li a2, 4		# numero de colunas da imagem da seta
		li a3, 48		# numero de linhas da imagem da seta			
		call PRINT_COR
		
	# Agora imprime a tela de combate no frame 0 com os textos necessários
		# Imprimindo a tela no frame 0
		la a0, matriz_tiles_tela_combate	# carrega a matriz de tiles
		la a1, tiles_combate_e_inventario	# carrega a imagem com os tiles
		li a2, 0xFF000000			# os tile serão impressos no frame indicado por t6
		call PRINT_TILES

		# Imprimindo os textos do menu de combate no frame 0
			# Calculando o endereço de onde imprimir o primeiro texto (ATACAR) no frame 0
			li a1, 0xFF000000	# seleciona o frame 0
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
												
	call TROCAR_FRAME	# troca o frame sendo mostrado, mostrando o frame 0

	# Replica o frame 0 no frame 1 para que os dois estejam iguais
	li a0, 0xFF000000	# copia o frame 0 no frame 1
	li a1, 0xFF100000
	li a2, 320		# numero de colunas a serem copiadas
	li a3, 240		# numero de linhas a serem copiadas
	call REPLICAR_FRAME
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #	

COMBATE_VITORIA_OU_DERROTA:
	# Procedimento simples para a vitoria ou derrota do RED, renderizando o pokemon do RED ou o 
	# pokemon inimigo desaparencendo, uma mensagem de vitoria ou derrota na caixa de dialogo e 
	# caso seja uma vitoria o jogador recebe 1 pokebola
	# 
	# Argumentos:
	# 	a5 = [ 0 ] se o RED ganhou
	#	     [ 1 ] se o RED perdeu
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Espera alguns milisegundos	
		li a0, 1000			# sleep 1 s
		call SLEEP			# chama o procedimento SLEEP	
						
	# Primeiro encontra a imagem do pokemon do RED ou o inimigo dependendo de a5
	andi t0, s11, 7		# faz o andi com 7 para deixar somente os bits que fazem parte do tipo
				# do pokemon inimigo intactos
	beq a5, zero, VITORIA_OU_DERROTA_ENCONTRAR_IMAGEM
	
	# Caso a5 != 0 o RED perdeu e encontra a imagem do pokemon dele		
	li t0, 28672
	and t0, s11, t0		# faz o andi com t0 para deixar somente os bits que fazem parte do tipo
				# do pokemon do RED intactos
	srli t0, t0, 12		# move os bits do tipo para o começo de t0
	
	VITORIA_OU_DERROTA_ENCONTRAR_IMAGEM:						
	addi t0, t0, -1		# -1 porque o tipo do pokemon começa em 1
			
	la t1, pokemons			# t1 tem o inicio da imagem do BULBASAUR
	addi t1, t1, 8			# pula para onde começa os pixels no .data	
	li t2, 1482			# 1482 = 38 * 39 = tamanho de uma imagem de um pokemon, ou seja,
	mul t2, t2, t0			# passa o endereço de t1 para a imagem do pokemon 
	add t3, t1, t2			# correto de acordo com t0
	
	call TROCAR_FRAME		# inverte o frame, mostrando o frame 1																																																																																																																																																																																															
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																														
	# Imprime a imagem do pokemon desaparecendo da tela no frame 0
		# Calculando o endereço de onde imprimir o pokemon de acordo com a5
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde imprimir o pokemon inimigo			
		li a2, 204		# numero da coluna 
		li a3, 43		# numero da linha
		li a4, 0	# a silhueta será impressa na orientação normal		
		beq a5, zero, VITORIA_OU_DERROTA_PRINT_POKEMON
						
		# Onde imprimir o pokemon do RED
		li a2, 76		# numero da coluna 
		li a3, 107		# numero da linha	
		li a4, 1	# a silhueta será impressa na orientação invertida	
		
		VITORIA_OU_DERROTA_PRINT_POKEMON:			
		
		call CALCULAR_ENDERECO			
	
		mv a1, a0		# move o retorno para a1
		
		# Imprime a silhueta do pokemon	no frame 0
		mv a0, t3	# t3 tem a imagem do pokemon que foi decidido no inicio procedimento				
		# a1 já tem o endereço de onde imprimir a imagem
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		# a4 já tem o valor da orientação da silhueta
		call PRINT_POKEMON_SILHUETA
		
		call TROCAR_FRAME		# inverte o frame, mostrando o frame 0	
																																																																																																																																																																																																	
		# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	

		# Remove o sprite do pokemon o que pode ser feito imprimindo novamente os
		# tiles onde ele está
		# Calculando o endereço de onde imprimir os tiles no frame 1 de acordo com a5
		li a1, 0xFF100000	# seleciona o frame 0
		
		# Onde imprimir os tiles no pokemon inimigo 			
		li a2, 192		# numero da coluna 
		li a3, 32		# numero da linha
		beq a5, zero, VITORIA_OU_DERROTA_PRINT_TILES
						
		# Onde imprimir os tiles no pokemon do RED 
		li a2, 64		# numero da coluna 
		li a3, 96		# numero da linha	
		
		VITORIA_OU_DERROTA_PRINT_TILES:	
		
		call CALCULAR_ENDERECO	
		
		mv t6, a0		# move o retorno para t6
				
		# Agora novamente no frame 1 os tiles onde o pokemon está
		la a0, matriz_tiles_combate_limpar_pokemon	# carrega a matriz de tiles
		la a1, tiles_combate_e_inventario	# carrega a imagem com os tiles
		mv a2, t6				# t6 tem o endereço onde os tile serão impressos
		call PRINT_TILES
		
		call TROCAR_FRAME		# inverte o frame, mostrando o frame 1	
		
		# Agora novamente no frame 0 os tiles onde o pokemon está
		la a0, matriz_tiles_combate_limpar_pokemon	# carrega a matriz de tiles
		la a1, tiles_combate_e_inventario	# carrega a imagem com os tiles
		mv a2, t6				# t6 tem o endereço onde os tile serão impressos
		li t0, 0x00100000
		sub a2, a2, t0			# passa o endereço de a2 para o frame 0
		call PRINT_TILES

	# Espera alguns milisegundos	
		li a0, 1000			# sleep 1 s
		call SLEEP			# chama o procedimento SLEEP	

	# Agora imprime a mensagem vitoria ou derrota na caixa de dialogo em ambos os frames
		# Primeiro limpa a caixa de dialogo	
		# Calculando o endereço de onde começar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv t5, a0		# move o retorno para t5

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		mv a1, t5		# t5 tem o endereço de onde começar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR	
		
		# Imprimindo o texto de vitoria ou derrota de acordo com a5
		# Calculando o endereço de onde imprimir o texto no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 75		# numero da coluna 
		li a3, 193		# numero da linha
		call CALCULAR_ENDERECO	
			
		mv a1, a0		# move o retorno para a1
	
		la a4, matriz_texto_vitoria 	
		beq a5, zero, VITORIA_OU_DERROTA_PRINT_MENSAGEM 
			la a4, matriz_texto_derrota
			
		VITORIA_OU_DERROTA_PRINT_MENSAGEM:
					
		# Imprime o texto com a mensagem
		# a1 já tem o endereço de onde imprimir o texto
		# a4 tem a matriz com a mensagem
		call PRINT_TEXTO
				
	call TROCAR_FRAME		# inverte o frame, mostrando o frame 0
		
	# Replica a caixa de dialogo do frame 0 no frame 1 para que os dois estejam iguais				
	mv a0, t5		# t5 ainda tem o endereço da caixa no frame 0
	li t0, 0x00100000
	add a1, t5, t0		# a1 recebe o endereço de t5 no frame 1		
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME	
	
	# Espera alguns milisegundos	
		li a0, 2500			# sleep 2,5 s
		call SLEEP			# chama o procedimento SLEEP	
		
	# se o RED venceu ele pode ganhar 1 pokebola
	bne a5, zero, FIM_COMBATE_VITORIA_DERROTA
		la t0, NUMERO_DE_POKEBOLAS
		lb t0, 0(t0)
		
		# O jogador só ganha uma pokebola caso ele não tenha 9 pokebolas ainda
		li t1, 9
		beq t0, t1, FIM_COMBATE_VITORIA_DERROTA
		
		call TROCAR_FRAME		# troca o frame, mostrando o frame 1
		
		# Agora imprime o texto ("Você ganhou 1 x POKEBOLA!")
		# Primeiro limpa a caixa de dialogo, imprimindo o rentangulo com a cor de fundo da 
		# caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		mv a1, t5		# t5 ainda tem o endereço de onde começar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR	
		
		# Calculando o endereço de onde imprimir o texto ('Você ganhou ') no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	
			
		mv a1, a0		# move o retorno para a1
		la a4, matriz_texto_voce_ganhou	
		call PRINT_TEXTO
		
		# Imprime o numero 1	
		addi a1, a1, 641	# 641 = 320 * 2 + 1
		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o tile,
		# de modo que está a +2 linhas e 1 coluna de onde imprimir o numero	
		li a0, 1		# numero a ser impresso
		call PRINT_NUMERO
		
		# Imprime o ultimo texto ("POKEBOLA!")	
		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o numero,
		# de modo que está a -12 linhas e 9 colunas de onde imprimir o proximo texto
		li t0, -3831	# -3831 = -12 * 320 + 9
		add a1, a1, t0
		la a4, matriz_texto_pokebola		
		call PRINT_TEXTO
				
		call TROCAR_FRAME		# inverte o frame, mostrando o frame 1
		
		# Replica a caixa de dialogo do frame 0 no frame 1 para que os dois estejam iguais				
		mv a0, t5		# t5 ainda tem o endereço da caixa no frame 0
		li t0, 0x00100000
		add a1, t5, t0		# a1 recebe o endereço de t5 no frame 1		
		li a2, 264		# numero de colunas a serem copiadas
		li a3, 32		# numero de linhas a serem copiadas
		call REPLICAR_FRAME
									
	# Espera alguns milisegundos	
		li a0, 4500			# sleep 4,5 s
		call SLEEP			# chama o procedimento SLEEP	
	
	# Incrementa o numero de pokebolas atual
	la t0, NUMERO_DE_POKEBOLAS
	lb t1, 0(t0)
	addi t1, t1, 1
	sb t1, 0(t0)
					
	FIM_COMBATE_VITORIA_DERROTA:																																
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
	# e escolhe a matriz de texto correta com o nome do pokemon (t5)
	
	li a0, 5				# encontra um numero randomico entre 0 e 4
	call ENCONTRAR_NUMERO_RANDOMICO		
	
	# se a0 == 0 então é pokemon inimigo será o BULBASAUR 
	li s11, BULBASAUR 			# codigo do BULBASAUR
	la t5, matriz_texto_bulbasaur		# carrega a matriz de texto do pokemon
	beq a0, zero, PRINT_TEXTO_POKEMON_INIMIGO
			
	# se a0 == 1 então é pokemon inimigo será o CHARMANDER 
	li t0, 1	
	li s11, CHARMANDER 			# codigo do CHARMANDER	
	la t5, matriz_texto_charmander		# carrega a matriz de texto do pokemon	
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
			
	# se a0 == 2 então é pokemon inimigo será o SQUIRTLE 
	li t0, 2	
	li s11, SQUIRTLE 			# codigo do SQUIRTLE
	la t5, matriz_texto_squirtle		# carrega a matriz de texto do pokemon				
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
										
	# se a0 == 3 então é pokemon inimigo será o CATERPIE 
	li t0, 3	
	li s11, CATERPIE 			# codigo do CATERPIE	
	la t5, matriz_texto_caterpie		# carrega a matriz de texto do pokemon			
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
	
	# se a0 == 4 então é pokemon inimigo será o DIGLETT 
	li t0, 4	
	li s11, DIGLETT 			# codigo do DIGLETT
	la t5, matriz_texto_diglett		# carrega a matriz de texto do pokemon		
	
	PRINT_TEXTO_POKEMON_INIMIGO:
	
	mv t6, a0	# salva em t6 o numero do pokemon escolhido
	
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
		
	# Replica a caixa de dialogo do frame 0 no frame 1 para que os dois estejam iguais
	# Calculando o endereço de onde começar a copia
	li a1, 0xFF000000	# seleciona o frame 0
	li a2, 28		# numero da coluna 
	li a3, 185		# numero da linha
	call CALCULAR_ENDERECO	
			
	mv t1, a0		# move o retorno para a1
				
	mv a0, t1		# t1 tem o endereço da caixa no frame 0
	li t0, 0x00100000
	add a1, t1, t0		# a1 recebe o endereço de t1 no frame 1		
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME
																								
	# Agora renderiza o pokemon inimigo aparecendo na tela
		mv a0, t6		# t6 ainda tem o numero do pokemon escolhido
		li a5, 0		# a5 = 0 para renderizar o pokemon inimigo
		call RENDERIZAR_POKEMON
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																						
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #

INICIAR_POKEMON_RED:
	# Procedimento que atualiza o valor de s11 com o pokemon do RED e imprime todos os sprites,
	# animações e textos relacionados a esse pokemon aparecendo na tela

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	call TROCAR_FRAME	# inverte o frame sendo mostrado, mostrando o frame 1

	# Primeiro limpa a caixa de dialogo no frame 0	
		# Calculando o endereço de onde começar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv t5, a0		# move o retorno para t5

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		mv a1, t5		# t5 tem o endereço de onde começar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR
					
	# Agora imprime o texto "Escolha o seu POKÉMON!"
		mv a1, t5	# o texto será impresso no mesmo endereço onde a limpeza foi feita acima
		la a4, matriz_texto_escolha_o_seu_pokemon 	
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
		mv a1, t3 		# t3 tem o endereço de onde imprimir a imagem
		lw a2, 0(a0)		# numero de colunas da imagem
		lw a3, 4(a0)		# numero de linhas da imagem
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	

	call TROCAR_FRAME	# inverte o frame sendo mostrado, mostrando o frame 0

	# Espera o jogador apertar ENTER	
	LOOP_ENTER_ESCOLHER_POKEMON_RED:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 é o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_ESCOLHER_POKEMON_RED
	
	# Antes é necessário preparar o frame 1 para mostrar o inventario
		# Limpa a caixa de dialogo no frame 0 somente para indicar que não mais necessário apertar ENTER					
		# Para retirar a imagem da seta basta imprimir uma área de mesmo tamanho com a cor
		# de fundo do inventario
		li a0, 0xFF		# a0 tem o valor do fundo do menu da caixa de dialogo (branco)
		mv a1, t3		# t3 ainda tem o endereço de onde a seta está		
		li a2, 10		# numero de colunas da imagem da seta
		li a3, 6		# numero de linhas da imagem da seta	
		call PRINT_COR	
	
		# De inicio copia o que acabou de ser impresso no frame 0 (o texto na caixa de dialogo) para
		# o frame 1
		mv a0, t5	# a copia se inicio no frame 0 no mesmo endereço onde o texto foi impresso
		li t0, 0x00100000
		add a1, t5, t0	# a copia vai para o endereço de a0, mas no frame 1
		li a2, 148		# numero de colunas a serem copiadas
		li a3, 32		# numero de linhas a serem copiadas
		call REPLICAR_FRAME	
		
		# Depois limpa algumas partes do frame de modo que só o que vai aparecer é a caixa de dialogo
		# e o inventario
			# Calculando o endereço de onde começar a limpeza no frame 1
			li a1, 0xFF100000	# seleciona o frame 1
			li a2, 32		# numero da coluna 
			li a3, 32		# numero da linha
			call CALCULAR_ENDERECO	

			mv a1, a0		# move o retorno para a1

			# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
			li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
			# a1 já tem o endereço de onde começar a impressao		
			li a2, 128		# numero de colunas da area a ser impressa
			li a3, 4		# numero de linhas da area a ser impressa		
			call PRINT_COR	
						
			# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
			li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
			# a1 já tem o endereço de onde começar a impressao		
			li a2, 26		# numero de colunas da area a ser impressa
			li a3, 28		# numero de linhas da area a ser impressa		
			call PRINT_COR
							
			# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
			li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
			li t0, 21440		# 24017 = 67 * 320 
			add a1, a1, t0		# o proximo retangulo começa a 75 linhas de 
						# onde o ultimo terminou de ser impresso
			li a2, 24		# numero de colunas da area a ser impressa
			li a3, 26		# numero de linhas da area a ser impressa		
			call PRINT_COR											

			# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
			li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
			li t0, -28568		# -28568 = -90 * 320 + 232
			add a1, a1, t0		# o proximo retangulo começa a -90 linhas e 232 colunas de 
						# onde o ultimo terminou de ser impresso
			li a2, 23		# numero de colunas da area a ser impressa
			li a3, 28		# numero de linhas da area a ser impressa	
			call PRINT_COR	
																																					
	li a5, 1		# a5 = 1 porque o inventario foi mostrado através do combate
	li a6, 0		# a6 = 0 para mostrar o inventario normalmente
	call MOSTRAR_INVENTARIO	

	# do retorno de MOSTRAR_INVENTARIO a0 tem um valor de 0 a 4 representando a opção, e consequentemente,
	# qual pokemon o jogador escolheu

	mv t6, a0	# salva o numero do pokemon escolhido em t6

	# Primeiro encontra a matriz de texto correta com o nome do pokemon (t5) e atualiza o valor de s11
	# com o codigo do pokemon do RED

	# se a0 == 0 então é pokemon escolhido é o BULBASAUR 
	la t5, matriz_texto_bulbasaur		# carrega a matriz de texto do pokemon
	li t1, BULBASAUR
	beq a0, zero, PRINT_TEXTO_POKEMON_RED
			
	# se a0 == 1 então é pokemon escolhido é o CHARMANDER 
	li t0, 1	
	la t5, matriz_texto_charmander		# carrega a matriz de texto do pokemon	
	li t1, CHARMANDER	
	beq a0, t0, PRINT_TEXTO_POKEMON_RED
			
	# se a0 == 2 então é pokemon escolhido é o SQUIRTLE 
	li t0, 2	
	la t5, matriz_texto_squirtle		# carrega a matriz de texto do pokemon	
	li t1, SQUIRTLE					
	beq a0, t0, PRINT_TEXTO_POKEMON_RED
										
	# se a0 == 3 então é pokemon escolhido é o CATERPIE 
	li t0, 3	
	la t5, matriz_texto_caterpie		# carrega a matriz de texto do pokemon
	li t1, CATERPIE					
	beq a0, t0, PRINT_TEXTO_POKEMON_RED
	
	# se a0 == 4 então é pokemon escolhido é o DIGLETT 
	la t5, matriz_texto_diglett		# carrega a matriz de texto do pokemon	
	li t1, DIGLETT							
	
	PRINT_TEXTO_POKEMON_RED:
	
	slli t1, t1, 12		# coloca o codigo do pokemon escolhido depois dos 12 bits do pokemon inimgo
	add s11, s11, t1	# em s11
	
	# Replica o frame 0 no frame 1 para que os dois estejam iguais
	li a0, 0xFF000000	# copia o frame 0 no frame 1
	li a1, 0xFF100000
	li a2, 320		# numero de colunas a serem copiadas
	li a3, 240		# numero de linhas a serem copiadas
	call REPLICAR_FRAME
	
	call TROCAR_FRAME		# inverte o frame, mostrando o frame 1
		
	# Agora imprime o texto "O YYY foi escolhido.", onde YYY é o nome do pokemon no frame 0
	
	# Limpa a caixa de dialogo no frame 0	
		# Calculando o endereço de onde começar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv a1, a0		# move o retorno para t5

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		# a1 já tem o endereço de onde começar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR
		
		# Calculando o endereço de onde imprimir o primeiro texto ('O ') no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	
			
		mv a1, a0		# move o retorno para a1
	
		# Imprime o texto com o nome do Pokemon
		# a1 já tem o endereço de onde imprimir o texto
		mv a4, t5		# a4 recebe a matriz de texto do pokemon decidido acima
		call PRINT_TEXTO

		# Imprime o texto com o ('escolhido.')
		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o tile,
		# de modo que está na posição exata do proximo texto
		la a4, matriz_texto_escolhido 	
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
	LOOP_ENTER_POKEMON_ESCOLHIDO:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 é o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_POKEMON_ESCOLHIDO
	
	# Limpa a caixa de dialogo no frame 0 somente para indicar que o não mais necessário apertar ENTER					
		# Para retirar a imagem da seta basta imprimir uma área de mesmo tamanho com a cor
		# de fundo do inventario
		li a0, 0xFF		# a0 tem o valor do fundo do menu da caixa de dialogo (branco)
		mv a1, t3		# t3 ainda tem o endereço de onde a seta está		
		li a2, 10		# numero de colunas da imagem da seta
		li a3, 6		# numero de linhas da imagem da seta	
		call PRINT_COR					

	# Replica a caixa de dialogo do frame 0 no frame 1 para que os dois estejam iguais
	# Calculando o endereço de onde começar a copia no frame 0
	li a1, 0xFF000000	# seleciona o frame 0
	li a2, 28		# numero da coluna 
	li a3, 185		# numero da linha
	call CALCULAR_ENDERECO	
			
	mv t1, a0		# move o retorno para a1
				
	mv a0, t1		# t1 tem o endereço da caixa no frame 0
	li t0, 0x00100000
	add a1, t1, t0		# a1 recebe o endereço de t1 no frame 1		
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME
																																																																																																																																																																																																																																					
	# Agora renderiza o pokemon do RED aparecendo na tela
		mv a0, t6		# t6 ainda tem o numero do pokemon escolhido
		li a5, 1		# a5 = 1 para renderizar o pokemon do RED
		call RENDERIZAR_POKEMON
																																																																							
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 
																																																																																																																																																																																																																																																																																											
# ====================================================================================================== #

TURNO_JOGADOR:
	# Procedimento que coordena o turno do jogador, fazendo chamadas aos procedimentos de ação 
	# (atacar, defender, item e fugir) de acordo com os inputs do jogador
	#
	# Retorno:
	# 	a0 = [ 0 ] se o combate deve continuar
	#	     [ 1 ] se o combate deve parar  
	#	     [ 2 ] se o RED ganhou
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	INICIO_TURNO_JOGADOR:
			
	# Primeiro encontra a matriz de texto com o nome do pokemon escolhido pelo RED
	srli t0, s11, 12	# os primeiros 12 bits de s11 são o codigo do pokemon inimigo e os proximos 12
				# são do pokemon do RED

	# Transforma o codigo do pokemon em uma matriz de texto
	la t6, matriz_texto_bulbasaur		# carrega a matriz de texto do pokemon
	li t1, BULBASAUR
	beq t0, t1, TURNO_JOGADOR_PRINT_TEXTO
			
	la t6, matriz_texto_charmander		# carrega a matriz de texto do pokemon	
	li t1, CHARMANDER	
	beq t0, t1, TURNO_JOGADOR_PRINT_TEXTO
			
	la t6, matriz_texto_squirtle		# carrega a matriz de texto do pokemon	
	li t1, SQUIRTLE				
	beq t0, t1, TURNO_JOGADOR_PRINT_TEXTO
										
	la t6, matriz_texto_caterpie		# carrega a matriz de texto do pokemon	
	li t1, CATERPIE		
	beq t0, t1, TURNO_JOGADOR_PRINT_TEXTO
	
	la t6, matriz_texto_diglett		# carrega a matriz de texto do pokemon	
	
	TURNO_JOGADOR_PRINT_TEXTO:
	
	# Agora imprime o texto "O que o YYY deve fazer?", onde YYY é o nome do pokemon
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1

		# Primeiro limpa a caixa de dialogo	
		# Calculando o endereço de onde começar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv t5, a0		# move o retorno para t5

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		mv a1, t5		# t5 tem o endereço de onde começar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR	
				
		# Imprime o texto com o 'O que o  '
		mv a1, t5		# t5 já tem o endereço de onde imprimir o texto
		la a4, matriz_texto_o_que_o 	
		call PRINT_TEXTO
		
		# Imprime o texto com o nome do Pokemon
		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o tile,
		# de modo que está na posição exata do proximo texto
		mv a4, t6		# a4 recebe a matriz de texto do pokemon decidido acima
		call PRINT_TEXTO

		# Imprime o texto com o ' vai'
		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o tile,
		# de modo que está na posição exata do proximo texto
		la a4, matriz_texto_vai	
		call PRINT_TEXTO
		
		# Calculando o endereço de onde imprimir o ultimo texto ('fazer?') no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 201		# numero da linha
		call CALCULAR_ENDERECO	
			
		mv a1, a0		# move o retorno para a1
				
		# Imprime o texto com o ('fazer?')
		# a1 já tem o endereço de onde imprimir o texto					
		la a4, matriz_texto_fazer 	
		call PRINT_TEXTO
	
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0

		# Replica o frame 0 no frame 1 para que os dois estejam iguais
		mv a0, t5		# t5 tem o endereço da caixa no frame 0		
		li t0, 0x00100000
		add a1, t5, t0		# a1 recebe o endereço de t5 no frame 1		
		li a2, 264		# numero de colunas a serem copiadas
		li a3, 32		# numero de linhas a serem copiadas
		call REPLICAR_FRAME
								
	call RENDERIZAR_MENU_DE_COMBATE

	# Como retorno de RENDERIZAR_MENU_DE_COMBATE a0 tem o valor da opção selecionada pelo jogador
	# Então é decidido a partir de a0 qual procedimento do menu chamar
		
	bne a0, zero, COMBATE_VERIFICAR_ACAO_FUGIR
		# se a opção selecionada for 0 então chama a ação de atacar	
		li a6, 0		# a6 == 0 porque quem está atacando é o RED																																																																									
		call ACAO_ATACAR
		# como retorno a0 == 0 se o combate deve continuar e 1 caso o RED tenha vencido
		beq a0, zero, FIM_TURNO_JOGADOR
			li a0, 2		# a0 == 2 porque o RED ganhou
		j FIM_TURNO_JOGADOR
	
	COMBATE_VERIFICAR_ACAO_FUGIR:																														
	li t0, 1
	bne a0, t0, COMBATE_VERIFICAR_ACAO_ITEM
		# se a opção selecionada for 1 então chama a ação de fugir																																																																										
		call ACAO_FUGIR
		# como retorno a0 == 0 se o combate deve continuar e 2 caso o RED venceu, esse retorno será
		# propagado para EXECUTAR_COMBATE
	
	COMBATE_VERIFICAR_ACAO_ITEM:
	li t0, 3
	bne a0, t0, FIM_TURNO_JOGADOR
		# se a opção selecionada for 3 então chama a ação de item																																																																										
		call ACAO_ITEM
		# como retorno a0 == 2 se o turno não deve acabar
		li t0, 2
		beq a0, t0, INICIO_TURNO_JOGADOR
			
		# como retorno a0 == 0 se o combate deve continuar e 1 se deve parar, esse retorno será
		# propagado para EXECUTAR_COMBATE	
	
	FIM_TURNO_JOGADOR:

	# dos procedimentos de ação do jogador chamados acima a0 teve ter um retorno especificando o que 
	# EXECUTAR_COMBATE deve fazer (continuar combate, terminar combate, etc)
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																													
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ------------------------------------------------------------------------------------------------------ #
# Abaixo seguem os procedimentos de ação do jogador, esses procedimentos são chamados através do menu	 #
# de combate durante TURNO_JOGADOR									 #
# Todos os procedimentos tem mais ou menos o mesmo retorno, um numero indicando se o combate deve 	 #
# continuar, parar, se o RED venceu ou se o pokemon inimigo vennceu				 	 #
# Além disso, todos devem terminar com o frame 0 e frame 1 iguais, com frame 0 na tela			 #
# ------------------------------------------------------------------------------------------------------ #

ACAO_FUGIR:
	# A ação de fugir tem uma chance de 1/3 de não funcionar, caso funcione simplesmente termina o combate
	#
	# Retorno:
	# 	a0 = [ 0 ] se o combate deve continuar
	#	     [ 1 ] se o combate deve parar e voltar ao loop do jogo 
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Imprime a mensagem inicial ('YYY tenta fugir!'), onde YYY é o nome do pokemon do RED
	mv a4, t6		# t6 ainda tem a matriz de texto do pokemon do RED decidida em TURNO_JOGADOR
	la a5, matriz_texto_tenta_fugir		# mensagem inicial
	call PRINT_MENSAGEM_INICIAL_DE_ACAO

	# Agora imprime o texto ('... YYY)', onde YYY é a mensagem se a fuga foi bem sucedida ou nao	
	# Calculando o endereço de onde imprimir o primeiro texto ('...') no frame 1
	li a1, 0xFF100000	# seleciona o frame 1
	li a2, 28		# numero da coluna 
	li a3, 185		# numero da linha
	call CALCULAR_ENDERECO	

	mv t5, a0		# move o retorno para a1

	# Imprime o texto ('...')
	mv a1, t5		# t5 tem o endereço de onde imprimir o texto
	la a4, matriz_texto_tres_pontos
	call PRINT_TEXTO
	
	mv t2, a1		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o tile,
				# de modo que está na posição exata do proximo texto
			
	call TROCAR_FRAME	# inverte o frame, mostrando o frame 1	

	# Replica a caixa de dialogo do frame 1 no frame 0 para que os dois estejam iguais
	mv a0, t5		# t5 tem o endereço da caixa no frame 1
	li t0, 0x00100000
	sub a1, t5, t0		# a1 recebe o endereço de t5 no frame 0			
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME	

	call TROCAR_FRAME	# inverte o frame, mostrando o frame 0	
													
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_ACAO_FUGIR_TRES_PONTOS:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 é o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_ACAO_FUGIR_TRES_PONTOS
										
	# Escolhe um numero randomico de 0 a 2, se o numero for 0 então a fuga nao foi bem sucedida
	li a0, 2
	call ENCONTRAR_NUMERO_RANDOMICO
		
	bne a0, zero, FUGA_FUNCIONOU

	# -------------------------------------------------------

	# A fuga falhou se a0 == 0

	# Imprime o texto com o ' a fuga falhou' no frame 1
	mv a1, t2	# pelo PRINT_TEXTO anterior t2 ainda tem salvo o endereço onde o ultimo tile
			# foi impresso, de modo que está na posição exata do proximo texto
	la a4, matriz_texto_a_fuga_falhou
	call PRINT_TEXTO	
	
	li t2, 0		# t2 recebe 0 para indicar que o combate deve continuar
	
	j FIM_ACAO_FUGA		
	
	# -------------------------------------------------------
	
	FUGA_FUNCIONOU:		
	
	# A fuga falhou se a0 != 0

	# Imprime o texto com o ' a fuga funcionou!' no frame 1
	mv a1, t2	# pelo PRINT_TEXTO anterior t2 ainda tem salvo o endereço onde o ultimo tile
			# foi impresso, de modo que está na posição exata do proximo texto
	la a4, matriz_texto_a_fuga_funcionou
	call PRINT_TEXTO
		
	li t2, 1		# t2 recebe 1 para indicar que o combate não deve continuar
													
	# -------------------------------------------------------
		
FIM_ACAO_FUGA:
	call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
	
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_FIM_ACAO_FUGIR:
		call VERIFICAR_TECLA
	
		li t0, 10		# 10 é o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_FIM_ACAO_FUGIR	
			
	# Replica a caixa de dialogo do frame 1 no frame 0 para que os dois estejam iguais	
	mv a0, t5		# t5 tem o endereço da caixa no frame 1
	li t0, 0x00100000
	sub a1, t5, t0		# a1 recebe o endereço de t5 no frame 0		
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME		

	call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
	
	mv a0, t2	# como retorno a0 recebe o valor de t2 decidido anteriormente, indicando se o combate
			# deve continuar ou não

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	
																							
# ------------------------------------------------------------------------------------------------------ #

ACAO_ATACAR:
	# A ação de atacar inclui decidir o dano que o pokemon vai dar, chamado todos os procedimentos
	# necessarios para mostrar esse dano sendo feito na tela
	# No caso dessa ação especifica ela pode ser usada pelo computador e pelo jogador
	#
	# Argumentos:
	# 	a6 = [ 0 ] se quem está atacando é pokemon do RED
	#	     [ 1 ] se quem está atacando é pokemon inimigo
	# Retorno:
	# 	a0 = [ 0 ] se o combate deve continuar
	#	     [ 1 ] se o combate deve parar porque o pokemon atacante venceu
	#		

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Encontra o codigo do pokemon que esta atacando (t5) e do pokemon inimigo (t6)
	srli t5, s11, 12	# t5 recebe o codigo do pokemon do RED	
	li t0, 4095	
	and t6, s11, t0		# faz com o andi com t0 de modo que t6 tem somente os bits que fazem parte
				# do codigo do pokemon inimigo em s11 intactos
					
	beq a6, zero, ACAO_ATACAR_ENCONTRAR_TEXTO
	# caso a6 != 0 o pokemon atacante é o pokemon do RED
	mv t0, t5
	mv t5, t6	# troca os codigo do pokemon atacante e do que está sendo atacado
	mv t6, t0
	
	# Transforma o codigo do pokemon atacante em uma matriz de texto
	ACAO_ATACAR_ENCONTRAR_TEXTO:
	la t4, matriz_texto_bulbasaur		# carrega a matriz de texto do pokemon
	li t1, BULBASAUR
	beq t5, t1, ACAO_ATACAR_PRINT_TEXTO
			
	la t4, matriz_texto_charmander		# carrega a matriz de texto do pokemon	
	li t1, CHARMANDER	
	beq t5, t1, ACAO_ATACAR_PRINT_TEXTO
			
	la t4, matriz_texto_squirtle		# carrega a matriz de texto do pokemon	
	li t1, SQUIRTLE				
	beq t5, t1, ACAO_ATACAR_PRINT_TEXTO
										
	la t4, matriz_texto_caterpie		# carrega a matriz de texto do pokemon	
	li t1, CATERPIE		
	beq t5, t1, ACAO_ATACAR_PRINT_TEXTO
	
	la t4, matriz_texto_diglett		# carrega a matriz de texto do pokemon	
	
	ACAO_ATACAR_PRINT_TEXTO:
	# Imprime a mensagem inicial ('YYY ataca!'), onde YYY é o nome do pokemon
	mv a4, t4		# t4 tem a matriz de texto do pokemon do RED decidida acima
	la a5, matriz_texto_ataca	# mensagem inicial
	call PRINT_MENSAGEM_INICIAL_DE_ACAO

	# Replica a caixa de dialogo do frame 0 no frame 1 para que os dois estejam iguais
	# Calculando o endereço de onde começar a copia no frame 0
	li a1, 0xFF000000	# seleciona o frame 0
	li a2, 28		# numero da coluna 
	li a3, 185		# numero da linha
	call CALCULAR_ENDERECO	
			
	mv t1, a0		# move o retorno para a1
				
	mv a0, t1		# t1 tem o endereço da caixa no frame 0
	li t0, 0x00100000
	add a1, t1, t0		# a1 recebe o endereço de t1 no frame 1		
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME

	# Para o ataque é necessario escolher um número de 0 a 7 indicando o dano que o pokemon deu
	li a0, 8
	call ENCONTRAR_NUMERO_RANDOMICO
	
	# Agora é necessário verificar se o pokemon é fraco ou forte contra o pokemon inimigo
		mv a5, a6		# move o argumento de a6 para a5
	
		li a6, -1		# a6 recebe -1 primeiramente para indicar o caso que o pokemon
					# não for nem fraco nem forte contra o pokemon inimigo
					# a6 pode ser atualizado com uma matriz de texto logo a frente
					
		# Encontra o codigo do pokemon que esta atacando (t5) e do pokemon inimigo (t6)
		srli t5, s11, 12	# t5 recebe o codigo do pokemon do RED	
		li t0, 4095	
		and t6, s11, t0		# faz com o andi com t0 de modo que t6 tem somente os bits que fazem parte
					# do codigo do pokemon inimigo em s11 intactos
					
		beq a5, zero, ACAO_ATACAR_CHECAR_TIPO_FORTE
		# caso a5 != 0 o pokemon atacante é o pokemon do RED
		mv t0, t5
		mv t5, t6	# troca os codigo do pokemon atacante e do que está sendo atacado
		mv t6, t0
		
		ACAO_ATACAR_CHECAR_TIPO_FORTE:
		# Checando o tipo do pokemon inimigo
		andi t0, t6, 56		# o andi 56 (111_000) deixa só os bits de t6 que 
					# correspondem ao tipo do pokemon inimigo intacto 
		srli t0, t0, 3		# move os bits para o começo de t0, de modo que o tipo cai em um 
					# intervalo de 0 a 4
					
		# Checando o tipo que o pokemon atacante é forte
		li t1, 0x0E00
		and t1, t5, t1		# o andi t1 deixa só os bits de t5 que 
					# correspondem ao tipo forte do pokemon que está atacando
		srli t1, t1, 9		# move os bits para o começo de t1, de modo que o tipo cai em um 
					# intervalo de 0 a 4		
	
		bne t1, t0, ACAO_ATACAR_CHECAR_TIPO_FRACO
		# verifica se o pokemon é forte contra o pokemon inimigo
		# se sim duplica o dano
		slli a0, a0, 1
		la a6, matriz_texto_muito_efetivo	
		j ACAO_ATACAR_RENDERIZAR_DANO
				
		ACAO_ATACAR_CHECAR_TIPO_FRACO:
		# Checando o tipo que o pokemon atacante é fraco
		li t1, 0x1C0
		and t1, t5, t1		# o andi t1 deixa só os bits de s11 que 
					# correspondem ao tipo fraco do pokemon atacante intacto 
		srli t1, t1, 6		# move os bits para o começo de t1, de modo que o tipo cai em um 
					# intervalo de 0 a 4		
	
		bne t1, t0, ACAO_ATACAR_RENDERIZAR_DANO
		# verifica se o pokemon é fraco contra o pokemon inimigo
		# se sim divide o dano por 2
		srli a0, a0, 1
		la a6, matriz_texto_pouco_efetivo	
		
	ACAO_ATACAR_RENDERIZAR_DANO:
	mv a7, a0		# move para a7 o valor do dano
	
	# Renderiza o dano aplicado
	mv a4, a0			# move para a4 o dano a ser renderizado
	# a5 já tem o indicativo de qual pokemon o dano vai ser dado	
	call RENDERIZAR_ATAQUE_DANO


	# Renderiza a animação de ataque
	# a5 já tem o indicativo de qual pokemon o dano vai ser dado	
	call RENDERIZAR_ATAQUE_EFEITO
		
	# Atualiza a barra de vida do pokemon
	mv a4, a5	# a5 já tem naturalmente o indicativo de qual barra de vida atualizar	
	call ATUALIZAR_BARRA_DE_VIDA	
	
	call TROCAR_FRAME		# inverte o frame, mostrando o frame 1
			
	# Agora imprime o texto ('YYY. O ataque deu X de dano'), onde YYY é a mensagem, se houver, indicando
	# se o ataque foi efeitvo ou nao, e X indica a quantidade de dano feito	
		# Primeiro limpa a caixa de dialogo	
		# Calculando o endereço de onde começar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv t4, a0		# move o retorno para t4

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		mv a1, t4		# t4 tem o endereço de onde começar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR	
		
		mv a1, t4		# move para a1 o endereço de onde imprimir o texto
		li t0, -1
		beq t0, a6, ACAO_ATAQUE_DANO_NORMAL
		
		# Imprimindo o texto indicando se o ataque foi efetivo ou não
		# a1 já tem o endereço de onde imprimir o texto	
		mv a4, a6		# a6 tem a matriz de texto decidida anteriormente
		call PRINT_TEXTO
			
		# Imprime o proximo texto ('O ataque'))
		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o tile,
		# de modo que está na posição exata do proximo texto
		la a4, matriz_texto_o_ataque
		call PRINT_TEXTO		
				
		# Caso o dano for fraco ou efeitvo o proximo texto será impresso na proxima linha
		# Calculando endereço de onde imprimir o texto na proxima linha
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 201		# numero da linha
		call CALCULAR_ENDERECO		 
			
		mv a1, a0		# move o retorno para a1
		j ACAO_ATAQUE_PRINT_TEXTO
						
		ACAO_ATAQUE_DANO_NORMAL:
		# Se a6 == -1 então o pokemon não é nem fraco nem forte contra o pokemon inimigo e não
		# tem nada para imprimir		
		# Imprime o proximo texto ('O ataque'))
		# a1 já tem o endereço de onde imprimir o texto
		la a4, matriz_texto_o_ataque
		call PRINT_TEXTO
		
		addi a1, a1, 4		# avança o endereço de a1 em 4 colunas para o proximo texto				

		ACAO_ATAQUE_PRINT_TEXTO:	
		# Imprime o proximo texto ('deu '))
		# a1 já está no endereço de onde imprimir o texto
		la a4, matriz_texto_deu
		call PRINT_TEXTO
						
		# Imprime o numero indicando o dano
		mv a0, a7		# a7 tem o dano dado
		addi a1, a1, 641	# 641 = 320 * 2 + 1
		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o tile,
		# de modo que está a +2 linhas e 1 coluna de onde imprimir o numero
		call PRINT_NUMERO

		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o tile,
		# de modo que está a -12 linhas e 10 colunas de onde imprimir o proximo texto
		li t0, -3830	# -3830	= -12 * 320 + 10
		add a1, a1, t0			
			
		ACAO_ATAQUE_PRINT_TEXTO_DANO:			
		# Imprime o proximo texto ('de dano.'))
		# a1 já está no endereço de onde imprimir o texto		
		la a4, matriz_texto_de_dano		
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
	
	# Replica a caixa de dialogo do frame 0 no frame 1 para que os dois estejam iguais
	# Calculando o endereço de onde começar a copia no frame 0
	li a1, 0xFF000000	# seleciona o frame 0
	li a2, 28		# numero da coluna 
	li a3, 185		# numero da linha
	call CALCULAR_ENDERECO	
			
	# a0 já tem o endereço da caixa no frame 0
	li t0, 0x00100000
	add a1, a0, t0		# a1 recebe o endereço de a0 no frame 1		
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME
	
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_ACAO_ATAQUE:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 é o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_ACAO_ATAQUE
	
	# Verifica a vida do pokemon inimigo
	mv a4, a5		# a5 já tem o indicativo para verificar a vida do pokemon do inimigo
	call VERIFICAR_VIDA_POKEMON
	
	li a0, 0		# a0 == 0 para o combate continuar
	bne a1, zero, FIM_ACAO_ATAQUE
	# se a vida do pokemon inimigo for 0 o atacante venceu	
		li a0, 1	# a0 == 1 para o combate parar porque o atacante venceu

	FIM_ACAO_ATAQUE:
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret		

# ------------------------------------------------------------------------------------------------------ #

ACAO_ITEM:
	# A ação de item inclui chamar o inventario para que o jogador possa escolher a pokebola,
	# cuidando de casos de conflito (inventario cheio, por exemplo). Caso seja possivel também
	# toma conta de capturar o pokemon e atualizar o inventario
	#
	# Retorno:
	# 	a0 = [ 0 ] se o combate deve continuar
	#	     [ 1 ] se o combate deve parar porque o pokemon foi capturado
	#	     [ 2 ] se não é para terminar o turno do jogador

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Antes limpa algumas partes do frame 1 de modo que só o que vai aparecer é a caixa de dialogo
	# e o inventario
		# Calculando o endereço de onde começar a limpeza no frame 1
		li a1, 0xFF100000	# seleciona o frame 1
		li a2, 32		# numero da coluna 
		li a3, 32		# numero da linha
		call CALCULAR_ENDERECO	

		mv a1, a0		# move o retorno para a1

		# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
		li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
		# a1 já tem o endereço de onde começar a impressao		
		li a2, 276		# numero de colunas da area a ser impressa
		li a3, 129		# numero de linhas da area a ser impressa		
		call PRINT_COR	
	
	li a6, 1		# a6 = 1 para mostrar somente as pokebolas
	call MOSTRAR_INVENTARIO	
		
	# Replica o frame 0 no frame 1 para que os dois estejam iguais
	li a0, 0xFF000000	# copia o frame 0 no frame 1
	li a1, 0xFF100000
	li a2, 320		# numero de colunas a serem copiadas
	li a3, 240		# numero de linhas a serem copiadas
	call REPLICAR_FRAME	
	
	# Agora é necessário fazer verificações para ver se o RED pode ou não capturar o pokemon
		# A primeira é se ele tem pokebolas
		la t0, NUMERO_DE_POKEBOLAS
		lb t0, 0(t0)
		bne t0, zero, ACAO_ITEM_VERIFICAR_INVENTARIO_CHEIO
		 		
		# se igual a zero imprime um texto indicando isso	
		
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
		
		# Primeiro limpa a caixa de dialogo no frame 0
		# Calculando o endereço de onde começar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv t5, a0		# move o retorno para t5

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		mv a1, t5		# t5 tem o endereço de onde começar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR	
				
		# Calculando o endereço de onde imprimir o primeiro texto no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv a1, a0		# move o retorno para a1

		# Imprime o texto ('Você não tem nenhuma')
		# a1 já tem o endereço de onde imprimir o texto
		la a4, matriz_texto_voce_nao_tem_nenhuma
		call PRINT_TEXTO
		
		# Calculando o endereço de onde imprimir o ultimo texto no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 201		# numero da linha
		call CALCULAR_ENDERECO	

		mv a1, a0		# move o retorno para a1

		# Imprime o texto ('POKEBOLA')
		# a1 já tem o endereço de onde imprimir o texto
		la a4, matriz_texto_pokebola
		call PRINT_TEXTO
		
		# Imprime o texto ('.')
		# a1 já tem naturalmente pelo PRINT_TEXTO acima o endereço de onde imprimir o texto
		la a4, matriz_texto_ponto
		call PRINT_TEXTO
	
		# Por fim, imprime uma pequena seta indicando que o jogador pode apertar ENTER para avançar
		# o dialogo						
		# Calculando o endereço de onde imprimir a seta no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 159		# numero da coluna 
		li a3, 207		# numero da linha
		call CALCULAR_ENDERECO											

		mv a1, a0		# move o retorno para a1		
									
		# Imprimindo a imagem da seta no frame 0
		la a0, seta_proximo_dialogo_combate		# carrega a imagem				
		# a1 já tem o endereço de onde imprimir a imagem
		lw a2, 0(a0)		# numero de colunas da imagem
		lw a3, 4(a0)		# numero de linhas da imagem
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
																																
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0

		# Replica a caixa de dialogo do frame 0 no frame 1 para que os dois estejam iguais				
		mv a0, t5		# t5 ainda tem o endereço da caixa no frame 0
		li t0, 0x00100000
		add a1, t5, t0		# a1 recebe o endereço de t5 no frame 1		
		li a2, 264		# numero de colunas a serem copiadas
		li a3, 32		# numero de linhas a serem copiadas
		call REPLICAR_FRAME				
		
		li t3, 2		# t3 = 2 porque o turno nao deve acabar																																																																											li t3, 0-2
		
		j LOOP_ENTER_ACAO_ITEM
		
		# ------------------------------------------------------------------------------------------
		
		ACAO_ITEM_VERIFICAR_INVENTARIO_CHEIO:
		
		# A segunda verificação é se o inventario está cheio
		la t0, POKEMONS_DO_RED
		li t1, 5	# numero de posições a serem verificadas
		li t2, 0	# t2 guarda o numero de posições livres no inventario
		
		ACAO_ITEM_ENCONTAR_ESPACO_VAZIO:
			lw t3, 0(t0)
			bne t3, zero, ENCONTAR_PROXIMO_ESPACO_VAZIO
				addi t2, t2, 1		# se a posição for 0 então incrementa t2
			ENCONTAR_PROXIMO_ESPACO_VAZIO:
			addi t1, t1, -1		# decrementa o numero de posições restantes
			addi t0, t0, 4		# proxima posicao do inventario
			bne t1, zero, ACAO_ITEM_ENCONTAR_ESPACO_VAZIO
		
		bne t2, zero, ACAO_ITEM_TENTAR_CAPTURAR_POKEMON
		# se não houver posição livre imprime um texto explicando o ocorrido
		
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
		
		# Primeiro limpa a caixa de dialogo no frame 0
		# Calculando o endereço de onde começar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv t5, a0		# move o retorno para t5

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		mv a1, t5		# t5 tem o endereço de onde começar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR	
				
		# Calculando o endereço de onde imprimir o primeiro texto no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv a1, a0		# move o retorno para a1

		# Imprime o texto ('Inventário cheio.')
		# a1 já tem o endereço de onde imprimir o texto
		la a4, matriz_texto_inventario_cheio
		call PRINT_TEXTO
		
		# Por fim, imprime uma pequena seta indicando que o jogador pode apertar ENTER para avançar
		# o dialogo						
		# Calculando o endereço de onde imprimir a seta no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 159		# numero da coluna 
		li a3, 207		# numero da linha
		call CALCULAR_ENDERECO											

		mv a1, a0		# move o retorno para a1		
									
		# Imprimindo a imagem da seta no frame 0
		la a0, seta_proximo_dialogo_combate		# carrega a imagem				
		# a1 já tem o endereço de onde imprimir a imagem
		lw a2, 0(a0)		# numero de colunas da imagem
		lw a3, 4(a0)		# numero de linhas da imagem
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
																																
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0

		# Replica a caixa de dialogo do frame 0 no frame 1 para que os dois estejam iguais				
		mv a0, t5		# t5 ainda tem o endereço da caixa no frame 0
		li t0, 0x00100000
		add a1, t5, t0		# a1 recebe o endereço de t5 no frame 1		
		li a2, 264		# numero de colunas a serem copiadas
		li a3, 32		# numero de linhas a serem copiadas
		call REPLICAR_FRAME				
		
		li t3, 2		# t3 = 2 porque o turno nao deve acabar	
		
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_ACAO_ITEM:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 é o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_ACAO_ITEM		
		
	j FIM_ACAO_ITEM
										
	ACAO_ITEM_TENTAR_CAPTURAR_POKEMON:
	# se tudo ocorreu corretamente o pokemon pode tentar ser capturado
																							
	# Primeiro encontra a imagem do pokemon inimigo dependendo
	andi t0, s11, 7		# faz o andi com 7 para deixar somente os bits que fazem parte do tipo
				# do pokemon inimigo intactos
	addi t0, t0, -1		# -1 porque o tipo do pokemon começa em 1
							
	la t1, pokemons			# t1 tem o inicio da imagem do BULBASAUR
	addi t1, t1, 8			# pula para onde começa os pixels no .data	
	li t2, 1482			# 1482 = 38 * 39 = tamanho de uma imagem de um pokemon, ou seja,
	mul t2, t2, t0			# passa o endereço de t1 para a imagem do pokemon 
	add t3, t1, t2			# correto de acordo com t0
	
	call TROCAR_FRAME		# inverte o frame, mostrando o frame 1																																																																																																																																																																																															
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																														
	# Imprime a imagem do pokemon desaparecendo da tela no frame 0
		# Calculando o endereço de onde imprimir o pokemon 
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 204		# numero da coluna 
		li a3, 43		# numero da linha					
		call CALCULAR_ENDERECO			
	
		mv a1, a0		# move o retorno para a1
		
		# Imprime a silhueta do pokemon	no frame 0
		mv a0, t3	# t3 tem a imagem do pokemon que foi decidido no inicio procedimento				
		# a1 já tem o endereço de onde imprimir a imagem
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		li a4, 0	# a silhueta será impressa na orientação normal		
		call PRINT_POKEMON_SILHUETA
		
		call TROCAR_FRAME		# inverte o frame, mostrando o frame 0	
																																																																																																																																																																																																	
		# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	

		# Remove o sprite do pokemon o que pode ser feito imprimindo novamente os
		# tiles onde ele está
		# Calculando o endereço de onde imprimir os tiles no frame 1
		li a1, 0xFF100000	# seleciona o frame 1
		li a2, 192		# numero da coluna 
		li a3, 32		# numero da linha
		call CALCULAR_ENDERECO	
		
		mv t6, a0		# move o retorno para t6
	
		# Agora novamente no frame 1 os tiles onde o pokemon está
		la a0, matriz_tiles_combate_limpar_pokemon	# carrega a matriz de tiles
		la a1, tiles_combate_e_inventario	# carrega a imagem com os tiles
		mv a2, t6				# t6 tem o endereço onde os tile serão impressos
		call PRINT_TILES
			
		# Imprime também uma imagem de uma pokebola representando a captura
		la a0, pokebola_captura		# carrega a imagem	
		li t0, 12186		# t0 = 38 * 320 + 26			
		add a1, t6, t0		# a imagem será impressa a +38 linhas +26 colunas de onde o pokemon
					# foi renderizado
		lw a2, 0(a0)		# numero de colunas da imagem
		lw a3, 4(a0)		# numero de linhas da imagem
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG														
		
		call TROCAR_FRAME		# inverte o frame, mostrando o frame 1	
		
		# Agora replica os pixels do frame 1 para o 0
		mv a0, t6		# t6 tem o endereço onde os tiles foram renderizados no frame 1
		li t0, 0x00100000
		sub a1, t6, t0		# a1 recebe o endereço de t6 no frame 0			
		li a2, 60		# numero de colunas a serem copiadas
		li a3, 56		# numero de linhas a serem copiadas
		call REPLICAR_FRAME
					
	call TROCAR_FRAME		# inverte o frame, mostrando o frame 0	
	
	# Agora imprime o texto ('... YYY)', onde YYY é a mensagem se a captura foi bem sucedida ou nao	
	# Calculando o endereço de onde imprimir o primeiro texto ('...') no frame 1
	li a1, 0xFF100000	# seleciona o frame 1
	li a2, 28		# numero da coluna 
	li a3, 185		# numero da linha
	call CALCULAR_ENDERECO	

	mv t5, a0		# move o retorno para a1

	# Antes limpa a caixa de dialogo no frame 1
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		mv a1, t5		# t5 tem o endereço de onde começar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR

	# Por fim, imprime uma pequena seta indicando que o jogador pode apertar ENTER para avançar
	# o dialogo						
		# Calculando o endereço de onde imprimir a seta no frame 1
		li a1, 0xFF100000	# seleciona o frame 1
		li a2, 159		# numero da coluna 
		li a3, 207		# numero da linha
		call CALCULAR_ENDERECO											

		mv a1, a0		# move o retorno para a1		
									
		# Imprimindo a imagem da seta no frame 0
		la a0, seta_proximo_dialogo_combate		# carrega a imagem				
		# a1 já tem o endereço de onde imprimir a imagem
		lw a2, 0(a0)		# numero de colunas da imagem
		lw a3, 4(a0)		# numero de linhas da imagem
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
						
	# Imprime o texto ('...')
	mv a1, t5		# t5 tem o endereço de onde imprimir o texto
	la a4, matriz_texto_tres_pontos
	call PRINT_TEXTO
	
	mv t2, a1		# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o tile,
				# de modo que está na posição exata do proximo texto
			
	call TROCAR_FRAME	# inverte o frame, mostrando o frame 1	

	# Replica a caixa de dialogo do frame 1 no frame 0 para que os dois estejam iguais
	mv a0, t5		# t5 tem o endereço da caixa no frame 1
	li t0, 0x00100000
	sub a1, t5, t0		# a1 recebe o endereço de t5 no frame 0			
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME	

	call TROCAR_FRAME	# inverte o frame, mostrando o frame 0	
													
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_ACAO_ITEM_TRES_PONTOS:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 é o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_ACAO_ITEM_TRES_PONTOS
										
	# Escolhe um numero randomico de 0 a 2, se o numero for 0 então a captura nao foi bem sucedida
	li a0, 2
	call ENCONTRAR_NUMERO_RANDOMICO
		
	bne a0, zero, CAPTURA_FUNCIONOU

	# -------------------------------------------------------

	# A captura falhou se a0 == 0

	# Imprime o texto com o ' a captura falhou' no frame 1
	mv a1, t2	# pelo PRINT_TEXTO anterior t2 ainda tem salvo o endereço onde o ultimo tile
			# foi impresso, de modo que está na posição exata do proximo texto
	la a4, matriz_texto_a_captura_falhou
	call PRINT_TEXTO	
			
	# Decrementa o numero de pokebolas 
	la t0, NUMERO_DE_POKEBOLAS
	lb t1, 0(t0)
	addi t1, t1, -1
	sb t1, 0(t0)	
	
	call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
	
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_FIM_CAPTURA_DE_POKEMON:
		call VERIFICAR_TECLA
	
		li t0, 10		# 10 é o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_FIM_CAPTURA_DE_POKEMON	
			
	# Replica a caixa de dialogo do frame 1 no frame 0 para que os dois estejam iguais	
	mv a0, t5		# t5 tem o endereço da caixa no frame 1
	li t0, 0x00100000
	sub a1, t5, t0		# a1 recebe o endereço de t5 no frame 0		
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME		

	call TROCAR_FRAME	# inverte o frame, mostrando o frame 0

	# é necessario reimprimir o sprite do pokemon inimigo
	# Primeiro encontra a imagem do pokemon inimigo
	
	# Imprimindo novamente os tiles para limpar a imagem da pokebola
		# Calculando o endereço de onde imprimir os tiles
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 192		# numero da coluna 
		li a3, 32		# numero da linha
		call CALCULAR_ENDERECO	
		
		mv a2, a0		# move o retorno para t6
	
		# Agora novamente no frame 0 os tiles onde o pokemon está
		la a0, matriz_tiles_combate_limpar_pokemon	# carrega a matriz de tiles
		la a1, tiles_combate_e_inventario	# carrega a imagem com os tiles
		# a2 já tem o endereço onde os tile serão impressos
		call PRINT_TILES
		
	andi t0, s11, 7		# faz o andi com 7 para deixar somente os bits que fazem parte do tipo
				# do pokemon inimigo intactos
	addi t0, t0, -1		# -1 porque o tipo do pokemon começa em 1
							
	la t1, pokemons			# t1 tem o inicio da imagem do BULBASAUR
	addi t1, t1, 8			# pula para onde começa os pixels no .data	
	li t2, 1482			# 1482 = 38 * 39 = tamanho de uma imagem de um pokemon, ou seja,
	mul t2, t2, t0			# passa o endereço de t1 para a imagem do pokemon 
	add t3, t1, t2			# correto de acordo com t0
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																							
	# Imprime a imagem do pokemon aparecendo da tela no frame 0
		# Calculando o endereço de onde imprimir o pokemon 
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 204		# numero da coluna 
		li a3, 43		# numero da linha					
		call CALCULAR_ENDERECO			
	
		mv t4, a0		# move o retorno para a1
		
		# Imprime a silhueta do pokemon	no frame 0
		mv a0, t3	# t3 tem a imagem do pokemon que foi decidido no inicio procedimento				
		mv a1, t4	# t4 tem o endereço de onde imprimir a imagem
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		li a4, 0	# a silhueta será impressa na orientação normal		
		call PRINT_POKEMON_SILHUETA
		
		# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		# Imprime a imagem completa do pokemon no frame 0
		mv a0, t3	# t3 ainda tem a imagem do pokemon que foi decidido no inicio procedimento				
		mv a1, t4	# t4 tem o endereço de onde imprimir a imagem
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		call PRINT_IMG
		
		# Replica o frame 0 no frame 1 para que os dois estejam iguais
		mv a0, t4		# t4 tem o endereço de onde o pokemon foi impresso no frame 0
		li t0, 0x00100000
		add a1, t4, t0		# a1 recebe o endereço de t4 no frame 1			
		li a2, 60		# numero de colunas a serem copiadas
		li a3, 56		# numero de linhas a serem copiadas
		call REPLICAR_FRAME
				
	li t3, 0		# t3 recebe 0 para indicar que o combate deve continuar	
			
	j FIM_ACAO_ITEM	
	
	# -------------------------------------------------------
	
	CAPTURA_FUNCIONOU:		
	
	# A captura falhou se a0 != 0

	# Imprime o texto com o ' a captura funcionou!' no frame 1
	mv a1, t2	# pelo PRINT_TEXTO anterior t2 ainda tem salvo o endereço onde o ultimo tile
			# foi impresso, de modo que está na posição exata do proximo texto
	la a4, matriz_texto_a_captura_funcionou
	call PRINT_TEXTO

	# Armazena o pokemon captura na primeira posicao livre do inventario
	li t0, 4095	
	and t0, s11, t0		# faz com o andi com t0 de modo que t0 tem somente os bits que fazem parte
				# do codigo do pokemon inimigo em s11 intactos
				
	la t1, POKEMONS_DO_RED
	li t2, 5	# numero de posições a serem verificadas
		
	ACAO_ITEM_LOOP_ARMAZENAR_POKEMON:
		lw t3, 0(t1)
		beq t3, zero, ACAO_ITEM_ARMAZENAR_POKEMON
		addi t2, t2, -1		# decrementa o numero de posições restantes
		addi t1, t1, 4		# proxima posicao do inventario
		bne t2, zero, ACAO_ITEM_LOOP_ARMAZENAR_POKEMON
	
	ACAO_ITEM_ARMAZENAR_POKEMON:
	sw t0, 0(t1) 		# armazena o codigo do pokemon captura no inventario

	call TROCAR_FRAME 		# inverte o frame, mostrando o frame 1
	
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_FIM_CAPTURA_FUNCIONOU:
		call VERIFICAR_TECLA
	
		li t0, 10		# 10 é o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_FIM_CAPTURA_FUNCIONOU	
			
	# Agora imprime a mensagem de vitoria no frame 0
		# Primeiro limpa a caixa de dialogo	
		# Calculando o endereço de onde começar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv a1, a0		# move o retorno para t5

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		# a1 já tem o endereço de onde começar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR	
		
		# Imprimindo o texto de vitoria
		# Calculando o endereço de onde imprimir o texto no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 75		# numero da coluna 
		li a3, 193		# numero da linha
		call CALCULAR_ENDERECO	
			
		mv a1, a0		# move o retorno para a1
		# Imprime o texto com a mensagem
		# a1 já tem o endereço de onde imprimir o texto
		la a4, matriz_texto_vitoria 	
		call PRINT_TEXTO
			
	call TROCAR_FRAME		# inverte o frame, mostrando o frame 0	
	
	# Replica a caixa de dialogo do frame 0 no frame 1 para que os dois estejam iguais	
		# Calculando o endereço de onde começar a copia no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	
	
		# a0 já tem o endereço da caixa no frame 0
		li t0, 0x00100000
		add a1, a0, t0		# a1 recebe o endereço de a0 no frame 0		
		li a2, 264		# numero de colunas a serem copiadas
		li a3, 32		# numero de linhas a serem copiadas
		call REPLICAR_FRAME		
			
		# Espera alguns milisegundos	
		li a0, 4500			# sleep 4,5 s
		call SLEEP			# chama o procedimento SLEEP	

	# Decrementa o numero de pokebolas 
	la t0, NUMERO_DE_POKEBOLAS
	lb t1, 0(t0)
	addi t1, t1, -1
	sb t1, 0(t0)	
																																																																																																																																																																																																																																																																																																																																																																																	
	li t3, 1		# t3 recebe 1 para indicar que o combate não deve continuar
	
	call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
	
			
	# Replica a caixa de dialogo do frame 1 no frame 0 para que os dois estejam iguais	
	mv a0, t5		# t5 tem o endereço da caixa no frame 1
	li t0, 0x00100000
	sub a1, t5, t0		# a1 recebe o endereço de t5 no frame 0		
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME
		
	call TROCAR_FRAME	# inverte o frame, mostrando o frame 0	
														
	# -------------------------------------------------------
							
	FIM_ACAO_ITEM:

	mv a0, t3	# t3 tem o valor do retorno decidido acima
											
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret		
						
# ------------------------------------------------------------------------------------------------------ #

PRINT_MENSAGEM_INICIAL_DE_ACAO:
	# As ações ATACAR, DEFENDER e FUGIR tem um mesmo inicio, que é imprimir uma pequena mensagem 
	# indicando o que o pokemon vai fazer
	# O procedimento termina no frame 0 com a mensagem na tela, enquanto a caixa de dialogo no frame 1
	# está limpa, porém deixando a seta de proximo dialogo
	# 
	# Argumentos:
	#	a4 = matriz de texto com o nome do pokemon
	#	a5 = matriz de texto com a descição do que o pokemon vai fazer
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Primeiro limpa a caixa de dialogo no frame 1	
	# Calculando o endereço de onde começar a limpeza no frame 1
	li a1, 0xFF100000	# seleciona o frame 1
	li a2, 28		# numero da coluna 
	li a3, 185		# numero da linha
	call CALCULAR_ENDERECO	

	mv t5, a0		# move o retorno para t5

	# Imprimindo o rentangulo com a cor de fundo da caixa no frame 1
	li a0, 0xFF		# a0 tem o valor do fundo da caixa
	mv a1, t5		# t5 tem o endereço de onde começar a impressao		
	li a2, 147		# numero de colunas da imagem da seta
	li a3, 30		# numero de linhas da imagem da seta			
	call PRINT_COR	
		
	# Agora imprime o texto com o nome do pokemon do RED		
	# Calculando o endereço de onde imprimir o primeiro texto no frame 1
	li a1, 0xFF100000	# seleciona o frame 1
	li a2, 28		# numero da coluna 
	li a3, 185		# numero da linha
	call CALCULAR_ENDERECO	
			
	mv a1, a0		# move o retorno para a1

	# Imprime o texto com o nome do Pokemon
	# a1 já tem o endereço de onde imprimir o texto
	# a4 já tem a matriz de texto do nome do pokemon
	call PRINT_TEXTO

	# Imprime o texto em a5
	# pelo PRINT_TEXTO acima a1 ainda está no ultimo endereço onde imprimiu o tile,
	# de modo que está na posição exata do proximo texto
	mv a4, a5
	call PRINT_TEXTO			

	# Por fim, imprime uma pequena seta indicando que o jogador pode apertar ENTER para avançar
	# o dialogo						
	# Calculando o endereço de onde imprimir a seta no frame 1
	li a1, 0xFF100000	# seleciona o frame 0
	li a2, 159		# numero da coluna 
	li a3, 207		# numero da linha
	call CALCULAR_ENDERECO											

	mv a1, a0		# move o retorno para a1		
									
	# Imprimindo a imagem da seta no frame 0
	la a0, seta_proximo_dialogo_combate		# carrega a imagem				
	# a1 já tem o endereço de onde imprimir a imagem
	lw a2, 0(a0)		# numero de colunas da imagem
	lw a3, 4(a0)		# numero de linhas da imagem
	addi a0, a0, 8		# pula para onde começa os pixels no .data	
	call PRINT_IMG	
		
	call TROCAR_FRAME	# inverte o frame, mostrando o frame 1		

	# Replica a caixa de dialogo do frame 1 no frame 0 para que os dois estejam iguais	
	mv a0, t5		# t5 tem o endereço da caixa no frame 1
	li t0, 0x00100000
	sub a1, t5, t0		# a1 recebe o endereço de t5 no frame 0	
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME
	
	call TROCAR_FRAME	# inverte o frame, mostrando o frame 0	
															
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_MENSAGEM_INICIAL_DE_ACAO:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 é o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_MENSAGEM_INICIAL_DE_ACAO
							
	# Imprimindo o rentangulo com a cor de fundo da caixa no frame 1 para a limpeza (deixa a seta impressa)
	li a0, 0xFF		# a0 tem o valor do fundo da caixa
	mv a1, t5		# t5 ainda tem o endereço de onde começar a impressao		
	li a2, 147		# numero de colunas da imagem da seta
	li a3, 15		# numero de linhas da imagem da seta			
	call PRINT_COR			
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	
																																																																																																																																			
# ====================================================================================================== #

TURNO_COMPUTADOR:
	# Procedimento que coordena o turno do computador, fazendo chamadas aos procedimentos de ação 
	# (atacar ou defender) de acordo com um numero randomico
	#
	# Retorno:
	# 	a0 = [ 0 ] se o combate deve continuar
	#	     [ 1 ] se o computador ganhou

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	li a6, 1		# a6 == 1 porque quem está atacando é o computador																																																																									
	call ACAO_ATACAR
	# como retorno a0 == 0 se o combate deve continuar e 1 caso o computador tenha vencido
	# esse retorno será propagado para EXECUTAR_COMBATE
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																							
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret		
																																																																																																																																					
# ====================================================================================================== #

RENDERIZAR_MENU_DE_COMBATE:
	# Procedimento que torna o menu de combate responsivo aos controles do jogador. Quando chamado o 
	# procedimento vai imprimir uma seta que pode ser movida pelo jogador entre as 4 opções do menu,
	# e com ENTER essa opeção pode ser selecionada.
	#
	# Retorno:
	#	a0 = número de 0 a 3 representado a opção que o jogador selecionou, onde
	#		[ 0 ] -> ATACAR 
	#		[ 1 ] -> FUGIR
	#		[ 2 ] -> DEFESA  
	#		[ 3 ] -> ITEM  			  

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	li t4, 0		# o menu começa com a primeira opção selecionada (ATACAR)
	
	LOOP_SELECIONAR_OPCAO_MENU_DE_COMBATE:
		# Primeiro imprime uma imagem de uma seta indicando a opção selecionada		
	   		# Calculando o endereço de onde a seta será impressa
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 187		# numero da coluna onde a seta da primeira opção está
			li a3, 185		# numero da linha onde a seta da primeira opção está	
			
			# O numero da coluna e linha onde a seta será impressa é dependente da opção selecionada
			li t0, 1
			beq t4, t0, COMBATE_SETA_OPCOES_1_3
			li t0, 3
			beq t4, t0, COMBATE_SETA_OPCOES_1_3
			j COMBATE_SETA_CHECAR_OPCAO_2_3
			
			COMBATE_SETA_OPCOES_1_3:
			# Caso a opção selecionada for a 1 ou 3 então a coluna é movida por +60 pixels		
			addi a2, a2, 60
			
			COMBATE_SETA_CHECAR_OPCAO_2_3: 
			li t0, 2
			blt t4, t0, COMBATE_SETA_CALCULAR_ENDEREÇO
			
			# Caso a opção selecionada for a 2 ou 3 então a linha é movida por +17											
			addi a3, a3, 17
			
			COMBATE_SETA_CALCULAR_ENDEREÇO:
			call CALCULAR_ENDERECO		
				
			mv t3, a0		# move o retorno para t3
			
			# Imprimindo a seta		
			la a0, tiles_alfabeto	
			addi a0, a0, 8		# pula para onde começa os pixels no .data
			li t0, 6720		# a imagem dessa seta pode ser encontrada em tiles_alfabeto
			add a0, a0, t0		# a 6720 (8 (tamanho de uma linha da imagem) * 840 (numero da 
						# linha onde esse tile começa)) pixels de distancia do começo
			mv a1, t3		# t3 tem o endereço de onde imprimir a seta
			li a2, 8		# numero de colunas da imagem 
			li a3, 15		# numero de linhas da imagem 	
			call PRINT_IMG	
		
		# Agora seleciona a opção mudando os pixels do texto da opção por pixels azuis
			# Via de regra o endereço de onde o texto está sempre fica a 9 colunas e 2 linhas 
			# de distancia da seta
			
			addi t5, t3, 649	# t5 recebe o endereço de onde o texto está a partir do 
						# endereço da seta (t3)
						# 649 = (320 * 2 linhas) + 9 colunas
			
			# Selecionado a opção
			li a0, 0		# a0 == 0 -> selecionar a opção
			mv a1, t5		# t5 tem o endereço de onde o texto está
			li a2, 9		# numero de linhas de pixels do texto
			li a3, 41		# numero de colunas de pixels do texto
			call SELECIONAR_OPCAO_MENU
	
		LOOP_SELECIONAR_OPCAO_COMBATE:
		
		# Agora é incrementado ou decrementado o valor de t4 de acordo com o input do jogador
		call VERIFICAR_TECLA
		
		li t0, 'w'
		beq a0, t0, OPCAO_W_COMBATE
		
		li t0, 'a'
		beq a0, t0, OPCAO_A_COMBATE
		
		li t0, 's'
		beq a0, t0, OPCAO_S_COMBATE
		
		li t0, 'd'
		beq a0, t0, OPCAO_D_COMBATE	
		
		# Se o jogador apertar ENTER ele quer selecionar essa opção
		li t0, 10		# 10 é o codigo do ENTER
		beq a0, t0, FIM_RENDERIZAR_MENU_DE_COMBATE																					
		
		j LOOP_SELECIONAR_OPCAO_COMBATE				
																				
		OPCAO_W_COMBATE:
		# se a opção atual for 0 ou 1 então não é possivel subir mais no menu
		li t0, 1
		ble t4, t0, LOOP_SELECIONAR_OPCAO_COMBATE
		addi t4, t4, -2			# passa t4 para a opção acima 
		j OPCAO_TROCADA_COMBATE	
		
		OPCAO_A_COMBATE:
		# se a opção atual for 0 ou 2 então não é possivel ir mais para a esquerda no menu
		beq t4, zero, LOOP_SELECIONAR_OPCAO_COMBATE		
		li t0, 2
		beq t4, t0, LOOP_SELECIONAR_OPCAO_COMBATE
		addi t4, t4, -1			# passa t4 para a opção a esquerda 
		j OPCAO_TROCADA_COMBATE
		
		OPCAO_S_COMBATE:
		# se a opção atual for 2 ou 3 então não é possivel descer mais no menu
		li t0, 2
		beq t4, t0, LOOP_SELECIONAR_OPCAO_COMBATE		
		li t0, 3
		beq t4, t0, LOOP_SELECIONAR_OPCAO_COMBATE
		addi t4, t4, 2			# passa t4 para a opção abaixo 
		j OPCAO_TROCADA_COMBATE
				
		OPCAO_D_COMBATE:
		# se a opção atual for 1 ou 3 então não é possivel ir mais para a direita no menu
		li t0, 1
		beq t4, t0, LOOP_SELECIONAR_OPCAO_COMBATE		
		li t0, 3
		beq t4, t0, LOOP_SELECIONAR_OPCAO_COMBATE
		addi t4, t4, 1			# passa t4 para a opção a direita

		OPCAO_TROCADA_COMBATE:
		# Se ocorreu uma troca de opção é necessário retirar a seleção da opção atual e limpar a tela
			# Retirando a seleção da opção
			li a0, 1		# a0 == 1 -> retirar seleção
			mv a1, t5		# t5 ainda tem o endereço de onde o texto da ultima opção
						# selecionada está
			li a2, 9		# numero de linhas de pixels do texto
			li a3, 41		# numero de colunas de pixels do texto
			call SELECIONAR_OPCAO_MENU
			
			# Para retirar a imagem da seta basta imprimir uma área de mesmo tamanho com a cor
			# de fundo do menu
			li a0, 0xFF		# a0 tem o valor do fundo do menu
			addi a1, t5, -9		# volta o endereço de t5 por 9 colunas de modo que a1
						# agora tem o endereço de onde a seta está e onde a limpeza
						# vai acontecer			
			li a2, 6		# numero de colunas da imagem da seta
			li a3, 11		# numero de linhas da imagem da seta			
			call PRINT_COR
					
			j LOOP_SELECIONAR_OPCAO_MENU_DE_COMBATE

	FIM_RENDERIZAR_MENU_DE_COMBATE:

	mv a0, t4		# como retorno move para a0 o valor da opção selecioanada

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #

RENDERIZAR_POKEMON:
	# Procedimento auxiliar a INICIAR_POKEMON_INIMIGO e INICIAR_POKEMON_RED que tem como objetivo
	# renderizar o sprite de um pokemon, o seu nome e sua barra de vida na tela de combate.
	# Dependendo do argumento a5 os elementos vão ser impressos em posições diferentes na tela.
	#
	# Argumento:
	#	a0 = número de 0 a 4 representando o pokemon a ser renderizado. 
	#	     [ 0 ] -> BULBASAUR
	#	     [ 1 ] -> CHARMANDER
	#	     [ 2 ] -> SQUIRTLE
	#	     [ 3 ] -> CATERPIE
	#	     [ 4 ] -> DIGLETT
	#	a5 = [ 0 ] -> renderiza o pokémon inimigo
	#	     [ 1 ] -> renderiza o pokémon do RED	
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Primeiro encontra a partir de a0 o endereço da imagem do pokemon (t5) e a matriz de texto com
	# o nome do pokemon (t6)
	
	la t5, pokemons			# t5 tem o inicio da imagem do BULBASAUR
	addi t5, t5, 8			# pula para onde começa os pixels no .data	
	li t0, 1482			# 1482 = 38 * 39 = tamanho de uma imagem de um pokemon, ou seja,
	mul t0, t0, a0			# passa o endereço de t5 para a imagem do pokemon correto de acordo com a0
	add t5, t5, t0

	# se a0 == 0 então é pokemon inimigo será o BULBASAUR 
	la t6, matriz_texto_bulbasaur		# carrega a matriz de texto do pokemon
	beq a0, zero, PRINT_POKEMON
			
	# se a0 == 1 então é pokemon inimigo será o CHARMANDER 
	li t0, 1	
	la t6, matriz_texto_charmander		# carrega a matriz de texto do pokemon	
	beq a0, t0, PRINT_POKEMON
			
	# se a0 == 2 então é pokemon inimigo será o SQUIRTLE 
	li t0, 2	
	la t6, matriz_texto_squirtle		# carrega a matriz de texto do pokemon				
	beq a0, t0, PRINT_POKEMON
										
	# se a0 == 3 então é pokemon inimigo será o CATERPIE 
	li t0, 3	
	la t6, matriz_texto_caterpie		# carrega a matriz de texto do pokemon			
	beq a0, t0, PRINT_POKEMON
	
	# se a0 == 4 então é pokemon inimigo será o DIGLETT 
	li t0, 4	
	la t6, matriz_texto_diglett		# carrega a matriz de texto do pokemon	
	
	PRINT_POKEMON:
																																																																																																																																																																																																	
	# Imprime a imagem do pokemon aparecendo na tela no frame 0	
		# Calculando o endereço de onde imprimir o pokemon dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde o pokemon inimigo deve ser impresso
		li a2, 204		# numero da coluna 
		li a3, 43		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_SPRITE
		
		# Onde o pokemon do RED deve ser impresso
		li a2, 76		# numero da coluna 
		li a3, 107		# numero da linha
				
		RENDERIZAR_POKEMON_PRINT_SPRITE:
		
		call CALCULAR_ENDERECO	
		
		mv t3, a0		# move o retorno para t3
		
		# Imprime a silhueta do pokemon		
		mv a0, t5	# t5 ainda tem a imagem do pokemon que foi decidido no inicio procedimento				
		mv a1, t3	# t3 tem o endereço de onde imprimir a imagem
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		mv a4, a5	# a5 já tem o numero correto indicando se a silheta é invertida ou não
		call PRINT_POKEMON_SILHUETA
	
		# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		# Imprime a imagem completa do pokemon no frame 0
		mv a0, t5	# t5 ainda tem a imagem do pokemon que foi decidido no inicio procedimento				
		mv a1, t3	# t3 tem o endereço de onde imprimir a imagem no frame 0
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		
		# decide de acordo com a5 se o pokemon deve ser impresso de forma invertida ou não
		bne a5, zero, PRINT_POKEMON_INVERTIDO
				
		call PRINT_IMG
		
		# Imprime a imagem completa do pokemon no frame 1
		mv a0, t5	# t5 ainda tem a imagem do pokemon que foi decidido no inicio procedimento				
		mv a1, t3	# t3 tem o endereço de onde imprimir a imagem no frame 0
		li t0, 0x00100000
		add a1, a1, t0		# passa o endereço de a1 para o frame 1
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		call PRINT_IMG
		
		j PRINT_INFORMACOES_DO_POKEMON
		
		PRINT_POKEMON_INVERTIDO:
				
		call PRINT_IMG_INVERTIDA
		
		# Imprime a imagem completa do pokemon no frame 1
		mv a0, t5	# t5 ainda tem a imagem do pokemon que foi decidido no inicio procedimento				
		mv a1, t3	# t3 tem o endereço de onde imprimir a imagem no frame 0
		li t0, 0x00100000
		add a1, a1, t0		# passa o endereço de a1 para o frame 1
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		call PRINT_IMG_INVERTIDA
			
	PRINT_INFORMACOES_DO_POKEMON:

	call TROCAR_FRAME 		# inverte o frame, mostrando o frame 1
																																			
	# Imprime a imagem da caixa com as informações do pokemon (nome, vida, etc) no frame 0
		# Calculando o endereço de onde imprimir a caixa dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
					
		# Onde imprimir a caixa do pokemon inimigo			
		li a2, 32		# numero da coluna 
		li a3, 32		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_CAIXA
				
		# Onde imprimir a caixa do pokemon do RED			
		li a2, 176		# numero da coluna 
		li a3, 112		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_CAIXA:
				
		call CALCULAR_ENDERECO	
		
		mv a2, a0		# move o retorno para a2
		
		# Imprime a caixa do pokemon
		la a0, matriz_tiles_caixa_pokemon_combate	# carrega a matriz de tiles
		la a1, tiles_caixa_pokemon_combate		# carrega a imagem com os tiles
		# a2 já tem o endereço de onde imprimir os tiles
		call PRINT_TILES
	
		# Imprime uma pequena seta indicando a orientação dessa caixa 
		# Calculando o endereço de onde imprimir a seta e a imagem da seta dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
					
		# Onde imprimir a seta da caixa do pokemon inimigo			
		li a2, 154		# numero da coluna 
		li a3, 55		# numero da linha
		la t2, seta_direcao_caixa_pokemon_combate	# carrega a imagem
		addi t2, t2, 8					# pula para onde começa os pixels no .data		
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_SETA_DE_CAIXA
				
		# Onde imprimir a seta da caixa do pokemon do RED
		addi t2, t2, 135	# passa o endereço de t2 para a proxima seta na imagem			
		li a2, 167		# numero da coluna 
		li a3, 135		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_SETA_DE_CAIXA:
				
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o retorno para a1
		
		# Imprime a seta 
		mv a0, t2	# t2 tem a imagem da seta correta		
		# a1 já tem o endereço de onde imprimir a imagem
		li a2, 15	# numero de colunas da imagem
		li a3, 9	# numero de linhas da imagem
		call PRINT_IMG

		# Imprime o nome do pokemon na caixa
		# Calculando o endereço de onde imprimir o nome na caixa dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
					
		# Onde imprimir o nome do pokemon inimigo			
		li a2, 37		# numero da coluna 
		li a3, 35		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_NOME
				
		# Onde imprimir o nome do pokemon do RED
		li a2, 181		# numero da coluna 
		li a3, 115		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_NOME:
		
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o retorno para a1
		
		# Imprime o texto com o nome do Pokemon
		# a1 tem o endereço de onde imprimir o nome
		mv a4, t6	# a4 recebe a matriz de texto do pokemon decidido anteriormente no procedimento	
		call PRINT_TEXTO							

		# Imprime a barra de vida
		# Calculando o endereço de onde imprimir a barra dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde imprimir a barra do pokemon inimigo			
		li a2, 48		# numero da coluna 
		li a3, 50		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_BARRA_DE_VIDA
						
		# Onde imprimir a barra do pokemon do RED
		li a2, 192		# numero da coluna 
		li a3, 130		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_BARRA_DE_VIDA:		
		
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o retorno para a1
		
		# Imprime a imagem da barra de vida
		la a0, combate_barra_de_vida	# carrega a imagem
		# a1 já tem o endereço de onde imprimir a imagem
		lw a2, 0(a0)	# numero de colunas da imagem
		lw a3, 4(a0)	# numero de linhas da imagem
		addi a0, a0, 8			# pula para onde começa os pixels no .data								
		call PRINT_IMG		
		
		# Imprime a vida do pokemon
		# Todos os pokemons tem uma vida de 45 pontos
		
		# Calculando o endereço de onde imprimir a vida dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde imprimir a vida do pokemon inimigo			
		li a2, 122		# numero da coluna 
		li a3, 37		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_PONTOS_DE_VIDA
						
		# Onde imprimir a vida do pokemon do RED
		li a2, 266		# numero da coluna 
		li a3, 117		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_PONTOS_DE_VIDA:			
		
		call CALCULAR_ENDERECO			
		
		mv a1, a0		# move o retorno para a1 
		li a0, 45		# 45 pontos de vida
		call PRINT_NUMERO
		
		# Imprime o caractere barra (/)
		la a0, caractere_barra	
		addi a0, a0, 8		# pula para onde começa os pixels no .data		
		# do PRINT_NUMERO acima a1 está naturalmente a -10 linhas +7 colunas de onde imprimir o proximo
		# numero
		li t0, -3193		# -3193 = -10 * 320 + 7
		add a1, a1, t0
		li a2, 6		# numero de colunas dos tiles a serem impressos
		li a3, 10		# numero de linhas dos tiles a serem impressos	
		call PRINT_IMG	
				
		# Imprime novemente os pontos de vida (45)
		li a0, 45		# 45 pontos de vida		
		# do PRINT_IMG acima a1 está naturalmente a -10 linhas +7 colunas de onde imprimir o proximo
		# numero
		li t0, -3193		# -3193 = -10 * 320 + 7
		add a1, a1, t0	
		call PRINT_NUMERO


	call TROCAR_FRAME 		# inverte o frame, mostrando o frame 0

	# Replica o frame 0 no frame 1 para que os dois estejam iguais
	li a0, 0xFF000000	# copia o frame 0 no frame 1
	li a1, 0xFF100000
	li a2, 320		# numero de colunas a serem copiadas
	li a3, 240		# numero de linhas a serem copiadas
	call REPLICAR_FRAME
	
	# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	
	
# ====================================================================================================== #

RENDERIZAR_ATAQUE_EFEITO:
	# Procedimento renderizar o sprite de ataque e realiza uma pequena animação mostrando um 
	# pokemon levando dano
	# Dependendo do argumento a5 os elementos vão ser impressos em posições diferentes na tela.
	#
	# Argumento:
	#	a5 = [ 0 ] -> renderiza o ataque no pokémon inimigo
	#	     [ 1 ] -> renderiza o ataque no pokémon do RED	
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
																																						
 	# Imprime a imagem do efeito de ataque no frame 0	
		# Calculando o endereço de onde imprimir a imagem dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde o efeito no pokemon inimigo deve ser impresso
		li a2, 208		# numero da coluna 
		li a3, 47		# numero da linha
		beq a5, zero, ACAO_ATAQUE_PRINT_EFEITO
		
		# Onde o efeito no pokemon do RED deve ser impresso
		li a2, 79		# numero da coluna 
		li a3, 111		# numero da linha
				
		ACAO_ATAQUE_PRINT_EFEITO:
		
		call CALCULAR_ENDERECO	
		
		mv t3, a0		# move o retorno para t3
		
		# Imprime o efeito de ataque
		la a0, efeito_de_ataque		# carrega a imagem			
		mv a1, t3		# t3 tem o endereço de onde imprimir a imagem
		lw a2, 0(a0)		# numero de colunas da imagem 
		lw a3, 4(a0)		# numero de linhas daa imagem 	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
	
	# Espera alguns milisegundos	
		li a0, 600			# sleep 600 ms
		call SLEEP			# chama o procedimento SLEEP	

	# Agora replica a imagem do pokemon que está no frame 1 para o frame 0 para que os dois estejam iguais
	# limpando o efeito de ataque no processo
		# Calculando o endereço de onde começar a replica dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde a replica começa no pokemon inimigo
		li a2, 208		# numero da coluna 
		li a3, 47		# numero da linha
		beq a5, zero, ACAO_ATAQUE_REPLICAR_EFEITO
		
		# Onde a replica começa no pokemon do RED
		li a2, 76		# numero da coluna 
		li a3, 111		# numero da linha
		
		ACAO_ATAQUE_REPLICAR_EFEITO:
		
		call CALCULAR_ENDERECO
		mv t3, a0		# move o retorno para t3	
			
	li t0, 0x00100000
	add a0, t3, t0		# a1 recebe o endereço de t3 no frame 1								
	mv a1, t3		# t3 tem o endereço de onde o efeito foi impresso no frame 0
	li a2, 40		# numero de colunas a serem copiadas
	li a3, 40		# numero de linhas a serem copiadas
	call REPLICAR_FRAME
	
	# Por fim, para emular um efeito de dano o pokemon deve ficar piscando
	# Para isso o pokemon será retirado do frame 1, o que pode ser feito imprimindo novamente os
	# tiles onde ele está
		# Calculando o endereço de onde imprimir os tiles dependendo de a5
		li a1, 0xFF100000	# seleciona o frame 1
		
		# Onde os tiles dever ser impressos no pokemon inimigo
		li a2, 192		# numero da coluna 
		li a3, 32		# numero da linha
		beq a5, zero, ACAO_ATAQUE_PRINT_TILES
		
		# Onde os tiles dever ser impressos no pokemon do RED
		li a2, 64		# numero da coluna 
		li a3, 96		# numero da linha
						
		ACAO_ATAQUE_PRINT_TILES:					
	
		call CALCULAR_ENDERECO	
		
		mv t6, a0		# move o retorno para t6
				
		# Agora novamente no frame 1 os tiles onde o pokemon 
		la a0, matriz_tiles_combate_limpar_pokemon	# carrega a matriz de tiles
		la a1, tiles_combate_e_inventario	# carrega a imagem com os tiles
		mv a2, t6				# t6 tem o endereço onde os tile serão impressos
		call PRINT_TILES

	# Agora troca os frame algumas vezes para que o pokemon fique piscando
	li t2, 10		# numero de loops a serem feitos
	
	ACAO_ATAQUE_LOOP_TROCAR_FRAMES: 
		# Espera alguns milisegundos	
			li a0, 130			# sleep 50 ms
			call SLEEP			# chama o procedimento SLEEP	
		
			call TROCAR_FRAME		# inverte o frame sendo mostrado
			
		addi t2, t2, -1			# decrementa o numero de loops restantes
		bne t2, zero, ACAO_ATAQUE_LOOP_TROCAR_FRAMES
		
	# Replica a imagem do pokemon que está no frame 0 para o frame 1 para que os dois estejam iguais
	# imprimindo novamente o pokemon que foi retirado para o loop acima
	li t0, 0x00100000
	sub a0, t6, t0		# a0 recebe o endereço de t6 no frame 0							
	mv a1, t6		# t6 tem o endereço de onde os tile foram impressos acima
	li a2, 64		# numero de colunas a serem copiadas
	li a3, 64		# numero de linhas a serem copiadas
	call REPLICAR_FRAME
																																																																																																
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #

RENDERIZAR_ATAQUE_DANO:
	# Procedimento que renderiza um efeito de dano na barra de vida de um pokemon. Por efeito de dano
	# entende-se trocar a porção da barra de vida que corresponde ao dano recebido por pixels vermelhos
	#
	# Argumento:
	#	a4 = numero indicando o dano a ser aplicado no pokemon
	#	a5 = [ 0 ] -> o dano foi aplicado ao pokémon inimigo
	#	     [ 1 ] -> o dano foi aplicado ao pokémon do RED
		
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	mv t3, a4		# salva a4 em t3

	# Verifica a vida do pokemon
	mv a4, a5 		# a5 tem o numero indicando qual pokemon verificar
	call VERIFICAR_VIDA_POKEMON
	# do retorno a0 tem endereço final onde o restante da vida do pokemon está na barra de vida
	slli t0, a1, 1		# multiplica a vida do pokemon por 2 porque cada ponto de vida ocupa 2 pixels 
	
	mv a4, t3		# volta o valor de a4
	
	slli a4, a4, 1		# é necessario multiplicar o dano a ser aplicado por 2 porque 1 ponto de vida
				# ocupa 2 pixels na barra de vida
	# se a4 == 0 nada precisa ser feito
	beq a4, zero, FIM_RENDERIZAR_ATAQUE_DANO
	
	sub t1, t0, a4		# t0 (vida atual) - a4 (dano feito) = vida restante
	bge t1, zero, RENDERIZAR_DANO_PRINT_DANO
	# se a vida restante for < 0 então no maximo o dano de a4 será a vida atual (t0)
		mv a4, t0
	
	RENDERIZAR_DANO_PRINT_DANO:
	
	sub t2, a0, a4		# do procedimento acima a0 está no final da barra de vida restante do pokemon
	
	# Agora é necessario pintar essa porção da barra de vida com a cor vermelha para representar o dano
		li a0, 87		# a0 tem a cor vermelha do dano
		mv a1, t2		# t2 tem o endereço de onde começar a imprimir a cor	
		mv a2, a4		# a4 tem o dano aplicado * 2 qure representa o 
					# numero de colunas da barra de vida a serem pintadas
		li a3, 3		# numero de linhas da barra de vida		
		call PRINT_COR	
	
		# Pintando a barra também no frame 1
		li a0, 87		# a0 tem a cor vermelha do dano
		mv a1, t2		# t2 tem o endereço de onde começar a imprimir a cor	
		li t0, 0x00100000
		add a1, a1, t0		# passa o endereço de t2 para o frame 1
		mv a2, a4		# a4 tem o dano aplicado * 2 qure representa o 
					# numero de colunas da barra de vida a serem pintadas
		li a3, 3		# numero de linhas da barra de vida		
		call PRINT_COR		

	FIM_RENDERIZAR_ATAQUE_DANO:
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	
						
# ====================================================================================================== #

ATUALIZAR_BARRA_DE_VIDA:
	# Procedimento que atualiza a barra de vida de um pokemon, imprimindo sua vida atual na barra 
	# e nos numeros que ficam em cima
	# Esse procedimento também retira o indicativo vermelho de dano impresso por RENDERIZAR_ATAQUE_DANO
	#
	# Argumento:
	#	a4 = [ 0 ] -> atualizar barra de vida do pokémon inimigo
	#	     [ 1 ] -> oatualizar barra de vida do pokémon do RED
		
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Verifica a vida do pokemon
	# a4 já tem o numero indicando qual pokemon verificar
	call VERIFICAR_VIDA_POKEMON
	# do retorno a0 tem endereço final onde o restante da vida do pokemon está na barra de vida
	slli t4, a1, 1		# multiplica a vida do pokemon por 2 porque cada ponto de vida ocupa 2 pixels 
	
	mv t2, a0		# do loop acima a0 está no final da barra de vida restante do pokemon
	li t3, 90		
	sub t3, t3, t4		# t3 recebe 90 - vida atual do pokemon (t4) de modo que tem o tamanho da 
				# porção restante da barra de vida que não está preenchida de verde
	
	# se ainda sim t3 == 0 então nada precisa ser feito
	beq t3, zero, FIM_ATUALIZAR_BARRA_DE_VIDA
	
	# Agora é necessario pintar essa porção da barra de vida com a cor branca para limpar o dano feito
		li a0, 0xFF		# a0 tem a cor branca
		mv a1, t2		# t2 tem o endereço de onde começar a imprimir a cor	
		mv a2, t3		# t3 numero de colunas da barra de vida a serem pintadas
		li a3, 3		# numero de linhas da barra de vida		
		call PRINT_COR	
	
		# Pintando a barra também no frame 1
		li a0, 0xFF		# a0 tem a cor branca
		mv a1, t2		# t2 tem o endereço de onde começar a imprimir a cor	
		li t0, 0x00100000
		add a1, a1, t0		# passa o endereço de t2 para o frame 1
		mv a2, t3		# t3 numero de colunas da barra de vida a serem pintadas
		li a3, 3		# numero de linhas da barra de vida		
		call PRINT_COR	


	# Por fim, será impresso os números indicando a vida atual do pokemon
		# Calculando o endereço de onde começar a imprimir os numeros dependendo de a4
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde os numeros de vida do pokemon inimigo está
		li a2, 122		# numero da coluna 
		li a3, 37		# numero da linha
		beq a4, zero, ATUALIZAR_BARRA_CALCULAR_ENDERECO_NUMEROS
		
		# Onde os numeros de vida do pokemon do RED está
		li a2, 266		# numero da coluna 
		li a3, 117		# numero da linha
				
		ATUALIZAR_BARRA_CALCULAR_ENDERECO_NUMEROS:
		
		call CALCULAR_ENDERECO		
		mv t2, a0		# move o retorno para t2
	
		# antes é necessario limpar a parte com os numeros na barra de vida
		li a0, 0xFF		# a0 tem a cor branca
		mv a1, t2		# t2 tem o endereço de onde começar a imprimir a cor	
		li a2, 13		# numero de colunas a serem pintadas
		li a3, 10		# numero de linhas a serem pintadas		
		call PRINT_COR	
	
		srli t4, t4, 1		# divide t4 por 2 porque cada ponto de vida é representado por 2 pixels
		
		call TROCAR_FRAME  		# inverte o frame, mostrando o frame 1
			
		# Imprime o numero
		mv a0, t4		# a0 recebe o numero a ser impresso	
		mv a1, t2		# t2 tem o endereço de onde imprimir o numero
		
		li t0, 10
		bge t4, t0, ATUALIZAR_BARRA_PRINT_NUMERO
		# se a vida do pokemon for menor que 10 então o endereço onde o numero será impresso
		# é +7 colunas a direita	
		addi a1, a1, 7
					
		ATUALIZAR_BARRA_PRINT_NUMERO:
											
		call PRINT_NUMERO
	
		call TROCAR_FRAME  		# inverte o frame, mostrando o frame 0
		
	# Replica a imagem dos pontos de vida no frame 0 para o frame 1 para que os dois estejam iguais
		# Calculando o endereço de onde começar a replica no frame 0 dependendo de a4
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde os numeros de vida do pokemon inimigo está
		li a2, 120		# numero da coluna 
		li a3, 37		# numero da linha
		beq a4, zero, ATUALIZAR_BARRA_REPLICAR_VIDA
		
		# Onde os numeros de vida do pokemon do RED está
		li a2, 264		# numero da coluna 
		li a3, 117		# numero da linha
				
		ATUALIZAR_BARRA_REPLICAR_VIDA:		
		call CALCULAR_ENDERECO		
		
		# a0 já tem o endereço de onde começar a replica no frame 0
		li t0, 0x00100000
		add a1, a0, t0		# a1 recebe o endereço de a0 no frame 1							
		li a2, 16		# numero de colunas a serem copiadas
		li a3, 16		# numero de linhas a serem copiadas
		call REPLICAR_FRAME

	FIM_ATUALIZAR_BARRA_DE_VIDA:
			
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret			

# ====================================================================================================== #

VERIFICAR_VIDA_POKEMON:
	# Procedimento que checa a barra de vida de um pokemon retornando seus pontos de vida
	#
	# Argumento:
	#	a4 = [ 0 ] -> verificar vida do pokémon inimigo
	#	     [ 1 ] -> verificar vida do pokémon do RED
	#
	# Retorno:
	#	a0 = endereço final onde a vida do pokemon está na barra de vida
	#	a1 = numero indicando a vida do pokemon 
		
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Calculando o endereço de onde a barra de vida começa dependendo de a4
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde a barra do pokemon inimigo está
		li a2, 64		# numero da coluna 
		li a3, 52		# numero da linha
		beq a4, zero, VERIFICAR_VIDA_POKEMON_CALCULAR_ENDERECO
		
		# Onde a barra do pokemon do RED está
		li a2, 208		# numero da coluna 
		li a3, 132		# numero da linha
				
		VERIFICAR_VIDA_POKEMON_CALCULAR_ENDERECO:
		
		call CALCULAR_ENDERECO		
		# do retorno a0 tem o endereço de inicio da barra de vida
		
	# Agora é necessário calcular quanto de vida o pokemon tem. Isso pode ser feito contando os pixels
	# de cor verde na barra de vida
	
	li t0, 0		# contador para o numero de pixels verdes
	li t1, 178		# cor do pixel verde que faz parte da barra de vida
	
	VERIFICAR_VIDA_POKEMON_LOOP:
		lbu t2, 0(a0)		# pega 1 pixel da barra de vida
		
		bne t2, t1, FIM_VERIFICAR_VIDA_POKEMON		
		# se o pixel for da cor verde (178) incrementa t4 (numero de pontos de vida) e a0 (endereço
		# na barra de vida)
		addi t0, t0, 1
		addi a0, a0, 1
		j VERIFICAR_VIDA_POKEMON_LOOP
	
	FIM_VERIFICAR_VIDA_POKEMON:
	# a0 já tem o retorno correto
	srli a1, t0, 1		# divide t0 por 2 porque cada ponto de vida ocupa 22 pixels na barra
				
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #
																																																																																																																																	
PRINT_POKEMON_SILHUETA:
	# Procedimento que imprime a silhueta de um pokemon na tela. Por silhueta entende-se uma imagem	
	# de um pokemon em pokemons.bmp, só que ao inves de imprimir a imagem normalmente o pokemon será
	# impresso apenas com pixels rosa, imprimindo só o "formato" do pokemon.
	# O procedimente tem suporte para imprimir a silheta de forma imvertida
	#
	# Argumentos: 
	# 	a0 = endereço da imagem	do pokemon	
	# 	a1 = endereço de onde, no frame escolhido, a imagem deve ser renderizada
	# 	a2 = numero de colunas da imagem
	#	a3 = numero de linhas da imagem
	#	a4 = [ 0 ] -> se a silhueta for impressa na orientação normal
	#	     [ 1 ] -> se a sulhueta deve ser impressa de forma invertida
	
	mul t0, a4, a2		# Caso a4 == 1 a imagem deve ser impressa de forma invertida então o endereço
	add a0, a0, t0		# de a0 deve estar no final da primeira linha
	li t0, -1
	mul t0, t0, a4
	add a0, a0, t0		# também é necessario voltar o endereço por 1 coluna (por motivos desconhecidos)	
		
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
									
			li t0, -2		# Caso a4 == 1 a imagem deve ser impressa de forma invertida 
			mul t0, a4, t0		# então o endereço de a0 precisa ser decrementado (-1)
			add a0, a0, t0		# (-2 porque foi somado 1 acima)		
			
			addi a1, a1, 1			# vai para o próximo pixel do bitmap
			bne t1, zero, PRINT_POKEMON_SILHUETA_COLUNAS	# reinicia o loop se t1 != 0
				
		sub a1, a1, a2			# volta o endeço do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endereço do bitmap para a proxima linha

		mul t0, a4, a2		# Caso a4 == 1 a imagem deve ser impressa de forma invertida então o
		add a0, a0, t0		# endereço de a0 deve estar no final da proxima linha a ser impressa,
		add a0, a0, t0		# o que requer soma t0 duas vezes
				
		addi a3, a3, -1			# decrementando o numero de linhas restantes
				
		bne a3, zero, PRINT_POKEMON_SILHUETA_LINHAS	# reinicia o loop se a3 != 0
			
	ret
	
# ====================================================================================================== #
	
.data
	.include "../Imagens/combate/matriz_tiles_tela_combate.data"
	.include "../Imagens/combate/seta_proximo_dialogo_combate.data"				
	.include "../Imagens/combate/tiles_caixa_pokemon_combate.data"	
	.include "../Imagens/combate/matriz_tiles_caixa_pokemon_combate.data"					
	.include "../Imagens/combate/seta_direcao_caixa_pokemon_combate.data"									
	.include "../Imagens/combate/combate_barra_de_vida.data"
	.include "../Imagens/combate/efeito_de_ataque.data"
	.include "../Imagens/combate/pokebola_captura.data"																																																																											
	.include "../Imagens/outros/caractere_barra.data"																		
