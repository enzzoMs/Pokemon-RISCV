.data

# Inicializando os itens do inventario

NUMERO_DE_POKEBOLAS: .byte 0
POKEMONS_DO_RED: .word 0,0,0,0,0
# O codigo de cada pokemon é codificado no seguinte formato FFF_RRR_TTT_PP, onde:
# 	PP -> número do pokemon, de modo que:
#		[ 001 ] -> BULBASAUR
#		[ 010 ] -> CHARMANDER
#		[ 011 ] -> SQUIRTLE
#		[ 100 ] -> CATERPIE
#		[ 101 ] -> DIGLETT
#	TTT -> tipo do pokemon, RRR -> tipo que ele é fraco, FFF -> tipo que ele é forte, todos de modo que:
#		[ 000 ] -> GRASS
#		[ 001 ] -> FIRE
#		[ 010 ] -> WATER
#		[ 011 ] -> GROUND
#		[ 100 ] -> BUG
# Sendo assim o codigo de cada Pokemon pode ser encontrado abaixo:
# 	BULBASAUR -> 1089
#	CHARMANDER -> 138
# 	SQUIRTLE -> 531
# 	CATERPIE -> 100
# 	DIGLETT -> 541

.text

# ====================================================================================================== # 
# 				              INVENTARIO					         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Contém alguns procedimentos destinados a renderização do inventario do jogador, possuindo as 		 #
# informações de quais pokemons ele tem, algumas informações básicas sobre eles e quantas pokebolas	 #
#													 #
# ====================================================================================================== #

