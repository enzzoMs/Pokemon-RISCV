.text

# ====================================================================================================== # 
# 						INTRO HISTORIA				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Código responsável por renderizar a história introdutória do jogo com todas as suas animações.         # 
#													 #
# ====================================================================================================== #


INICIALIZAR_INTRO_HISTORIA:
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra	
		
	# Imprimindo a intro_prof_carvalho no frame 0
		la a0, intro_prof_carvalho			# carregando a imagem em a0
		li a1, 0xFF000000		# selecionando como argumento o frame 0
		call PRINT_TELA

	# Imprimindo a intro_prof_carvalho no frame 1
		la a0, intro_prof_carvalho			# carregando a imagem em a0
		li a1, 0xFF100000		# selecionando como argumento o frame 1
		call PRINT_TELA
	
	# Espera alguns milisegundos	
		li a0, 500		# sleep por 500 ms
		call SLEEP		# chama o procedimento SLEEP		
	
	# Renderiza 4 caixas de dialogo	
		la a5, intro_dialogos	# carrega o endereço da imagem 
		addi a5, a5, 8		# pula para onde começa os pixels no .data
		li a6, 5		# seleciona como argumento o numero de dialogos a serem renderizados
		call PRINT_DIALOGOS	

	mv a6, zero			# com argumento a6 = 0 renderiza o começo da animação do professor
	call RENDERIZAR_ANIMACAO_PROF
	
	# Renderiza 4 caixas de dialogo	
		# através da chamada do procedimento PRINT_DIALOGOS acima, a5 já possui o endereço
		# do próximo diálogo
		li a6, 4		# seleciona como argumento o numero de dialogos a serem renderizados
		call PRINT_DIALOGOS
	
	li a6, 1			# com argumento a6 = 1 renderiza o final da animação do professor
	call RENDERIZAR_ANIMACAO_PROF	
	
	# Renderiza 1 caixas de dialogo	
		# através da chamada do procedimento PRINT_DIALOGOS acima, a5 já possui o endereço
		# do próximo diálogo
		li a6, 1		# seleciona como argumento o numero de dialogos a serem renderizados
		call PRINT_DIALOGOS
		
		
	li a6, 0			# com argumento a6 = 0 renderiza a silhueta do RED
	call RENDERIZAR_RED	
			
	# Renderiza 1 caixas de dialogo	
		# através da chamada do procedimento PRINT_DIALOGOS acima, a5 já possui o endereço
		# do próximo diálogo
		li a6, 1		# seleciona como argumento o numero de dialogos a serem renderizados
		call PRINT_DIALOGOS
		
	li a6, 1			# com argumento a6 = 1 renderiza a imagem completa do RED
	call RENDERIZAR_RED		
		
	# Renderiza 1 caixas de dialogo	
	# através da chamada do procedimento PRINT_DIALOGOS acima, a5 já possui o endereço
	# do próximo diálogo
		li a6, 1		# seleciona como argumento o numero de dialogos a serem renderizados
		call PRINT_DIALOGOS	
				
		
	# Imprime a imagem do BLUE em ambos os frames										
		# Calcula o endereço de onde renderizar a imagem do Blue no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 124 			# numero da coluna
		li a3, 34			# numero da linha
		call CALCULAR_ENDERECO
		
		mv t4, a0			# salva o endereço retornado em t4
		
		li t0, 0x00100000	# soma t0 com t4 de forma que o endereço de t4 passa para o 
		add a1, t4, t0		# endereço correspondente no frame 1		
		
		# Imprimindo a imagem do Blue no frame 1
		la a0, intro_blue	# carrega a imagem
		# a1 já possui o endereço de onde renderizar a imagem
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED			
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG

		# Imprimindo a imagem do Blue no frame 0	
		la a0, intro_blue	# carrega a imagem
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		mv a1, t4		# passa para a1 o endereço de onde renderizar a imagem
		# a2 (numero de linhas) e a3 (numero de colunas) já possuem os valores corretos					
		call PRINT_IMG	
					
	# Renderiza 3 caixas de dialogo	
	# através da chamada do procedimento PRINT_DIALOGOS acima, a5 já possui o endereço
	# do próximo diálogo
		li a6, 3		# seleciona como argumento o numero de dialogos a serem renderizados
		call PRINT_DIALOGOS					
				
	li a6, 1			# com argumento a6 = 1 renderiza a imagem completa do RED
	call RENDERIZAR_RED		
		
	# Renderiza 3 caixas de dialogo	
	# através da chamada do procedimento PRINT_DIALOGOS acima, a5 já possui o endereço
	# do próximo diálogo
		li a6, 3		# seleciona como argumento o numero de dialogos a serem renderizados
		call PRINT_DIALOGOS				
				
	call RENDERIZAR_ANIMACAO_FINAL_INTRO
										
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #					

