.text

# ====================================================================================================== # 
# 						   AREAS				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo possui os procedimentos necesários para renderizar as diferentes áreas do jogo, fazendo   #
# as alterações necessárias nos registradores s0 (numero da coluna do personagem) e s1 (numero da linha) #
# do personagem, s2 (orientação do personagem) e s3 (endereço da area atula), além de imprimir os 	 #
# sprites do RED na tela.										 #
#            												 #	 
# ====================================================================================================== #

RENDERIZAR_QUARTO_RED:
	# Procedimento que imprime a imagem do quarto do RED no frame 0
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Imprimindo a casa_red_quarto no frame 0
		la a0, casa_red_quarto		# carregando a imagem em a0
		li a1, 0xFF000000		# selecionando como argumento o frame 0
		call PRINT_TELA
	
	# Atualizando os valores de s0 (coluna do personagem) e s1 (linha do personagem)
		li s0, 147
		li s1, 163

	# Atualizando o valor de s2 (orientação do personagem)
		li s2, 2	# inicialmente virado para cima
		
	# Atualizando o valor de s3 (endereço da area atual)
		la s3, casa_red_quarto		# inicialmente virado para cima
			

	# Agora é necessário renderizar o sprite do RED onde ele deve estar
		# Calcula o endereço de onde renderizar a imagem do RED no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		mv a2, s0 			# numero da coluna do RED = s0
		mv a3, s1			# numero da linha do RED = s1
		call CALCULAR_ENDERECO
		
		mv a1, a0		# move o endereço retornado para a1
		
		# Imprimindo a imagem do RED virado para cima no frame 0
		la a0, red_cima		# carrega a imagem				
		# a1 já possui o endereço de onde renderizar o RED
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
			
	j FIM_RENDERIZAR_AREA



FIM_RENDERIZAR_AREA:

	# Mostra o frame 0		
	li t0, 0xFF200604		# t0 = endereço para escolher frames 
	sb zero, (t0)			# armazena 0 no endereço de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #					
 
.data
	.include "../Imagens/areas/casa_red_quarto.data"