MOSTRAR_INVENTARIO:
	# Este procedimento que coordena o funcionamento do inventario na tela, imprimindo todas as informações
	# necessário e fazendo alterações no menu de acordo com os inputs do jogador
	
	# OBS: não é necessário empilhar o valor de ra pois a chegada a este procedimento é por meio
	# de uma instrução de jump e a saida é pelo ra empilhado em VERIFICAR_TECLA_JOGO

	# Primeiro imprime a imagem base do inventario, ou seja, a imagem sem nunhum pokemon, nome ou outra
	# informação, só com os placeholders necessários  	
	# A impressão dessa tela funciona da mesma maneira que qualquer outra tela que também usa um esquema
	# de tiles
	# O inventario sempre é impresso no frame 1

	# Calculando o endereço de onde imprimir o inventario no frame 1
		li a1, 0xFF100000	# seleciona o frame 1
		li a2, 56 		# numero da coluna 
		li a3, 56		# numero da linha
		call CALCULAR_ENDERECO	
		
		mv a2, a0	# do retorno do procedimento acima a0 tem o endereço de onde imprimir o inventario
		
	# Imprimindo os tiles do inventario
		la a0, matriz_tiles_inventario		# carrega a matriz de tiles da caixa
		la a1, tiles_inventario			# carrega a imagem com os tiles da caixa
		# a2 já tem o endereço de onde imprimir as caixas
		call PRINT_TILES
	
	# Agora é necessário popular o inventário com as informações atuais do jogador, como o número de pokebolas
	# e cada pokemon que ele tem
	
		# Começando com o texto 'Inventário' será usado apenas o PRINT_TEXTO
			# Calculando o endereço de onde o texto
			li a1, 0xFF100000	# seleciona o frame 1
			li a2, 74		# numero da coluna 
			li a3, 66		# numero da linha
			call CALCULAR_ENDERECO		
		
			mv a1, a0		# move o retorno para a1
			
			# Imprime o texto
			# a1 já tem o endereço correto
			la a4, matriz_texto_inventario
			call PRINT_TEXTO
			
	
		# Para as pokebolas é precisa imprimir uma pequena imagem representando as pokebolas
			# Calculando o endereço de onde imprimir a imagem das pokebolas
			li a1, 0xFF100000	# seleciona o frame 1
			li a2, 203		# numero da coluna 
			li a3, 147		# numero da linha
			call CALCULAR_ENDERECO	
			
			mv t3, a0	# salva o retorno em t3
			mv a1, a0	# move o retorno para a1
		
			# Imprimindo a imagem das pokebolas
			la a0, pokebola_inventario		# carrega a imagem do sprite			
			# a1 já tem o endereço de onde imprimir a imagem
			lw a2, 0(a0)		# numero de colunas da imagem 
			lw a3, 4(a0)		# numero de linhas daa imagem 	
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG	
			
			# Agora será impresso o número de pokebolas (0 - 9) que o RED tem
			# Para encontrar a imagem do numero certo para imprimir será usado simplesmente o valor
			# de NUMERO_DE_POKEBOLAS, sendo que a imagem dos numeros está construida de modo que
			# o numero 1 está a 1 * (6 x 10) pixles do começo da imagem, da mesma forma como funcionam
			# os tiles em outras imagens
	
			la t0, NUMERO_DE_POKEBOLAS
			lb t0, 0(t0)			# t0 recebe o numero de pokebolas
				
			li t1, 60	# t1 recebe 6 * 10 = 60, ou seja, a área de uma imagem de um numero							
			mul t0, t0, t1	# como dito acima t1 (número de pokebolas) * (6 * 10) retorna quantos 
					# pixels o numero está do começo da imagem dos tiles de numeros
			la t1, tiles_numeros	
			add a0, t1, t0	

			# Imprimindo a imagem do numero
			# a0 já tem a imagem certa		
			addi a1, t3, 21		# o endereço onde o numero será impresso é a 21 colunas de onde 
						# a imagem da pokebola foi impressa (t3)
			li a2, 6		# numero de colunas de um tile de numero 
			li a3, 10		# numero de linhas de um tile de numero  	
			addi a0, a0, 8		# pula para onde começa os pixels no .data	
			call PRINT_IMG

		# Por fim, serão impressos os nomes de cada um dos pokemons que o RED tem
			# Calculando o endereço de onde o primeiro nome será impresso
			li a1, 0xFF100000	# seleciona o frame 1
			li a2, 184		# numero da coluna 
			li a3, 64		# numero da linha
			call CALCULAR_ENDERECO		
			
			mv t5, a0		# move o retorno para t5
		
		la t6, POKEMONS_DO_RED		# carrega a lista de pokemons
		
		LOOP_IMPRIMIR_NOME_POKEMOM:
			lw t0, 0(t6)		# le o codigo do pokemon apontado por t6 e realiza o andi
			andi t1, t0, 7		# com 7 (0111) de modo que deixa só os 3 primeiros bits de 
						# t6 intactos para a analise
			
			# se t1 == 0 então não tem um pokemon nessa posição
			beq t1, zero, PROXIMO_POKEMOM
			
			# se t1 == 1 então é o bulbasaur que está nessa posição
			li t0, 1
			la a4, matriz_texto_bulbasaur 		# carrega a matriz com o nome do pokemon
			beq t1, t0, IMPRIMIR_NOME_POKEMON
			
			# se t1 == 2 então é o charmander que está nessa posição
			li t0, 2
			la a4, matriz_texto_charmander 		# carrega a matriz com o nome do pokemon
			beq t1, t0, IMPRIMIR_NOME_POKEMON

			# se t1 == 3 então é o squirtle que está nessa posição
			li t0, 3
			la a4, matriz_texto_squirtle 		# carrega a matriz com o nome do pokemon
			beq t1, t0, IMPRIMIR_NOME_POKEMON
			
			# se t1 == 4 então é o caterpie que está nessa posição
			li t0, 4
			la a4, matriz_texto_caterpie 		# carrega a matriz com o nome do pokemon
			beq t1, t0, IMPRIMIR_NOME_POKEMON
			
			# se t0 == 5 então é o diglett que está nessa posição
			la a4, matriz_texto_diglett 		# carrega a matriz com o nome do pokemon
									
			IMPRIMIR_NOME_POKEMON:												
			# Imprime o texto com o nome do pokemon
			mv a1, t5 	# t5 tem o endereço de onde imprimir o texto nessa iteração
			# a4 já tem a matriz com o nome do pokemon
			call PRINT_TEXTO
																													
																																																			
			PROXIMO_POKEMOM:
			addi t6, t6, 4		# passa o endereço de t6 para o proximo pokemon da lista
			
			li t0, 5120	
			add t5, t5, t0		# passa o endereço de t5 para a posição onde o proximo
						# texto será impresso (5120 = 16 * 320)																																	
			
			la t0, POKEMONS_DO_RED
			addi t0, t0, 20		# passa t0 para o fim de POKEMONS_DO_RED
 			
			bne t6, t0, LOOP_IMPRIMIR_NOME_POKEMOM	# reinicia o loop se o endereço de t6 ainda 
								# não está no fim da lista de pokemons

	call TROCAR_FRAME	# inverte o frame, ou seja, mostra o frame 1
				
	# Com todos os itens no lugar é hora de tornar o menu do inventário responsivo aos comandos do jogador,
	# dando a opção de trocar entre pokemons com W e S
	
	li t4, 0		# o menu começa com a primeira opção selecionada
	
	LOOP_SELECIONAR_POKEMON_INVENTARIO:
		# Primeiro imprime uma imagem de uma seta indicando a opção selecionada		
	   		# Calculando o endereço de onde a seta será impressa
			li a1, 0xFF100000	# seleciona o frame 1
			li a2, 178		# numero da coluna 
			li a3, 64		# numero da linha
			li t0, 16
			mul t0, t4, t0		# o numero da linha também é dependendo do valor da opção 
			add a3, a3, t0		# atualmente selecionada
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
		
		# Agora seleciona a opção mudando os pixels do texto do pokemon por pixels azuis
			# Via de regra o endereço de onde o texto está sempre fica a 7 colunas e 2 linhas 
			# de distancia da seta
			
			addi t5, t3, 647	# t5 recebe o endereço de onde imprimir o texto a partir do endereço
						# da seta (t3)
						# 647 = (320 * 2 linhas) + 7 colunas
			
			# Selecionado a opção
			li a0, 0		# a0 == 0 -> selecionar a opção
			mv a1, t5		# t5 tem o endereço de onde o texto está
			li a2, 10		# numero de linhas de pixels do texto
			li a3, 70		# numero de colunas de pixels do texto
			call SELECIONAR_OPCAO_INVENTARIO
	
		# Imprime a imagem do pokemon, seu tipo e pontos pontes e fracos
			# O primeiro passo é encontrar qual o pokemon correspondente a essa opção
				li t0, 4		# Para encontrar o endereço da opção atual em 
				mul t0, t0, t4		# POKEMONS_DO_RED basta utilizar o valor de t4
				la t1, POKEMONS_DO_RED	# (numero da opção atual) partindo do fato de 
				add t1, t1, t0		# de que cada pokemon tem 1 word (4 bytes) de tamanho
				
				lw t6, 0(t1)		# le o codigo do pokemon apontado por t1 e realiza o andi
				andi t3, t6, 7		# com 7 (0111) de modo que deixa só os 3 primeiros bits de 
							# t1 intactos para a analise
			
				# se t3 == 0 então não tem um pokemon nessa posição
				beq t3, zero, LOOP_SELECIONAR_OPCAO	
			
			# Calcula o endereço de onde imprimir a imagem do pokemon 
				li a1, 0xFF100000		# seleciona como argumento o frame 1
				li a2, 93 			# numero da coluna 
				li a3, 95			# numero da linha
				call CALCULAR_ENDERECO	
		
				mv a1, a0		# move para a1 o endereço retornado
			
			# Imprimindo o pokemon no frame 		
				la a0, pokemons		# carrega a imagem dos pokemons
				addi a0, a0, 8		# pula para onde começa os pixels no .data
			
				li t0, 1482 		# t0 recebe o tamanho de uma imagem de um pokemon
				addi t3, t3, -1		# t3 precisa ser decrementado porque os pokemons começam
							# no 1 e não no 0
				mul t0, t3, t0		# decide qual imagem renderizar de acordo com t3
				add a0, a0, t0
			
				# a1 já tem o endereço de onde a imagem será impressa
				li a2, 38	# a2 = numero de colunas de uma imagem de um pokemon
				li a3, 39	# a3 = numero de linhas de uma imagem de um pokemon
				call PRINT_IMG
			
			# Imprimindo o tipo do pokemon
				la a0, pokemons_tipos	# carrega a imagem dos tipos de pokemons
				addi a0, a0, 8		# pula para onde começa os pixels no .data
			
				andi t0, t6, 56		# o andi 56 (111_000) deixa só os bits de t6 que 
							# correspondem ao tipo do pokemon intacto
				srli t0, t0, 3		# desloca 3 bits de t0 de modo que o tipo do pokemon 
							# começa cai em um intervalo de 0 a 4 ao inves de 4 a 20							
				li t1, 384 		# t0 recebe o tamanho de uma imagem de um tipo		
				mul t0, t0, t1		# decide qual imagem renderizar de acordo com t0
				add a0, a0, t0
				
				# do PRINT_IMG acima a1 ainda tem o endereço final onde o pokemon foi renderizado
				# Convenientemente o endereço de onde imprimir o tipo do pokemon sempre está a 
				# 3 linhas e 4 colunas
 				addi a1, a1, 964	# 964 = (320 * 3) + 4
				li a2, 32	# a2 = numero de colunas de uma imagem de tipo de pokemon
				li a3, 12	# a3 = numero de linhas de uma imagem de tipo de pokemon
				call PRINT_IMG			
			
			# Imprimindo as setas com representado o tipo forte e fraco do pokemon
				# Imprimindo seta do tipo fraco
				la a0, seta_tipo_forte_fraco	# carrega a imagem 
				addi a0, a0, 8			# pula para onde começa os pixels no .data
				# do PRINT_IMG acima a1 ainda tem o endereço onde o tipo do pokemon foi renderizado
				# Convenientemente o endereço de onde imprimir a seta sempre está a 
				# 13 linhas e -33 colunas
				li t0, 4127		# 4127 = (320 * 13) - 33
 				add a1, a1, t0	
				li a2, 10	# a2 = numero de colunas da imagem 
				li a3, 6	# a3 = numero de linhas da imagem 
				call PRINT_IMG				
			
				# Imprimindo seta do tipo forte
				# do PRINT_IMG acima a0 já tem o endereço da imagem da seta correta
				# do PRINT_IMG acima a1 está a -6 linhas e 54 colunas do endereço onde imprimir
				# a proxima seta
				li t0, -1866		# -1866 = (320 * -6) + 54
 				add a1, a1, t0	
				li a2, 10	# a2 = numero de colunas da imagem 
				li a3, 6	# a3 = numero de linhas da imagem 
				call PRINT_IMG					
									
			# Imprimindo o tipo forte e fraco do pokemon
				# Imprimindo o tipo fraco
				la a0, pokemons_tipos	# carrega a imagem 
				addi a0, a0, 8			# pula para onde começa os pixels no .data
				
				andi t0, t6, 448	# o andi 448 (111_000_000) deixa só os bits de t6 que 
							# correspondem a fraqueza do pokemon intactos
				srli t0, t0, 6		# desloca 6 bits de t0 de modo que a fraqueza do pokemon 
							# começa cai em um intervalo de 0 a 4 ao inves de 4 a 20							
				li t1, 384 		# t0 recebe o tamanho de uma imagem de um tipo		
				mul t0, t0, t1		# decide qual imagem renderizar de acordo com t0
				add a0, a0, t0
				# do PRINT_IMG anterior a1 está a -9 linhas e -42 colunas do endereço onde 
				# imprimir a proxima imagem
				li t0, -2922		# -2922 = (320 * -9) - 42
 				add a1, a1, t0	
				li a2, 32	# a2 = numero de colunas da imagem 
				li a3, 12	# a3 = numero de linhas da imagem 
				call PRINT_IMG	
							
				# Imprimindo o tipo forte
				la a0, pokemons_tipos	# carrega a imagem 
				addi a0, a0, 8		# pula para onde começa os pixels no .data
				
				li t0, 3584
				and t0, t6, t0		# o andi 3584 (111_000_000_000) deixa só os bits de t6 que 
							# correspondem a fraqueza do pokemon intactos
				srli t0, t0, 9		# desloca 9 bits de t0 de modo que a fraqueza do pokemon 
							# começa cai em um intervalo de 0 a 4 ao inves de 4 a 20							
				li t1, 384 		# t0 recebe o tamanho de uma imagem de um tipo		
				mul t0, t0, t1		# decide qual imagem renderizar de acordo com t0
				add a0, a0, t0
				# do PRINT_IMG anterior a1 está a -12 linhas e 54 colunas do endereço onde 
				# imprimir a proxima imagem
				li t0, -3786		# -3786 = (320 * -12) + 54
 				add a1, a1, t0	
				li a2, 32	# a2 = numero de colunas da imagem 
				li a3, 12	# a3 = numero de linhas da imagem 
				call PRINT_IMG				

		LOOP_SELECIONAR_OPCAO:
		
		# Agora é incrementado ou decrementado o valor de t4 de acordo com o input do jogador
		call VERIFICAR_TECLA
		
		addi t4, t4, -1	
		li t1, -1	# se o valor de t4 atualizado for -1 então o não dá para subir mais no menu
		beq t4, t1, SELECIONAR_OPCAO_S
		li t0, 'w'		
		beq a0, t0, OPCAO_TROCADA
		
		SELECIONAR_OPCAO_S:
		addi t4, t4, 2		# mais 2 porque foi subtraido 1 acima				
		li t1, 5	# se o valor de t4 atualizado for 5 então o não dá para descer mais no menu
		beq t4, t1, FIM_LOOP_SELECIONAR_OPCAO
		li t0, 's'
		beq a0, t0, OPCAO_TROCADA
		
		FIM_LOOP_SELECIONAR_OPCAO:
		addi t4, t4, -1		# memos 1 para voltar t4 para o valor que ele tinha antes das verificações
		
		li t0, 'i'		# se 'i' foi apertado então é preciso fechar o inventário
		beq a0, t0, FIM_LOOP_SELECIONAR_POKEMON_INVENTARIO
		
		j LOOP_SELECIONAR_OPCAO
		
		OPCAO_TROCADA:
		# Se ocorreu uma troca de opção é necessário retirar a seleção da opção atual e limpar a tela
			# Retirando a seleção da opção
			li a0, 1		# a0 == 1 -> retirar seleção
			mv a1, t5		# t5 ainda tem o endereço de onde o texto da ultima opção
						# selecionada está
			li a2, 10		# numero de linhas de pixels do texto
			li a3, 70		# numero de colunas de pixels do texto
			call SELECIONAR_OPCAO_INVENTARIO
			
			# Retirando a imagem da seta
			addi t5, t5, -7		# volta o endereço de t5 por sete colunas de modo que t5
						# agora tem o endereço de onde a seta está
			
			li t0, 191		# t0 tem o valor do fundo do menu do inventario
			li t1, 11		# numero de linhas da imagem da seta
	
			RETIRAR_SETA_LINHAS:
			li t2, 6		# numero de colunas da imagem da seta
			
			RETIRAR_SETA_COLUNAS:
			sb t0, 0(t5)		# armazena o pixel de t0 em t5
	
			addi t2, t2, -1			# decrementa o numero de colunas restantes
			addi t5, t5, 1			# vai para o próximo pixel do bitmap
			bne t2, zero, RETIRAR_SETA_COLUNAS	# reinicia o loop se t2 != 0
			
			addi t1, t1, -1			# decrementando o numero de linhas restantes
		
			addi t5, t5, -6			# volta o endeço do bitmap pelo numero de colunas impressas
			addi t5, t5, 320		# passa o endereço do bitmap para a proxima linha
		
			bne t1, zero, RETIRAR_SETA_LINHAS	# reinicia o loop se t1 != 0
			
		# Limpando a tela
			# Calculando o endereço de onde começar a limpeza
				li a1, 0xFF100000		# seleciona como argumento o frame 1
				li a2, 88 			# numero da coluna 
				li a3, 88			# numero da linha
				call CALCULAR_ENDERECO		
			
				mv a1, a0	# move o retorno para a1
			
			# Limpando a tela. A limpeza consistem em imprimir novamente o tile que faz parte do
			# "fundo" do inventario 		
				li t3, 16	# A impressão vai acontecer em 16 colunas ao longo do loop abaixo
				li t5, 4	# Nos primeiros loops vão ser limpos 4 linhas
				li t1, 0	# De inicio não atualiza o a1
				
				LOOP_LIMPAR_INVENTARIO_PROXIMA_ITARACAO:
					add a1, a1, t1		# atualiza o endereço de a1 para a proxima coluna
								# de acordo com o valor escolhido de t1
		
				LOOP_LIMPAR_INVENTARIO:
					la a0, tiles_inventario	
					addi a0, a0, 8	
					li t0, 2304		# A imagem que será usada na limpeza está é o
					add a0, a0, t0		# tile 9, portanto está a 2304 = 9 * 16 * 16 
								# pixels do inicio da imagem de tiles
					# a1 já tem o endereço de onde imprimir o tile
					li a2, 16		# numero de colunas de um tile
					li a3, 16		# numero de linhas de um tile
					call PRINT_IMG
					
					# Pelo funcionamento do PRINT_IMG a1 já vai estar no endereço de inicio
					# do tile imediatamente abaixo do que foi impresso				
																	
					addi t5, t5, -1		# decrementa o numero de linhas restantes
					bne t5, zero, LOOP_LIMPAR_INVENTARIO	# reinicia o loop se t5 != 0
				
				addi t3, t3, -1		# decrementa o numero de colunas restantes
				
				# Abaixo é decidido dependendo da iteração (t3) qual o proximo numero de linhas
							
				li t1, -20464 		# a1 será atualizado em -64 linhas e + 16 colunas
				li t5, 4		# a proxima limpeza será em 4 linhas		
				li t0, 14
				bge t3, t0, LOOP_LIMPAR_INVENTARIO_PROXIMA_ITARACAO	
				li t0, 13
				li t1, -64		# a1 será atualizado em -64 colunas
				li t5, 1		# a proxima limpeza será em 1 linha	
				beq t3, t0, LOOP_LIMPAR_INVENTARIO_PROXIMA_ITARACAO	
				li t1, -5104 		# a1 será atualizado em -16 linhas e + 16 colunas
				li t5, 1		# a proxima limpeza será em 1 linha		
				li t0, 7			
				bge t3, t0, LOOP_LIMPAR_INVENTARIO_PROXIMA_ITARACAO
				li t1, -80		# a1 será atualizado em -80 colunas
				li t5, 1		# a proxima limpeza será em 1 linha
				li t0, 6				
				beq t3, t0, LOOP_LIMPAR_INVENTARIO_PROXIMA_ITARACAO	
				li t1, -5104 		# a1 será atualizado em -16 linhas e + 16 colunas
				li t5, 1		# a proxima limpeza será em 1 linha		
				li t0, 7			
				bge t3, zero, LOOP_LIMPAR_INVENTARIO_PROXIMA_ITARACAO			
										
		j LOOP_SELECIONAR_POKEMON_INVENTARIO
	
	FIM_LOOP_SELECIONAR_POKEMON_INVENTARIO:
	
	# Para fechar o inventário só é necessário limpar a tela no frame 1
		call TROCAR_FRAME 	# inverte o frame, ou seja, mostra o frame 0			
													
		# Calculando o endereço de onde o inventario foi impresso no frame 1
		li a1, 0xFF100000	# seleciona o frame 1
		li a2, 48 		# numero da coluna 
		li a3, 48		# numero da linha
		call CALCULAR_ENDERECO	
		
		mv a1, a0	# move o retorno para a1
		
		# Imprimindo os tiles e limpando a tela
		mv a0, s2	# move para a0 o endereço de inicio da matriz de tiles que está na tela
		li t0, 3
		mul t0, t0, s3	
		add a0, a0, t0	# o endereço na matriz onde começam os tiles que vão ser usados na limpeza
		addi a0, a0, 3	# está a 3 linhas e 3 colunas do inicio de s2	
		# a1 já tem o endereço onde imprimir os tiles
		li a2, 14	# número de colunas de tiles a serem impressas
		li a3, 9	# número de linhas de tiles a serem impressas
		call PRINT_TILES_AREA	
		
		# Por via das dúvidas é melhor imprimir novamente o sprite do RED no frame 1 porque talvez 
		# ele foi pego na limpeza acima
		
		# Escolhe a imagem do RED de acordo com s1
		la a0, red_esquerda				
		beq s1, zero, FIM_INVENTARIO_PRINT_RED
		la a0, red_direita	
		li t0, 1				
		beq s1, t0, FIM_INVENTARIO_PRINT_RED		
		la a0, red_cima	
		li t0, 2				
		beq s1, t0, FIM_INVENTARIO_PRINT_RED		
		la a0, red_baixo					
				
		FIM_INVENTARIO_PRINT_RED:
		mv a1, s0		# s0 tem a posição do RED no frame 0
		li t0, 0x00100000	# passando o endereço de s0 para o seu endereço correspondente no
		add a1, a1, t0		# frame 1
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
		
		# Se for necessário também é preciso imprimir a faixa de grama no frame 1 de acordo com s10
		beq s10, zero, FIM_INVENTARIO
		la a0, tiles_pallet	# para encontrar a faixa de grama que será impressa pode ser usado o
		addi a0, a0, 8		# tilles pallet, partindo do fato de que essa imagem vai estar 
		li t0, 22688		# na linha 1418 (22688 = 1418 * 16 (largura de uma linha de tiles_pallet))
		add a0, a0, t0
		
		mv a1, a6		# O endereço onde essa faixa será impressa é no novo endereço do
		li t0, 4160		# personagem (a6), 13 linhas para baixo (4160 = 13 * 320) e uma coluna
		add a1, a1, t0		# para a esquerda (-1)
		addi a1, a1, -1
		
		li t0, 0x00100000	# passa o endereço de a1 para o frame 1
		add a1, a1, t0		
			
		li a2, 16		# numero de colunas da faixa de grama	
		li a3, 6		# numero de linhas da faixa de grama	
		call PRINT_IMG	

	FIM_INVENTARIO:
				
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
			
