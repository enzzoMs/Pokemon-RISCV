.text

# ====================================================================================================== # 
# 						TELA INICIAL				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Código responsável por renderizar a tela inicial do jogo, incluindo pequenas animações.                # 
#													 #
# ====================================================================================================== #


INICIALIZAR_TELA_INICIAL:

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, 0(sp)		# empilha ra

	call RENDERIZAR_ANIMACAO_FAIXA
	
	# Espera alguns milisegundos	
		li a7, 32			# selecionando syscall sleep
		li a0, 500			# sleep por 500 ms
		ecall
	
	call RENDERIZAR_ANIMACAO_POKEMONS
	
	call MOSTRAR_TELA_INICIAL
	
	call MOSTRAR_TELA_CONTROLES

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
	

# ------------------------------------------------------------------------------------------------------ #

RENDERIZAR_ANIMACAO_FAIXA:

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Antes de mostrar a tela inicial ocorre uma pequena animação onde as imagem do bulbasaur e 
	# charizard são atravessadas por uma faixa branca, esse procedimento é responsável por executá-la

	# Imprimindo a tela de pré animação
		la a0, pre_animacao_inicial	# carrega a imagem
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		call PRINT_TELA	
	
	# Mostrando o frame 1		
		li t0, 0xFF200604		# t0 = endereço para escolher frames 
		li t1, 1
		sb t1, (t0)			# armazena 0 no endereço de t0
		#call TROCAR_FRAME
		
	# Espera alguns milisegundos			
		li a7, 32			# selecionando syscall sleep
		li a0, 1000			# sleep por 1 ms
		ecall
		
		
	# Calcula o endereço do final da imagem do bulbasaur
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		li a2, 3 			# coluna = 3
		li a3, 199			# linha = 199
		call CALCULAR_ENDERECO

		mv a4, a0			# coloca o retorno do procedimento chamado acima em a4

	# Calcula o endereço do final da imagem do charizard
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		li a2, 206 			# coluna = 206
		li a3, 199			# linha = 199
		call CALCULAR_ENDERECO

		mv a5, a0			# coloca o retorno do procedimento chamado acima em a5


	# Renderizando faixa
		li a6, 115			# numero de vezes que a faixa será renderizada
		
		
	LOOP_RENDERIZAR_FAIXA:
		# Espera alguns milisegundos	
		li a7, 32			# selecionando syscall sleep
		li a0, 1			# sleep por 1 ms
		ecall
	
		# renderizando a faixa no bulbasaur
		mv a1, a4			# a1 = a4 = endereco de onde colocar a faixa
		la a0, animacao_faixa		# carrega a imagem da faixa	
		call PRINT_FAIXA
		
		# renderizando a faixa no charizard
		mv a1, a5			# a1 = a5 = endereco de onde colocar a faixa
		la a0, animacao_faixa		# carrega a imagem da faixa	
		call PRINT_FAIXA
		
		addi a4, a4, -320		# passando o endereco da faixa para a linha anterior
		addi a5, a5, -320		# passando o endereco da faixa para a linha anterior
		addi a6, a6, -1			# decrementa a6
		
		bne a6, zero, LOOP_RENDERIZAR_FAIXA	# verifica se a6 == 0 para terminar o loop
			
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
				
	ret


# ------------------------------------------------------------------------------------------------------ #