RENDERIZAR_ANIMACAO_PROF:
	# Procedimento que imprime uma serie de imagens do professor Carvalho
	# Esse procedimento pode imprimir o começo ou final da animação do professor a depender do argumento
	# Em ambos os casos o procedimento usa o arquivo prof_carvalho_intro_animacao.data, a diferença é que 
	# o começo da animação segue as imagens de forma sequencial e o final segue as imagens na ordem inversa
	# Argumentos:
	#	a6 = Se 0 -> imprime o começo da animação
	# 	     Se qualquer outro valor -> imprime o final da animação

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Mostra o frame 0 
		li t0, 0xFF200604	# carrega o endereço para escolher os frames
		sw zero, 0(t0)		# armazena 0 no endereço de t0

	# Calcula o endereço de onde renderizar a imagem do professor no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 94 			# coluna = 94
		li a3, 26			# linha = 26
		call CALCULAR_ENDERECO

	mv t4, a0			# guarda o endereço em t4

	la a0, prof_carvalho_intro_animacao	# carrega a imagem em a0
	addi a0, a0, 8			# pula para onde começa os pixels no .data
	li a2, 128			# a2 = numero de colunas na imagem a ser renderizada
	li a3, 143			# a3 = numero de linhas na imagem a ser renderizada
	
	mul t5, a2, a3		# t5 = a2 * a3 = colunas * linhas = area total de uma imagem do professor
	
	add a0, a0, t5		# pula para a segunda imagem do .data
	
	li t6, 4		# t6 = numero de loops a serem executados
	
	# Verifica se o argumento a6 == 0, caso sim avança a0 para a 4a imagem
	beq a6, zero, LOOP_RENDERIZAR_PROF
		slli t5, t5, 1		# através de um shif lógico multiplica t5 por 2	
					# nesse caso t5 possui a area total de 2 imagens do professor		
		
		add a0, a0, t5		# passa o endereço de a0 para a 4a imagem
	
	LOOP_RENDERIZAR_PROF:
		# a0 já possui o endereço da imagem
		mv a1, t4		# move para a1 o endereço no bitmap onde a imagem será impressa
		# a2 e a3 já possuem o numero de linhas e colunas da imagem
		call PRINT_IMG
		
		mv t2, a0		# guarda o endereço de a0 em t0
		
		# Espera alguns milisegundos	
			li a0, 500			# sleep por 500 ms
			call SLEEP			# chama o procedimento SLEEP		
	
		mv a0, t2		# volta o endereço de t0 para a0
	
		# Verifica se o argumento a6 == 0, nesse caso o procedimento renderiza as imagens na 
		# ordem inversa do mostrado no prof_carvalho_intro_animacao, portanto o endereço de a0
		# deve "subir" duas imagens
		beq a6, zero, LOOP_PROF_RENDERIZAR_INICIO
			sub a0, a0, t5		# nesse ponto do codigo t5 possui a area total de pixels
						# de duas imagens do professor, portanto essa soma
						# volta o endereço de a0 em duas imagens
		LOOP_PROF_RENDERIZAR_INICIO:
	
		addi t6, t6, -1				# decrementa t6
	
		bne t6, zero, LOOP_RENDERIZAR_PROF	# reinicia o loop se t6 != 0
	
	# Agora a ultima imagem do professor também deve ser impressa no frame 1
	
	# Verifica se o argumento a6 == 0, nesse caso a ultima imagem a ser mostrada é a primeira
	# do prof_carvalho_intro_animacao.bmp, com o inverso caso a6 != 0 
				
	beq a6, zero, PROF_RENDERIZAR_INICIO
		srli t5, t5, 1		# através de um shif lógico divide t5 por 2			
		# nesse caso t5 possui a area total de 1 imagem do professor	
						
		add a0, a0, t5		# passa o endereço de a0 para a 1a imagem do professor
		j PROF_RENDERIZAR_FIM
		
	PROF_RENDERIZAR_INICIO:
		# Caso a6 == 0 deve ser renderizado a aniamação inicial do professor,
		# nesse caso o endereço de a0 deve voltar uma imagem
		
		sub a0, a0, t5
	
	PROF_RENDERIZAR_FIM:
	
	li t0, 0x00100000	# soma t0 com t4 de forma que o endereço de a1 passa para o 
	add a1, t4, t0		# endereço correspondente no frame 1
	# a2 e a3 já possuem o numero de linhas e colunas da imagem
	call PRINT_IMG	
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #						
		