# ====================================================================================================== #
									
SELECIONAR_OPCAO_INVENTARIO:
	# Procedimento auxiliar que tem por objetivo selecionar ou retirar a seleção de um item do inventario
	# trocando os pixels de um texto por pixels azuis ou pixels cinza dependendo do argumento
	# O texto deve ter sido impresso usando os tiles em tiles_alfabeto.data
	# 
	# Argumentos:
	# 	a0 = [ 0 ] -> selecionar uma opção, ou seja, trocar os pixels do texto de cinza para azul
	#	     [ != 0 ] -> retirar a seleção de uma opção, ou seja, trocar os pixels de azul para cinza
	#	a1 = endereço onde o texto está
	#	a2 = numero de linhas de pixels do texto
	#	a3 = numero de colunas de pixels do texto
	
	li t0,	91		# t0 = cor do texto quando ele não está selecionado	
	li t1,	192		# t1 = cor que vai "selecionar" o texto
		
	# Se a0 != 0 então o procedimento vai retirar a seleção de um item								
	beq a0, zero, SELECIONAR_OPCAO_LINHAS	
		li t0,	192		# t0 = cor do texto quando ele está selecionada	
		li t1,	91		# t1 = cor que vai retirar a seleção do texto
					
	SELECIONAR_OPCAO_LINHAS:
		mv t2, a3		# copia do numero de colunas no loop abaixo
			
		SELECIONAR_OPCAO_COLUNAS:
			lbu t3, 0(a1)			# pega 1 pixel do bitmap e coloca em t3
			
			# Se t3 != t0 então o pixel não sera modificado,
			# dessa forma somente o texto do item será modificados					
			bne t3, t0, NAO_MODIFICAR_OPCAO
				sb t1, 0(a1)
			
			NAO_MODIFICAR_OPCAO:
			addi a1, a1, 1				# vai para o próximo pixel do bitmap
			addi t2, t2, -1				# decrementando o numero de colunas restantes
			bne t2, zero, SELECIONAR_OPCAO_COLUNAS	# reinicia o loop se t2 != 0
			
		sub a1, a1, a3				# volta o endeço do bitmap pelo numero de colunas impressas
		addi a1, a1, 320			# passa o endereço do bitmap para a proxima linha
		addi a2, a2, -1				# decrementando o numero de linhas restantes		
		bne a2, zero, SELECIONAR_OPCAO_LINHAS	# reinicia o loop se a2 != 0
			
	ret

# ====================================================================================================== #

.data
	.include "../Imagens/inventario/tiles_inventario.data"
	.include "../Imagens/inventario/matriz_tiles_inventario.data"
	
	.include "../Imagens/inventario/tiles_numeros.data"
	
	.include "../Imagens/inventario/pokebola_inventario.data"
	
	.include "../Imagens/inventario/matriz_texto_inventario.data"
	
	.include "../Imagens/inventario/matriz_texto_bulbasaur.data"
	.include "../Imagens/inventario/matriz_texto_charmander.data"
	.include "../Imagens/inventario/matriz_texto_squirtle.data"
	.include "../Imagens/inventario/matriz_texto_caterpie.data"
	.include "../Imagens/inventario/matriz_texto_diglett.data"
				
	.include "../Imagens/inventario/pokemons_tipos.data"
	.include "../Imagens/inventario/seta_tipo_forte_fraco.data"
