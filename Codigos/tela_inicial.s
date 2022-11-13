.text

# ====================================================================================================== # 
# 						TELA INICIAL				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Código responsável por renderizar a tela inicial do jogo, incluindo pequenas animações.                # 
#													 #
# ====================================================================================================== #


CARREGAR_TELA_INICIAL:

	mv tp, ra	# salvando endereco de retorno em tp

	call RENDERIZAR_ANIMACAO_FAIXA
	
	mv ra, tp	# ra recebe o endereco que foi salvo em tp
	
	ret
	

# ------------------------------------------------------------------------------------------------------ #

RENDERIZAR_ANIMACAO_FAIXA:

	# Antes de mostrar a tela inicial ocorre uma pequena animação onde as imagem do bulbasaur e 
	# charizard são atravessadas por uma faixa branca

	# Imprimindo a tela de pré animação
		la a0, pre_animacao_inicial	# carrega a imagem
		li a1, 0xFF100000		# seleciona como argumento o frame 1
		call PRINT_TELA	
	
	call TROCAR_FRAME 			# trocando o frame para o 1
		
		
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
		li a7, 32			# selecionando syscall sleep
		li a0, 1			# sleep por 1 ms
		ecall
	
		# renderizando a faixa no bulbasaur
		mv a1, a4			# a1 = a4 = endereco de onde colocar a faixa
		la a0, animacao_faixa		# carrega a imagem da faixa	
		call RENDERIZAR_FAIXA
		
		# renderizando a faixa no charizard
		mv a1, a5			# a1 = a5 = endereco de onde colocar a faixa
		la a0, animacao_faixa		# carrega a imagem da faixa	
		call RENDERIZAR_FAIXA
		
		addi a4, a4, -320		# passando o endereco da faixa para a linha anterior
		addi a5, a5, -320		# passando o endereco da faixa para a linha anterior
		addi a6, a6, -1			# decrementa a6
		
		bne a6, zero, LOOP_RENDERIZAR_FAIXA	# verifica se a6 == 0 para terminar o loop
			
	ret


# ------------------------------------------------------------------------------------------------------ #

RENDERIZAR_FAIXA:

	# Procedimento que imprime a faixa no bitmpa, a diferenca desse procedimento para o PRINT_IMG
	# é que a faixa é impressa somente onde os bits não são pretos, de forma a aparecer o contorno
	# do bulbasaur e charizard
	
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


# ====================================================================================================== #

.data
	.include "../Imagens/tela_inicial/pre_animacao_inicial.data"
	.include "../Imagens/tela_inicial/animacao_faixa.data"
	
	.include "procedimentos_auxiliares.s"
	
	
