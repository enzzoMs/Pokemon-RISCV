.text

# ====================================================================================================== # 
# 						INTRO HISTORIA				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Código responsável por renderizar a história introdutória do jogo.			                 # 
#													 #
# ====================================================================================================== #


INICIALIZAR_INTRO_HISTORIA:
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Espera alguns milisegundos	
		li a7, 32			# selecionando syscall sleep
		li a0, 300			# sleep por 450 ms
		ecall
		
	# Imprimindo a intro_0 no frame 0
		la a0, intro_0			# carregando a imagem em a0
		li a1, 0xFF000000		# selecionando como argumento o frame 0
		call PRINT_TELA

	# Imprimindo a intro_0 no frame 1
		la a0, intro_0			# carregando a imagem em a0
		li a1, 0xFF100000		# selecionando como argumento o frame 1
		call PRINT_TELA
	
	# Espera alguns milisegundos	
		li a7, 32		# selecionando syscall sleep
		li a0, 150		# sleep por 450 ms
		ecall
	
	# Renderiza 4 caixas de dialogo	
		la a0, intro_dialogos		# carrega o endereço da imagem 
		addi a0, a0, 8			# pula para onde começa os pixels no .data
	
		li a1, 5		# seleciona como argumento o numero de dialogos a serem renderizados
	
		call PRINT_DIALOGOS	

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret
	
# ====================================================================================================== #					

.data
	.include "../Imagens/intro_historia/intro_0.data"
	.include "../Imagens/intro_historia/intro_dialogos.data"
	.include "../Imagens/outros/seta_dialogo.data"