PRINT_FAIXA:

	# Procedimento auxiliar ao RENDERIZAR_ANIMACAO_FAIXA que imprime a faixa no bitmap, a diferença 
	# desse procedimento para o PRINT_IMG é que a faixa é impressa somente onde os bits não são pretos, 
	# de forma a aparecer o contorno do bulbasaur e charizard
	
	# Argumentos: 
	# 	a0 = endereço da imgagem		
	# 	a1 = endereço de onde, no frame escolhido, a imagem deve ser renderizada
	
	lw t0, 0(a0)		# t0 = largura da imagem / numero de colunas da imagem
	lw t1, 4(a0)		# t1 = altura da imagem / numero de linhas da imagem
	
	addi a0, a0, 8		# pula para onde começa os pixels no .data

	li t2, 0		# contador para o numero de linhas ja impressas
	
	PRINT_LINHAS_FAIXA:
		li t3, 0		# contador para o numero de colunas ja impressas
		mv t4, a1		# copia do endereço de a1 para usar no loop de colunas
			
		PRINT_COLUNAS_FAIXA:
			lb t5, (a0)			# pega 1 pixel do .data e coloca em t5
			
			lb t6, (t4)			# pega 1 pixel do bitmap

			beq t6, zero, NAO_COLOCAR_PIXEL	# renderiza a faixa somente se o pixel não for preto
			sb t5, 0(t4)			# pega o pixel de t5 e coloca no bitmap
	
			NAO_COLOCAR_PIXEL:
			addi t3, t3, 1			# incrementando o numero de colunas impressas
			addi a0, a0, 1			# vai para o próximo pixel da imagem
			addi t4, t4, 1			# vai para o próximo pixel do bitmap
			bne t3, t0, PRINT_COLUNAS_FAIXA	# reinicia o loop se t3 != t0
			
		addi t2, t2, 1				# incrementando o numero de linhas impressas
		addi a1, a1, 320			# passa o endereço do bitmap para a proxima linha
		bne t2, t1, PRINT_LINHAS_FAIXA	        # reinicia o loop se t2 != t1
			
	ret

# ------------------------------------------------------------------------------------------------------ #

RENDERIZAR_ANIMACAO_POKEMONS:

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Depois de RENDERIZAR_ANIMACAO_FAIXA esse procedimento realiza também uma pequena animação onde
	# o charizard e bulbasaur vão lentamente sendo mostrados na tela

	# Calcula o endereço do começo da imagem do bulbasaur
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		li a2, 3 			# coluna = 3
		li a3, 115			# linha = 115
		call CALCULAR_ENDERECO

		mv a4, a0			# salva o retorno do procedimento chamado acima em a4

	# Calcula o endereço do começo da imagem do charizard
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		li a2, 206 			# coluna = 206
		li a3, 99			# linha = 99
		call CALCULAR_ENDERECO

		mv a5, a0			# salva o retorno do procedimento chamado acima em a5


	# Imprimindo bulba_0
	la a0, bulba_0		# carregando a imagem bulba_0
	mv a1, a4		# a1 = argumento com a posicao onde a imagem do bulbasur será impressa
	call PRINT_IMG		
		
	# Imprimindo chari_0
	la a0, chari_0		# carregando a imagem chari_0
	mv a1, a5		# a5 = argumento com a posicao onde a imagem do charizard será impressa
	call PRINT_IMG	
	
	# Espera alguns milisegundos	
	li a7, 32		# selecionando syscall sleep
	li a0, 1000		# sleep por 1 s
	ecall
	
	# -------------------------------------------------------------------------------------------- #

	# Imprimindo bulba_1
	la a0, bulba_1		# carregando a imagem bulba_1
	mv a1, a4		# a1 = argumento com a posicao onde a imagem do bulbasur será impressa
	call PRINT_IMG		
		
	# Imprimindo chari_1
	la a0, chari_1		# carregando a imagem chari_1
	mv a1, a5		# a5 = argumento com a posicao onde a imagem do charizard será impressa
	call PRINT_IMG	
	
	# Espera alguns milisegundos	
	li a7, 32		# selecionando syscall sleep
	li a0, 1000		# sleep por 1 s
	ecall
	
	# -------------------------------------------------------------------------------------------- #

	# Imprimindo bulba_2
	la a0, bulba_2		# carregando a imagem bulba_2
	mv a1, a4		# a1 = argumento com a posicao onde a imagem do bulbasur será impressa
	call PRINT_IMG		
		
	# Imprimindo chari_2
	la a0, chari_2		# carregando a imagem chari_2
	mv a1, a5		# a5 = argumento com a posicao onde a imagem do charizard será impressa
	call PRINT_IMG	
	
	# Espera alguns milisegundos	
	li a7, 32		# selecionando syscall sleep
	li a0, 1000		# sleep por 1 s
	ecall
	
	# -------------------------------------------------------------------------------------------- #

	# Imprimindo bulba_3
	la a0, bulba_3		# carregando a imagem bulba_3
	mv a1, a4		# a1 = argumento com a posicao onde a imagem do bulbasur será impressa
	call PRINT_IMG		
		
	# Imprimindo chari_3
	la a0, chari_3		# carregando a imagem chari_3
	mv a1, a5		# a5 = argumento com a posicao onde a imagem do charizard será impressa
	call PRINT_IMG	
	
	# Espera alguns milisegundos	
	li a7, 32		# selecionando syscall sleep
	li a0, 1000		# sleep por 1 s
	ecall
	
	# -------------------------------------------------------------------------------------------- #

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
				
	ret

