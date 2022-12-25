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
	# Procedimento que imprime imagens de tamanho variado, menores que 320 x 240, no frame de escolha
	# Argumentos: 
	# 	a0 = endereço da imgagem		
	# 	a1 = endereço de onde, no frame escolhido, a imagem deve ser renderizada
	# 	a2 = numero de colunas da imagem
	#	a3 = numero de linhas da imagem
	
	li t0, 0		# contador para o numero de linhas ja impressas
	
	PRINT_IMG_LINHAS:
		li t1, 0		# contador para o numero de colunas ja impressas
			
		PRINT_IMG_COLUNAS:
			lb t2, 0(a0)			# pega 1 pixel do .data e coloca em t3
			sb t2, 0(a1)			# pega o pixel de t3 e coloca no bitmap
	
			addi t1, t1, 1			# incrementando o numero de colunas impressas
			addi a0, a0, 1			# vai para o próximo pixel da imagem
			addi a1, a1, 1			# vai para o próximo pixel do bitmap
			bne t1, a2, PRINT_IMG_COLUNAS	# reinicia o loop se t1 != t2
			
		addi t0, t0, 1			# incrementando o numero de linhas impressas
		sub a1, a1, a2			# volta o endeço do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endereço do bitmap para a proxima linha
		bne t0, a3, PRINT_IMG_LINHAS	# reinicia o loop se t0 != a3
			
	ret

# ====================================================================================================== #

PRINT_SPRITE:
	# Esse procedimento funciona de maneira similar ao PRINT_IMG, a diferença é que possui algumas 
	# alterações específicas para a renderização dos sprites de personagens na tela.
	# Para entender esse procedimento é ncessário perceber que alguns sprites, como os do RED que podem
	# ser encontrados em "../Imagens/red", possuem um fundo rosa, com base nisso, o que esse procedimento
	# faz é imprimir um sprite na tela, porém ao invés de imprimir esses pixels rosas ele imprime os 
	# pixels correspondentes de uma área, ou seja, podemos pensar que esse procedimento imprime um
	# sprite emulando uma espécie de transparência.
	# Essa obordagem foi utilizada porque usar somente pixels com a cor transparente (0xC7) 
	# não estava funcionando tão bem assim nas animações de movimentação. O uso desse procedimento
	# elimina a maior parte (mas não toda) da necessidade de fazer algum tipo de "limpeza" na tela para 
	# remover os sprites antigos, resolvendo grande parte desses problemas. 
	# Esse procedimento é usado nas animações de movimentação, para simplesmente imprimir o sprite de
	# um personagem / objeto na tela sem se preocupar em limpar a tela depois pode ser usado também
	# o procedimento PRINT_IMG
	# O procedimento parte do pressuposto que todos os sprites de personagens tem o mesmo tamanho: 
	# 26 (colunas) x 32 (linhas)
	# Argumentos: 
	# 	a0 = endereço base da imagem do sprite		
	# 	a1 = endereço de onde, no frame escolhido, o sprite deve ser renderizado
	#	a2 = endereço base da área onde o sprite será renderizado
	#	a3 = número de colunas do sprite
	#	a4 = número de linhas do sprite	
	
	
	addi a2, a2, 8		# pula para onde começa os pixels no .data da imagem da área
	
	li t0, 0xFF000000	# t0 = endereço base do frame 0
	sub t0, a1, t0		# a1 (endereço de onde renderizar o sprite) - t0 (endereço base do frame 0) = 
				# quantos pixels é necessário pular na imagem da área (a2) para encontrar 
				# onde a sub imagem que será usada no procedimento 

	add a2, a2, t0		# pula para o endereço da sub imagem da área que será usada no procedimento 
	
	li t0, 0xC7		# t1 = valor da cor do pixel transparente
		
	addi a0, a0, 8		# pula para onde começa os pixels no .data do sprite
	
	PRINT_SPRITE_LINHAS:
		mv t1, a3		# t1 = copia de a3 para usar no loop de colunas
			
		PRINT_SPRITE_COLUNAS:
			lbu t2, 0(a0)			# pega 1 pixel do .data e coloca em t2
	
			# se o pixel em t2 for o transparente então ele vai ser substituido pelo
			# pixel correspondente na imagem da área passada no argumento a2
			bne t2, t0, ARMAZENAR_PIXEL_SPRITE		
				lb t2, 0(a2)	# pega 1 pixel do .data da imagem da área e coloca em t2
	
			ARMAZENAR_PIXEL_SPRITE:
			sb t2, 0(a1)		# pega 1 pixel do .data escolhido e coloca no bitmap
			
			addi t1, t1, -1				# decrementando o numero de colunas impressas
			addi a0, a0, 1				# vai para o próximo pixel da imagem do sprite
			addi a2, a2, 1				# vai para o próximo pixel da imagem da área
			addi a1, a1, 1				# vai para o próximo pixel do bitmap
			bne t1, zero, PRINT_SPRITE_COLUNAS	# reinicia o loop se t1 != 0
			
		addi a4, a4, -1			# decrementando o numero de linhas impressas
		sub a1, a1, a3			# volta o endereço do bitmap pelo número de colunas impressas
		addi a1, a1, 320		# passa o endereço do bitmap para a proxima linha
		sub a2, a2, a3			# volta o endereço da área pelo número de colunas impressas
		addi a2, a2, 320		# passa o endereço da área para a proxima linha
		bne a4, zero, PRINT_SPRITE_LINHAS	# reinicia o loop se t0 != 0
			
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
		la a0, seta_dialogo	# carrega a imagem
		# a1 tem o endereço onde a seta será renderizada
		lw a2, 0(a0)		# a1 = numero de colunas da imagem
		lw a3, 4(a0)		# a2 = numero de linhas da imagem
		addi a0, a0, 8		# pula para onde começa os pixels no .data
		call PRINT_IMG

	# Imprime a seta no frame 0
		la a0, seta_dialogo	# carrega a imagem
		mv a1, t6		# a1 tem o endereço onde a seta será renderizada
		# os valores de a2 (coluna) e a3 (linha) continuam os mesmos 
		addi a0, a0, 8		# pula para onde começa os pixels no .data
		call PRINT_IMG

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
																											