RENDERIZAR_RED:
	# Procedimento que imprime uma de duas imagens do RED (protagonista do jogo)
	# Esse procedimento pode imprimir a silhueta do RED ou a imagem do personagem completo dependendo 
	# do argumento
	# Em ambos os casos o procedimento usa o arquivo intro_red.data
	# Argumentos:
	#	a6 = Se 0 -> imprime a silhueta do RED
	# 	     Se qualquer outro valor -> imprime a imagem completa do RED		
		
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra				
											
	# Calcula o endereço de onde renderizar a imagem do Red no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 124 			# numero da coluna
		li a3, 34			# numero da linha
		call CALCULAR_ENDERECO
		
	mv t4, a0			# salva o endereço retornado em t4
		
	li t0, 0x00100000	# soma t0 com t4 de forma que o endereço de t4 passa para o 
	add t5, t4, t0		# endereço correspondente no frame 1		
		
		
	la a0, intro_red	# carrega a imagem
	addi a0, a0, 8		# pula para onde começa os pixels no .data	
	li a2, 73		# numero de colunas de uma imagem do RED
	li a3, 129		# numero de linhas de uma imagem do RED
		
	# verifica se o argumento a6 == 0, se sim nada precisa ser feito e o procedimento pode continuar,
	# caso contrário, é a segunda imagem do RED que deve ser renderiza, para isso é preciso avançar 
	# o endereço de a0 em a1 (linhas de uma imagem do RED) * a2 (colunas de uma imagem do RED) pixels
	beq a6, zero, PRINT_RED_SILHUETA
		mul t0, a2, a3		# t0 = a1 (linhas) * a2 (colunas)
		add a0, a0, t0		# avança o endereço de a0 em uma imagem
	
	PRINT_RED_SILHUETA:
	
	mv t6, a0			# salva o endereço de a0 em t6
		
	# Imprime a imagem do Red determinada acima em ambos os frames			
		# a0 já possui o endereço da imagem
		mv a1, t4		# move para a1 o endereço de onde renderizar a imagem no frame 0
		# a2 (numero de linhas) e a3 (numero de colunas) já possuem os valores corretos
		call PRINT_IMG
		
		mv a0, t6		# move para a0 a copia do endereço da imagem armazenada em t6
		mv a1, t5		# move para a1 o endereço de onde renderizar a imagem no frame 1
		# o valor de a2 (numero de linhas) e a3 (numero de colunas) continua o mesmo
		call PRINT_IMG
									
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret				

# ====================================================================================================== #					

RENDERIZAR_ANIMACAO_FINAL_INTRO:
	# Procedimento que imprime uma serie de imagens na tela referentes a animação final da intro,
	# nessa animação várias imagens do Red aparecem, sendo uma menor do que a outra.
	# O procedimento usa os arquivos intro_final_red.data e intro_final_red_animação.data, sendo este
	# último usado na animação em si, com as imagens colocadas de maneira sequencial tal como no procedimento
	# RENDERIZAR_ANIMACAO_PROF 

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra	
	
	# Mostrando o frame 0		
	li t0, 0xFF200604		# t0 = endereço para escolher frames 
	sb zero, (t0)			# armazena 0 no endereço de t0
																														
	# Imprimindo a intro_final_red no frame 0
		la a0, intro_final_red 		# carregando a imagem em a0
		li a1, 0xFF000000		# selecionando como argumento o frame 0
		call PRINT_TELA																																																												
																																																																																										
	# Espera alguns milisegundos	
		li a0, 1000			# sleep por 1 s
		call SLEEP			# chama o procedimento SLEEP		
					
	# Calcula o endereço de onde renderizar as imagens do Red no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 124 			# numero da coluna
		li a3, 34			# numero da linha
		call CALCULAR_ENDERECO
	
	mv t4, a0			# guarda o endereço em t4	
		
	la a0, intro_final_red_animacao		# carrega a imagem da animação
	addi a0, a0, 8				# pula para onde começa os pixels no .data	
	li a2, 73				# numero de colunas de uma imagem do RED
	li a3, 129				# numero de linhas de uma imagem do RED
	
	mul t5, a2, a3		# t5 = a2 * a3 = colunas * linhas = area total de uma imagem do RED
	
	li t6, 7		# t6 = numero de loops a serem executados = numero de imagens do RED
	
	LOOP_RENDERIZAR_RED:
		# a0 já possui o endereço da imagem
		mv a1, t4		# move para a1 o endereço no bitmap onde a imagem será impressa
		# a2 e a3 já possuem o numero de linhas e colunas da imagem
		call PRINT_IMG
		
		mv t2, a0		# guarda o endereço de a0 em t0
		
		# Espera alguns milisegundos	
			li a0, 600			# sleep por 600 ms
			call SLEEP			# chama o procedimento SLEEP		
	
		mv a0, t2		# volta o endereço de t0 para a0

		addi t6, t6, -1				# decrementa t6
	
		bne t6, zero, LOOP_RENDERIZAR_RED	# reinicia o loop se t6 != 0
	
						
	# Espera alguns milisegundos	
		li a0, 1000			# sleep por 1 s
		call SLEEP			# chama o procedimento SLEEP		
																
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret				
																																																																																																																																																																																																																																																																																																																																																																						
# ====================================================================================================== #					
 
.data
	.include "../Imagens/intro_historia/intro_prof_carvalho.data"
	.include "../Imagens/intro_historia/intro_dialogos.data"
	.include "../Imagens/intro_historia/prof_carvalho_intro_animacao.data"
	.include "../Imagens/intro_historia/intro_red.data"
	.include "../Imagens/intro_historia/intro_blue.data"
	.include "../Imagens/intro_historia/intro_final_red.data"
	.include "../Imagens/intro_historia/intro_final_red_animacao.data"
	.include "../Imagens/outros/seta_dialogo.data"