# ====================================================================================================== #

MOSTRAR_TELA_INICIAL:

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Imprimindo a tela inicial no frame 1
		la a0, tela_inicial		# carregando a imagem da tela inicial
		li a1, 0xFF100000		# selecionando como argumento o frame 1
		call PRINT_TELA

	# Imprimindo a tela inicial no frame 0
		la a0, tela_inicial		# carregando a imagem da tela inicial
		li a1, 0xFF000000		# selecionando como argumento o frame 0
		call PRINT_TELA
	
	# Para o frame 0 a tela inicial não terá o texto "Aperte Enter", para isso é necessário substituir o
	# texto por um retangulo preto:
	
	# Calcula o endereço do texto "Aperte Enter"
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 127 			# coluna = 127
		li a3, 185			# linha = 185
		call CALCULAR_ENDERECO
	
	li t0, 63		# t0 = largura do texto / numero de colunas = 63
	li t1, 19		# t1 = altura do texto / numero de linhas = 19
	
	li t2, 0		# contador para o numero de linhas ja impressas
	
	# O loop abaixo substitui o texto por um retangulo preto
	
	REMOVE_TEXTO_LINHAS:
		li t3, 0		# contador para o numero de colunas ja impressas
		addi t4, a0, 0		# copia do endereço de a0 para usar no loop de colunas
			
		REMOVE_TEXTO_COLUNAS:
			sb zero, 0(t4)				# bota um pixel preto no bitmap
	
			addi t3, t3, 1				# incrementando o numero de colunas impressas
			addi t4, t4, 1				# vai para o próximo pixel do bitmap
			bne t3, t0, REMOVE_TEXTO_COLUNAS	# reinicia o loop se t3 != t0
			
		addi t2, t2, 1				# incrementando o numero de linhas impressas
		addi a0, a0, 320			# passa o endereço do bitmap para a proxima linha
		bne t2, t1, REMOVE_TEXTO_LINHAS	        # reinicia o loop se t2 != t1
	
	# O loop abaixo alterna constantemente entre o frame 0 e o 1 enquanto espera que o 
	# usuario aperte ENTER
	
	LOOP_FRAME_TELA_INICIAL:
		# Espera alguns milisegundos	
		li a7, 32			# selecionando syscall sleep
		li a0, 450			# sleep por 450 ms
		ecall
		
		call TROCAR_FRAME
		
		call VERIFICAR_TECLA			# verifica se alguma tecla foi apertada	
		li t0, 10				# t0 = valor da tecla enter
		bne a0, t0, LOOP_FRAME_TELA_INICIAL	# se a0 = t0 -> tecla Enter foi apertada
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #

