.text

# ====================================================================================================== # 
# 						   AREAS				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo possui os procedimentos necesários para renderizar as diferentes áreas do jogo, fazendo   #
# as alterações necessárias nos registradores s1 (orientação do personagem), s2 (endereço da subseção da #
# area atual onde o personagem está), s3 (tamanho de uma linha da área atual), s4 (posição na matriz de  #
# movimentação) e s5 (tamanho de linha na matriz)			  				 #
#            												 #	 
# Além disso, esse arquivo também contém os procedimentos para realizar as transições entre área.	 #
# A transição entre uma área e outra acontece quando o jogador se encontra em uma posição especial na	 #
# matriz de movimentação de uma área.									 #
# Os procedimentos de movimentação vão verificar o valor da próxima posição do personagem na matriz de   #
# movimentação, caso o valor dessa posição seja maior ou igual a 128 (1000_0000 em binário) os 		 #
# procedimentos de transição de área serão chamados.							 #		 #
# A razão para esse número é que o byte desses elementos especiais é codificado em binário no seguinte   #
# formato 1_YY_AAA_PP, onde:									         #
# 	 1... -> 1 bit fixo que indica que essa posição se trata de uma transição para outra área +  	 #
#	   YY -> 2 bits identificando o modo como o personagem está indo, por escadas ou por uma porta,  #
# 		por exemplo, +										 #
# 	  AAA -> 3 bits identificando a área para onde o personagem está indo +				 #
#	   PP -> 2 bits que indicam por qual ponto de entrada o personagem vai entrar na área 		 #
#													 #
# Então cada elemento de transição da matriz guarda as informações necessárias para que os procedimentos #
# saibam o que fazer.											 #
# Os possíveis valores de AAA e YY podem ser encontrados abaixo:					 #
# 	Áreas (AAA): 										 	 #
#		Quarto do RED -> 000									 #
#		Sala da casa do RED -> 001								 #
#													 #
#	Maneiras de fazer a transição entre áreas (YY):							 #
#		Por escada, descendo -> 00 								 #
#		Por escada, subindo -> 01 								 #
#		Entrando por uma porta -> 10 								 #
#		Nada deve acontecer na trasição -> 11 							 #
# 													 #
# Já os valores de PP variam dependendo da área. Algumas áreas possuem mais de uma maneira de acessa-las #
# a sala do RED, por exemplo, pode ser acessada tanto pelo quarto do RED ou pela porta da frente, nesse  #
# caso PP indica por qual entrada o personagem vai acessar a área:					 #
#	Quarto do RED:											 #
#		PP = 00 -> Entrada por lugar nenhum (quando o jogo começa)				 #
#		PP = 01 -> Entrada pelas escadas							 #
#	Sala do RED:											 #
#		PP = 00 -> Entrada pela porta da frente							 #
#		PP = 01 -> Entrada pelas escadas							 #
#            												 #	 
# ====================================================================================================== #

RENDERIZAR_AREA:
	# Procedimento principal de areas.s, coordena a renderização de áreas e a transição entre elas
	# Argumentos:
	# 	a0 = número codificando as informações de renderização de área, ou seja, um número em que 
	# 	todos os bits são 0, exceto o byte menos significativo, que segue o formato 1YYAAAPP onde 
	# 	AAA é o código da área a ser renderizada, YY como a transição para essa área será feita e PP o 
	# 	ponto de entrada na área.
	# 	Para mais explicações ler texto acima.
	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Primeiro verifica a transição a ser feita (YY)
		andi t0, a0, 0x60	# fazendo o AND de a0 com 0x60, que é 0110_000 em binário, deixa 
					# somente os dois bits de a0 que devem ser de YY intactos, 
					# enquanto o restante fica todo 0
		
		# checagem de transições deve acontecer aqui		
		
	# Agora é necessário verificar a área a ser renderizada (YYY)
		# Para usar como argumento nos procedimentos de renderização de áreas é necessário
		# separar também o PP (ponto de entrada da área)
	
		andi t0, a0, 3		# fazendo o AND de a0 com 3, 011 em binário, deixa somente os dois 
					# primeiros bits de a0 intactos, enquanto o restante fica todo 0
		
		# Agora Separando o campo AAA
			
		andi t1, a0, 0x1C	# fazendo o AND de a0 com 0x1C, 0001_1100 em binário, deixa somente os 
					# bits de a0 que devem ser de AAA intactos, enquanto o restante 
					# fica todo 0	
	
		# Agora o procedimento de renderização de área adequado será chamado de acordo com AAA
		mv a0, t0	# move para a0 o valor de PP para que a0 possa ser usado como 
				# argumento nos procedimentos de renderização de área
		
		# se t1 (AAA) = 000 renderiza o quarto do RED
		beq t1, zero, RENDERIZAR_QUARTO_RED


	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #
RENDERIZAR_QUARTO_RED:
	# Procedimento que imprime a imagem do quarto do RED e o sprite do RED no frame 0 e no frame 1 de 
	# acordo com o ponto de entrada, além de atualizar os registradores salvos
	# Argumentos:
	# 	a0 = indica o ponto de entrada na área, ou seja, por onde o RED está entrando nessa área
	#	Para essa área os pontos de entrada possíveis são:
	#		PP = 00 -> Entrada por lugar nenhum (quando o jogo começa)	
	#		PP = 01 -> Entrada pelas escadas

	# OBS: não é necessário empilhar o valor de ra pois a chegada a este procedimento é por meio
	# de uma instrução de branch e a saída é pelo último ra empilhado
			
	# Atualizando os registradores salvos para essa área
		# Atualizando o valor de s1 (orientação do personagem)
		li s1, 2	# inicialmente virado para cima
		
		# Atualizando o valor de s2 (endereço da subsecção onde o personagem está na área atual) e
		# s3 (tamanho de uma linha da área atual)
		la s2, casa_red_quarto		# carregando em s2 o endereço da imagem da área
		
		lw s3, 0(s2)			# s3 recebe o tamanho de uma linha da imagem da área
		
		addi s2, s2, 8			# pula para onde começa os pixels no .data
		
		li t0, 24000			# 40 * 600 = 24.000, move o endereço de s2 algumas linhas para
		add s2, s2, t0			# baixo, de modo que s2 tem o endereço da subsecção onde o
						# personagem vai estar
						
		# Atualizando o valor de s4 (posição atual na matriz de movimentação da área) e 
		# s5 (tamanho de linha na matriz)	
		la t0, matriz_casa_red_quarto	
		
		lw s5, 0(t0)			# s5 recebe o tamanho de uma linha da matriz da área
				
		addi t0, t0, 8
	
		addi s4, t0, 72		# o personagem começa na linha 10 e coluna 8 da matriz
					# então é somado o endereço base da matriz (t0) a 
		addi s4, s4, 1		# 10 (número da linha) * 18 (tamanho de uma linha da matriz) 
					# e a 8 (número da coluna) 
											
	# Imprimindo as imagens da área e o sprite inicial do RED no frame 0					
		# Imprimindo a casa_red_quarto no frame 0
		mv a0, s2		# move para a0 o endereço de s2
		li a1, 0xFF000000	# selecionando como argumento o frame 0
		li a2, 600		# 600 = tamanho de uma linha da imagem dessa área
		call PRINT_AREA		
			
		# Imprimindo a imagem do RED virado para cima no frame 0
		la a0, red_cima		# carrega a imagem				
		mv a1, s0		# move para a1 o endereço de s0 (endereço de onde o RED fica na tela)
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	

	# Imprimindo as imagens da área e o sprite inicial do RED no frame 1					
		# Imprimindo a casa_red_quarto no frame 1
		mv a0, s2		# move para a0 o endereço de s2
		li a1, 0xFF100000	# selecionando como argumento o frame 1
		li a2, 600		# 600 = tamanho de uma linha da imagem dessa área
		call PRINT_AREA		
			
		# Imprimindo a imagem do RED virado para cima no frame 1
		la a0, red_cima		# carrega a imagem				
		mv a1, s0		# move para a1 o endereço de s0 (endereço de onde o RED fica na tela)
		
		li t0, 0x00100000	# passa o endereço de a1 para o equivalente no frame 1
		add a1, a1, t0
			
		lw a2, 0(a0)		# numero de colunas de uma imagem do RED
		lw a3, 4(a0)		# numero de linhas de uma imagem do RED	
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
				
	# Mostra o frame 0		
	li t0, 0xFF200604		# t0 = endereço para escolher frames 
	sb zero, (t0)			# armazena 0 no endereço de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret

# ====================================================================================================== #					
 
.data
	.include "../Imagens/areas/casa_red_quarto.data"
	.include "../Imagens/areas/matriz_casa_red_quarto.data"