MOSTRAR_TELA_CONTROLES:

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Mostrando o frame 0		
	li t0, 0xFF200604		# t0 = endereço para escolher frames 
	sb zero, (t0)			# armazena 0 no endereço de t0

	# Imprimindo a tela de controles no frame 1
	la a0, tela_controles		# carregando a imagem em a0
	li a1, 0xFF100000		# selecionando como argumento o frame 1
	call PRINT_TELA
	
	# Na tela de controles tem uma pequena animação de uma seta vermelha oscilando na tela,
	# para isso a tela_controles também será impressa no frame 0
	
	# Imprimindo a tela de controles no frame 0
	la a0, tela_controles		# carregando a imagem em a0
	li a1, 0xFF000000		# selecionando como argumento o frame 0
	call PRINT_TELA
	
	# Porém, no frame 0 essa seta deverá estar um pouco mais para cima:
	
	# Calcula o endereço do inicio da seta
	li a1, 0xFF000000		# seleciona como argumento o frame 0
	li a2, 296 			# coluna = 296
	li a3, 220			# linha = 220
	call CALCULAR_ENDERECO
	# como retorno a0 = endereço da imagem da seta
	
	li t0, 18		# t0 = largura da seta / numero de colunas = 18
	li t1, 15		# t1 = altura da seta / numero de linhas = 15
	
	li t2, 0		# contador para o numero de linhas ja impressas
	
	mv a1, a0		# a1 = endereço de onde a seta deve ser renderizada
	addi a1, a1, -640	# sobe esse endereço 2 linhas para cima (320 * 2)
	
	# Dessa forma, o loop abaixo imprime a mesma seta só que duas 2 linhas para cima no frame 0														
	PRINT_SETA_LINHAS:
		li t3, 0		# contador para o numero de colunas ja impressas
		mv t4, a1		# copia do endereço de a1 para usar no loop de colunas
		mv t5, a0 		# copia do endereço de a0 para usar no loop de colunas
		
		PRINT_SETA_COLUNAS:
			lb t6, 0(t5)			# pega 1 pixel da imagem e coloca em t6
			sb t6, 0(t4)			# pega o pixel de t6 e coloca no bitmap
	
			addi t3, t3, 1			# incrementando o numero de colunas impressas
			addi t5, t5, 1			# vai para o próximo pixel da imagem
			addi t4, t4, 1			# vai para o próximo pixel do bitmap
			bne t3, t0, PRINT_SETA_COLUNAS	# reinicia o loop se t3 != t0
			
		addi t2, t2, 1				# incrementando o numero de linhas impressas
		addi a1, a1, 320			# passa o endereço do bitmap para a proxima linha
		addi a0, a0, 320			# passa o endereço da imagem para a proxima linha	
		bne t2, t1, PRINT_SETA_LINHAS	        # reinicia o loop se t2 != t1	
	
	# O loop abaixo alterna constantemente entre o frame 0 e o 1 enquanto espera que o 
	# usuario aperte ENTER
		
	LOOP_TELA_CONTROLES:
		# Espera alguns milisegundos	
			li a7, 32			# selecionando syscall sleep
			li a0, 450			# sleep por 450 ms
			ecall
		
		call TROCAR_FRAME
		
		call VERIFICAR_TECLA			# verifica se alguma tecla foi apertada	
		li t0, 10				# t0 = valor da tecla enter
		bne a0, t0, LOOP_TELA_CONTROLES		# se a0 = t0 -> tecla Enter foi apertada
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #

.data
	.include "../Imagens/tela_inicial/pre_animacao_inicial.data"
	.include "../Imagens/tela_inicial/animacao_faixa.data"
	.include "../Imagens/tela_inicial/bulba_0.data"
	.include "../Imagens/tela_inicial/chari_0.data"	
	.include "../Imagens/tela_inicial/bulba_1.data"
	.include "../Imagens/tela_inicial/chari_1.data"	
	.include "../Imagens/tela_inicial/bulba_2.data"
	.include "../Imagens/tela_inicial/chari_2.data"	
	.include "../Imagens/tela_inicial/bulba_3.data"	
	.include "../Imagens/tela_inicial/chari_3.data"
	.include "../Imagens/tela_inicial/tela_inicial.data"
	.include "../Imagens/tela_inicial/tela_controles.data"
	
	.include "procedimentos_auxiliares.s"
	
	
