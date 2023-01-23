.text

# ====================================================================================================== # 
# 						 HISTORIA				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Código com os procedimentos necessários para renderizar os momentos de história do jogo, incluindo	 #
# imprimir caixas de diálogo e executar algumas animações 						 #
#													 #
# Esse arquivo possui 3 procedimentos principais, um para cada momento de história do jogo:		 #
#	RENDERIZAR_ANIMACAO_PROF_OAK, ...								 #
#													 #
# ====================================================================================================== #

RENDERIZAR_ANIMACAO_PROF_OAK:
	# Esse procedimento é chamado quando o RED tenta pela primeira vez sair da área principal de Pallet
	# e andar sobre um tile de grama. Quando o jogador passa por esses tiles existe a chance de um 
	# Pokemon aparecer e iniciar uma batalha, mas como na primeria vez o jogador ainda não tem Pokemon 
	# ele precisa ir ao laboratório. Portanto, esse procedimento renderiza a animação do Professor 
	# Carvalho indo ao jogador, renderiza o dialógo explicando que o RED tem que escolher seu Pokemon 
	# inicial, e depois renderiza a animação do professor voltando de onde ele veio.

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, 0(sp)		# empilha ra
	
	# Espera alguns milisegundos	
		li a0, 1000			# sleep 1 s
		call SLEEP			# chama o procedimento SLEEP	
		
	# Como primeira parte da animaçaõ é necessário imprimir um balão de exclamação sobre a cabeça do RED
	# no frame 0. O balão funciona que nem um tile normal, a diferença é que tem fundo transparentes
	
	mv a0, s0			# calcula o endereço de inicio do tile onde a cabeça do RED está (s0)
	call CALCULAR_ENDERECO_DE_TILE	
	
	# Imprimindo o balão de exclamação no frame 1			
		la a0, balao_exclamacao		# carrega a imagem
		addi a0, a0, 8			# pula para onde começa os pixels no .data
		# do retorno do procedimento CALCULAR_ENDERECO_DE_TILE a1 já tem o endereço de inicio 
		# do tile onde a cabeça do RED está 
		li a2, 16			# a2 = numero de colunas de um tile
		li a3, 16			# a3 = numero de linhas de um tile
		call PRINT_IMG

	# Espera alguns milisegundos	
		li a0, 1000			# sleep 1 s
		call SLEEP			# chama o procedimento SLEEP	
	
	# Imprime o dialogo inicial do professor
	la a4, matriz_dialogo_oak_1	# carrega a matriz de tiles do dialogo
	li a5, 1			# renderiza 1 dialogo		
	call RENDERIZAR_DIALOGOS
	
	# Agora é necessário trocar a orientação do RED para que ele fique virado para baixo
			
	la a4, red_baixo	# carrega como argumento o sprite do RED virada para baixo		
	call MUDAR_ORIENTACAO_RED
			
	li s1, 3	# atualiza o valor de s1 dizendo que agora o RED está virado para baixo
	
	# Obs: a mudança de orientação naturalmente vai retirar a imagem do balão de exclamação
	
	# Agora começa a animação do professor Carvalho
	# Na primeira parte o sprite do professor dando um passo para cima será lentamente impressa,
	# pixel por pixel, na tela, dando a impressão de que o professor está entrando em cena
	
	# O endereço onde o sprite do professor será impresso depende da posição do RED.
	
	li t0, 41600	# 41600 = 130 linhas * 320 (tamanho de uma linha do frame)
	
	add t3, s0, t0	# o endereço do professor está sempre a 130 linhas do RED (s0)
	
	# O endereço do professor pode ainda estar a -16 ou -32 colunas do RED dependendo de onde ele está
	# Para definir isso é possível usar a matriz de movimentação e checar a posição a esquerda do RED
	
	addi t3, t3, -16	# primeiro move o endereço de t3 para 16 a esquerda
	
	lb t0, -1(s6)	# checa na matriz de movimentação a posição a esquerda do RED  
	
	li t1, 16	# multiplicando 16 pelo valor lido em t0 retorna a quantidade certa de pixels (0 ou 
	mul t0, t0, t1	# 16) que é necessário subtrair do endereço de t3
	sub t3, t3, t0 
		
	
	# Imprimindo o sprite do professor entrando em cena
	
	mv t4, t3	# faz uma copia do endereço de t3 em t4
			# essa copia guarda o endereço do tile inicial onde o sprite do professor foi renderizado
			
		
	li t5, 0		# contador para o numero de loops feitos
				
	li t6, 0x00100000	# t6 será usada para fazer a troca entre frames no loop de movimentação	
				# O loop abaixo começa imprimindo os sprites no frame 1 já que se parte
				# do pressuposto de que o frame 0 é o que está sendo mostrado
				
	LOOP_PROFESSOR_ENTRANDO:
		# Limpa o tile onde o professor será renderizado
		mv a0, t4			# encontra o endereço do tile na matriz e o endereço do
		call CALCULAR_ENDERECO_DE_TILE	# frame onde o sprite foi renderizado
	
		# Agora imprime o tile e limpa a tela
		mv a0, a2	# pelo retorno do procedimento chamado acima a2 tem o endereço da imagem do 
				# tile correspondente a t4
		# pelo retorno do procedimento a1 tem o endereço de inicio do tile no frame 0
		add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# será impressa			
		li a2, 16		# numero de colunas de um tile
		li a3, 16		# numero de linhas de um tile
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG			
	
	
		# Agora imprime a imagem do professor no frame
		la a0, oak_cima_passo_esquerdo	# carrega o sprite do professor	
		mv a1, t3		# t3 possui o endereço de onde renderizar o sprite
		add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# será impressa			
		lw a2, 0(a0)		# numero de colunas de uma imagem do professor
		addi a3, t5, 1		# o numero de linhas a serem impressas depende do numero da iteração
					# + 1 (porque t5 começa no 0)
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
	
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado
			
		li t0, 0x00100000	# com essa operação xor se t6 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# ficar alternando entre esses valores
		
		addi t3, t3, -320	# volta o endereço de onde imprimir o professor para linha acima			
											
		addi t5, t5, 1		# incrementa o numero de loops restantes
		li t0, 20		# 20 é a altura do sprite do professor 
		bne t5, t0, LOOP_PROFESSOR_ENTRANDO	# reinicia o loop se t5 != 20
	
	addi t3, t3, 320	# na ultima iteração o valor de t3 é decrementado mais uma vez desnecessariamente
				# portanto, é necessário reverter essa mudança 				

	# Agora realiza a animação de movimentação do professor 
	
	mv a0, t3		# dos calculos acima t3 ainda tem a posição do ultimo sprite do 
				# professor no frame 0 
	
	li t6, -1		# contador para o loop abaixo, de modo que cada loop representa uma movimentação
				# do professor em alguma orientação

	LOOP_ANIMACAO_PROFESSOR:
	
	addi t6, t6, 1		# incrementa o numero de loops feitos
	
	# Primeiro determina qual é o sentido da movimentação do professor de acordo com o numero da iteração,
	# de modo que a animação siga o seguinte padrão:
	# Prof sobe até o RED -> DIALOGO DO PROFESSOR -> Prof sai da área dependendo de onde o RED está
	li t0, 3		
	ble t6, t0, MOVER_PROFESSOR_CIMA
	
	addi t0, t0, 1 			# a movimentação do professor para a direita depende de onde o RED 
	lb t1, -1(s6)			# está. Para decidir isso é possível utilizar o valor da posição a 
	add t0, t0, t1			# esquerda de onde ele está na matriz de movimentação. 
					# Obs: essa posição da matriz só pode ter 0 ou 1 
	ble t6, t0, MOVER_PROFESSOR_DIREITA
	
	addi t0, t0, 1		
	ble t6, t0, MOVER_PROFESSOR_CIMA
	
	addi t0, t0, 1			# caso o número de iterações chegue nesse ponto então é necessario
					# imprimir o próximo dialogo do professor
	ble t6, t0, ANIMACAO_PROFESSOR_PRINT_DIALOGO
		
	# Ao chegar nesse ponto é necessario fazer com que o professor ande até uma posição no canto inferior 
	# da tela para que ele possa sair de cena, mas qual é essa posição vai ser determinada pela posição
	# do RED. Se a posição ao lado do RED estiver livre então o prof vai ir para a direita e depois descer, 
	# senão ele vai para a esquerda e depois desce
	lb t1, -1(s6)		 
	bne t1, zero, ANIMACAO_PROFESSOR_ESQUERDA		
	
	li t0, 8			
	ble t6, t0, MOVER_PROFESSOR_DIREITA

	addi t0, t0, 1			
	ble t6, t0, MOVER_PROFESSOR_BAIXO					

	addi t0, t0, 7			
	ble t6, t0, MOVER_PROFESSOR_DIREITA															
	j ANIMACAO_PROFESSOR_DESCER

	ANIMACAO_PROFESSOR_ESQUERDA:
	li t0, 8					
	ble t6, t0, MOVER_PROFESSOR_ESQUERDA					

	addi t0, t0, 1			
	ble t6, t0, MOVER_PROFESSOR_BAIXO	
	
	addi t0, t0, 1		
	ble t6, t0, MOVER_PROFESSOR_ESQUERDA	
	
	ANIMACAO_PROFESSOR_DESCER:
	addi t0, t0, 4			
	ble t6, t0, MOVER_PROFESSOR_BAIXO
																																																																																											
	j FIM_ANIMACAO_PROFESSOR

		MOVER_PROFESSOR_CIMA:
		# Decide os valores de a4 e a7 para a movimentação	
		
		la a4, oak_cima		# carrega a imagem do professor parado virado para cima
		li a7, 0		# a = 0 = animação para cima																
		
		# Decide se o professor vai ser renderizado dando o passo com o pé esquerdo ou direito
		# de acordo com o valor de t6	
						
		# Com o branch abaixo é possivel alternar entre os passos esquerdo e direito a cada iteração		
		andi t0, t6, 1					# se t6 for par o professor dá um passo
		beq t0, zero, PROFESSOR_CIMA_PASSO_DIREITO	# direito, senão um passo esquerdo
			la a5, oak_cima_passo_esquerdo	
			j MOVER_PROFESSOR
			
		PROFESSOR_CIMA_PASSO_DIREITO:		
			la a5, oak_cima_passo_direito
			j MOVER_PROFESSOR
					
		# -------------------------------------------------------------------------------------------
					
		MOVER_PROFESSOR_DIREITA:
		# Decide os valores de a4 e a7 para a movimentação	
		
		la a4, oak_direita	# carrega a imagem do professor parado virado para a direita
		li a7, 3		# a7 = 0 = animação para a direita																
		
		# Decide se o professor vai ser renderizado dando o passo com o pé esquerdo ou direito
		# de acordo com o valor de t6	
						
		# Com o branch abaixo é possivel alternar entre os passos esquerdo e direito a cada iteração		
		andi t0, t6, 1					# se t6 for par o professor dá um passo
		bne t0, zero, PROFESSOR_DIREITA_PASSO_DIREITO	# esquerdo, senão um passo direito
			la a5, oak_direita_passo_esquerdo	
			j MOVER_PROFESSOR
			
		PROFESSOR_DIREITA_PASSO_DIREITO:		
			la a5, oak_direita_passo_direito
			j MOVER_PROFESSOR
			
		# -------------------------------------------------------------------------------------------
		
		MOVER_PROFESSOR_ESQUERDA:
		# Decide os valores de a4 e a7 para a movimentação	
		
		la a4, oak_esquerda	# carrega a imagem do professor parado virado para a esquerda
		li a7, 1		# a7 = 1 = animação para a esquerda																
		
		# Decide se o professor vai ser renderizado dando o passo com o pé esquerdo ou direito
		# de acordo com o valor de t6	
						
		# Com o branch abaixo é possivel alternar entre os passos esquerdo e direito a cada iteração		
		andi t0, t6, 1					# se t6 for par o professor dá um passo
		bne t0, zero, PROFESSOR_ESQUERDA_PASSO_DIREITO	# esquerdo, senão um passo direito
			la a5, oak_esquerda_passo_esquerdo	
			j MOVER_PROFESSOR
			
		PROFESSOR_ESQUERDA_PASSO_DIREITO:		
			la a5, oak_esquerda_passo_direito
			j MOVER_PROFESSOR
			
		# -------------------------------------------------------------------------------------------
		
		MOVER_PROFESSOR_BAIXO:
		# Decide os valores de a4 e a7 para a movimentação	
		
		la a4, oak_baixo	# carrega a imagem do professor parado virado para baixo
		li a7, 2		# a = 2 = animação para baixo																
		
		# Decide se o professor vai ser renderizado dando o passo com o pé esquerdo ou direito
		# de acordo com o valor de t6	
						
		# Com o branch abaixo é possivel alternar entre os passos esquerdo e direito a cada iteração		
		andi t0, t6, 1					# se t6 for par o professor dá um passo
		beq t0, zero, PROFESSOR_BAIXO_PASSO_DIREITO	# direito, senão um passo esquerdo
			la a5, oak_baixo_passo_esquerdo	
			j MOVER_PROFESSOR
			
		PROFESSOR_BAIXO_PASSO_DIREITO:		
			la a5, oak_baixo_passo_direito
			
		# -------------------------------------------------------------------------------------------
																																																																						
		MOVER_PROFESSOR:				
			# a4 já tem a imagem do professor parado
			# a5 tem a a imagem do professor dando um passo	
			mv a6, a0		# a0 tem o endereço de onde imprimir o sprite do professor
			# a7 tem o número indicando qual o sentido da movimentação															
			call MOVER_PERSONAGEM	
		
			j LOOP_ANIMACAO_PROFESSOR
		
		ANIMACAO_PROFESSOR_PRINT_DIALOGO:
			addi sp, sp, -4		# cria espaço para 1 word na pilha
			sw a0, 0(sp)		# empilha ra
	
			# Imprime o proximo dialogo do professor
			la a4, matriz_dialogo_oak_2	# carrega a matriz de tiles do dialogo
			li a5, 3			# renderiza 3 dialogos		
			call RENDERIZAR_DIALOGOS
		
			li t6, 7 	# como o RENDERIZAR_DIALOGOS modifica o valor de t6 é necessário voltar
					# esse registrador para o valor antigo. Felizmente nesse ponto do código
					# é possível saber quase exatamente que valor t6 tinha antes do
					# procedimento: no máximo 7 quando o ANIMACAO_PROFESSOR_PRINT_DIALOGO 
					# foi chamado
					
			lw a0, (sp)		# desempilha ra
			addi sp, sp, 4		# remove 1 word da pilha
					
			j LOOP_ANIMACAO_PROFESSOR
		
	FIM_ANIMACAO_PROFESSOR:
	
	# Agora é necessário imprimir o sprite do professor saindo de cena
	
	# Do loop acima a0 ainda tem o endereço de onde o ultimo sprite do professor foi renderizado
	
	mv t4, a0		# salva a0 em t4	
			
	li t5, 0		# contador para o numero de loops feitos
				
	li t6, 0x00100000	# t6 será usada para fazer a troca entre frames no loop de movimentação	
				# O loop abaixo começa imprimindo os sprites no frame 1 já que se parte
				# do pressuposto de que o frame 0 é o que está sendo mostrado
				
	LOOP_PROFESSOR_SAINDO:
		# Limpa os 2 tiles onde o professor está 
		mv a0, t4			# encontra o endereço do tile na matriz e o endereço do
		call CALCULAR_ENDERECO_DE_TILE	# frame onde o professor está

		# Imprimindo os tiles e limpando a tela no frame
		# do retorno do procedimento a0 tem o endereço do tile onde a cabeça do professor está
		# do retorno do procedimento a1 tem o endereço de inicio do tile a0 no frame 0, ou seja, o 
		# endereço onde os tiles vão começar a ser impressos para a limpeza
		add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# será impressa	
		li a2, 1	# a limpeza vai ocorrer em 1 coluna
		li a3, 2	# a limpeza vai ocorrer em 2 linhas 
		call PRINT_TILES
		
		# Agora imprime a imagem do professor no frame
		la a0, oak_baixo_passo_esquerdo		# carrega o sprite do professor	
		mv a1, t4		# t4 possui o endereço de onde o ultimo sprite do professor estava

		li t0, 320		# a linha onde o sprite será impresso depende do número da interação
		mul t0, t0, t5		# de modo que quanto maior for t5 mais baixo o sprite será renderizado
		add a1, a1, t0		# dando a impressão que o professar está saindo de cena
		
		add a1, a1, t6		# decide a partir do valor de t6 qual o frame onde a imagem
					# será impressa		
						
		lw a2, 0(a0)		# numero de colunas de uma imagem do professor	
		
		li a3, 20		# o numero de linhas a serem impressas depende do numero da iteração
		sub a3, a3, t5		# diminuindo conforme o valor de t5
					
		addi a0, a0, 8		# pula para onde começa os pixels no .data	
		call PRINT_IMG	
	
		# Espera alguns milisegundos	
		li a0, 20			# sleep 20 ms
		call SLEEP			# chama o procedimento SLEEP
			
		call TROCAR_FRAME		# inverte o frame sendo mostrado
			
		li t0, 0x00100000	# com essa operação xor se t6 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# ficar alternando entre esses valores
												
		addi t5, t5, 1		# incrementa o numero de loops restantes
		li t0, 20		# 20 é a altura do sprite do professor
		bne t5, t0, LOOP_PROFESSOR_SAINDO	# reinicia o loop se t5 != 20
	
	# Pela maneira como o loop acima é feito ainda sobram alguns sprites no frame 0 e 1 que precisam ser
	# limpos
		mv a0, t4			# encontra o endereço do tile na matriz e o endereço do
		call CALCULAR_ENDERECO_DE_TILE	# frame onde o sprite do professor foi renderizado
				
		mv t4, a0	# salva o a0 retornado em t4
		mv t5, a1	# salva o a1 retornado em t5

		# Limpa o tile onde o professor estava no frame 0
		# do retorno do procedimento a0 tem o endereço do tile onde a cabeça do professor está
		# do retorno do procedimento a1 tem o endereço de inicio do tile a0 no frame 0, ou seja, o 
		# endereço onde os tiles vão começar a ser impressos para a limpeza
		li a2, 1	# a limpeza vai ocorrer em 1 coluna
		li a3, 2	# a limpeza vai ocorrer em 2 linhas 
		call PRINT_TILES
		
		# Limpa o tile onde o professor estava no frame 1
		mv a0, t4 	# t4 tem o endereço do tile onde a cabeça do professor está
		mv a1, t5	# t5 tem o endereço de inicio do tile a0 no frame 0, ou seja, o 
				# endereço onde os tiles vão começar a ser impressos para a limpeza
		li t0, 0x00100000	
		add a1, a1, t0		# passa o endereço de a1 para o equivalente no frame 1		
		li a2, 1	# a limpeza vai ocorrer em 1 coluna
		li a3, 2	# a limpeza vai ocorrer em 2 linhas 
		call PRINT_TILES
	
	# Por fim, é preciso atualizar os valores da matriz de grama que estão acima no RED para que eles
	# não chamem mais esse procedimento
	
	sub t0, s6, s7		# t0 tem o endereço na linha anterior a s6 na matriz de movimentação
	
	# armazena 0 na posição de t0 e nas duas adjacentes de modo que essas posições da matriz de movimentação
	# não vão mais permitir movimentação
	sb zero, -1(t0)		
	sb zero, 0(t0)
	sb zero, 1(t0)
															
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret

	
# ====================================================================================================== #	

RENDERIZAR_DIALOGOS:
	# Procedimento auxiliar aos procedimento de história que imprime uma caixa de dialogo com uma
	# quantidade variável de textos.
	# Para imprimir os dialogos é necessário uma matriz de tiles. Nessa matriz cada dialogo só pode 
	# ter no máximo 2 linhas, mas é possível encadear um dialogo com outro na mesma matriz, de modo que
	# quando 2 linhas da matriz forem renderizadas o procedimento vai esperar o jogador apertar ENTER e 
	# vai imprimir as proximas 2 linhas, e assim por diante imprimindo a5 dialogos.
	# Para que o procedimento funcione é necessário que a matriz em a5 especifique um número par de dialogos
	# (já que serão impressas 2 linhas por vez) e que cada linha da matriz tenha o mesmo numero de elementos
	#
	# Argumentos:
	#	a4 = matriz de tiles condificando o texto do dialogo de acordo com tiles_alfabeto
	#	a5 = número de dialogos especificados na matriz (lembrando que cada dialogo tem 2 linhas)
			
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, 0(sp)		# empilha ra	
		
	lw a6, 0(a4)		# a6 recebe o tamanho de uma linha da matriz de tiles	
	addi a4, a4, 8		# pula para onde começa os pixels no .data	
	
	# Impreme os a5 dialogos
	LOOP_PRINT_DIALOGO:	
		# Primeiro imprime a caixa de dialogo na tela
		li a0, 0xFF000000	# a0 tem o endereço base do frame 0
		
		andi t0, a5, 1		# realiza a operação andi de forma a deixar somente o primeiro bit de
					# a5 intacto. Esse bit vai ser 1 se a5 for impar e 0 caso for par
		li t1, 0x00100000	
		mul t0, t0, t1		# multiplica o bti de t0 por 0x00100000 e soma com a0 de modo que o				
		add a0, a0, t0		# endereço de a0 vai para o frame 1 caso a5 for impar e continua no 
					# frame 0 caso contrário
		call PRINT_CAIXA_DE_DIALOGO
			
		# Impreme o dialogo
			
		# a4 já tem a matriz de tiles do dialogo
		# a6 já tem tamanho de uma linha da matriz de tiles	
		li a7, 0xFF000000	# a7 tem o endereço base do frame 0
		
		andi t0, a5, 1		# realiza a operação andi de forma a deixar somente o primeiro bit de
					# a5 intacto. Esse bit vai ser 1 se a5 for impar e 0 caso for par
		li t1, 0x00100000	
		mul t0, t0, t1		# multiplica o bti de t0 por 0x00100000 e soma com a7 de modo que o				
		add a7, a7, t0		# endereço de a0 vai para o frame 1 caso a5 for impar e continua no 
					# frame 0 caso contrário			
		call PRINT_DIALOGO
		# pelo funcionamento do PRINT_DIALOGO o valor de a4 já é convenientemente atualizado de modo
		# que ele aponta para as próximas 2 linhas de dialogo	
		# além disso, o valor de a6 é preservado durante o loop	
		
		call TROCAR_FRAME		# inverte o frame sendo mostrado
				
		LOOP_TECLA_ENTER_PRINT_DIALOGO:
			# Espera o jogador apertar ENTER para ir para o proximo dialogo
			call VERIFICAR_TECLA			# verifica se alguma tecla foi apertada	
			li t0, 10				# t0 = 10 = valor da tecla ENTER
			bne a0, t0, LOOP_TECLA_ENTER_PRINT_DIALOGO	# se a0 = 10 -> tecla ENTER foi apertada 
	
		li t0, 0x00100000	# com essa operação xor se t6 for 0 ele recebe 0x0010000
		xor t6, t6, t0		# e se for 0x0010000 ele recebe 0, ou seja, com isso é possível
					# ficar alternando entre esses valores
					
		addi a5, a5, -1				# decrementa o numero de dialogos restantes
		bne a5, zero, LOOP_PRINT_DIALOGO	# reinicia o loop se a5 != 0																																							

	# Agora é necessário limpar a caixa de dialogo da tela imprindo novamente os tiles nos dois frames
	
	# O loop acima pode ser executado um numero arbitrario de vezes de acordo com o valor de a5,
	# assim não é possivel saber no final qual dos dois frame é que está sendo mostrado
	# Sendo assim, a limpeza da tela vai acontecer do seguinte modo:
	# 	(1) ->  analise de qual frame está sendo mostrado
	#	(2) -> limpa o outro frame
	#	(3) -> mostra o outro frame
	#	(4) -> limpa o frame que estava na tela
	#	(5) -> mostra o frame 0
	
	# (1) ->  analise de qual frame está sendo mostrado
		li t0, 0xFF200604		# t0 = endereço para escolher frames 
		lb t4, (t0)			# t4 = valor armazenado em t0 = qual o frame (0 ou 1) que 
						# está na tela
	
	# (2) -> limpa o outro frame
		# Calculando o endereço de onde foi impresso a caixa no frame 0
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 48 			# numero da coluna 
		li a3, 192			# numero da linha
		call CALCULAR_ENDERECO	
		
		# do retorno do procedimento acima a0 tem o endereço de onde a caixa de dialogo começou
		# a ser impressa. Dessa forma, é necessário encontrar o endereço do tile correspondente na matriz 
		# e no frame
		call CALCULAR_ENDERECO_DE_TILE	
		
		mv t5, a0	# salva o a0 retornado em t5			
		mv t6, a1	# salva o a1 retornado em t6	
		
		# Imprimindo novamente os tiles e limpando a tela no frame inverso a t4
		
		# o a0 retornado tem o endereço do tile correspondente na matriz		
		# o a1 tem o endereço de inicio do tile a0 no frame 0, ou seja, o endereço onde os tiles 
		# vão começar a ser impressos
		xori t0, t4, 1			# inverte o valor de t6
		li t1, 0x00100000		# multiplica 0x0010000 com o inverso de t4 e soma com a1
		mul t0, t0, t1			# de modo que o endereço de a1 vai para o frame inverso
		add a1, a1, t0			# do que está na tela
		li a2, 14	# número de colunas de tiles a serem impressas (largura da caixa de dialogo)
		li a3, 3	# número de linhas de tiles a serem impressas (altura da caixa de dialogo)
		call PRINT_TILES
		
	# (3) -> mostra o outro frame
		call TROCAR_FRAME
	
	# (4) -> limpa o frame que estava na tela
		mv a0, t5	# t5 tem salvo o a0 retornado de CALCULAR_ENDERECO_DE_TILE com 
				# o endereço do tile correspondente		
		mv a1, t6 	# t6 tem salvo o a1 retornado de CALCULAR_ENDERECO_DE_TILE com o endereço 
				# de inicio do tile a0 no frame 0, ou seja, o endereço onde os tiles 
				# vão começar a ser impressos
		li t1, 0x00100000	# multiplica 0x0010000 com o valor de t4  soma com a1 de modo que
		mul t0, t4, t1		# que o endereço de a1 vai para o endereço correspondente 
		add a1, a1, t0		# no frame que estava na tela
		li a2, 14	# número de colunas de tiles a serem impressas (largura da caixa de dialogo)
		li a3, 3	# número de linhas de tiles a serem impressas (altura da caixa de dialogo)
		call PRINT_TILES
			
	# (5) -> mostra o frame 0																				
		li t0, 0xFF200604		# t0 = endereço para escolher frames 
		sb zero, (t0)			# armazena 0 no endereço de t0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
	
# ====================================================================================================== #

PRINT_DIALOGO:
	# Procedimento auxiliar a RENDERIZAR_DIALOGOS que usa uma matriz de tiles para imprimir duas 
	# linhas de um dialogo no frame 0.
	# Cada texto de um dialogo é codificado em uma matriz de tiles, a diferença é que enquanto 
	# normalmente os tiles do jogo tem 16 x 16, os tiles dos textos tem 8 x 15.
	# Todos os textos são construidos com os tiles em "../Imagens/historia/dialogos/tiles_alfabeto".
	# Para renderizar o dialogo é necessário fornecer uma matriz de tiles, onde cada tile
	# é uma letra desse alfebeto.
	# Esse procedimento só imprime 2 linhas da matriz de tiles do dialogo.
	# 
	# Argumentos:
	#	a4 = matriz de tiles condificando o texto do dialogo de acordo com tiles_alfabeto
	# 	a6 = tamanho de uma linha da matriz em a4
	# 	a7 = endereço base do frame 0 ou 1 indicando o frame onde os tile serão impressos

	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, 0(sp)		# empilha ra

	# Calculando o endereço de onde imprimir a primeira letra do dialogo
		mv a1, a7		# move para a1 o endereço do frame onde os tiles serão renderizados 
		li a2, 63 			# numero da coluna 
		li a3, 198			# numero da linha
		call CALCULAR_ENDERECO	
		
		mv a1, a0	# do retorno do procedimento acima a0 tem o endereço de onde começar a 
				# imprimir as letras

	la t3, tiles_alfabeto	# carrega a imagem com os tiles do alfabeto
	addi t3, t3, 8		# pula para onde começa os pixels no .data

	li t4, 2		# numero de linhas de tiles a serem impressas

	PRINT_DIALOGO_LINHAS:
		mv t5, a6		# copia do numero de colunas para usar no loop abaixo 
				
		PRINT_DIALOGO_COLUNAS:
			lb t0, 0(a4)	# pega 1 elemento da matriz de tiles e coloca em t0
		
			li t1, 120	# t1 recebe 8 * 15 = 120, ou seja, a área de um tile do alfabeto							
			mul t0, t0, t1	# t0 (número do tile) * (8 * 15) etorna quantos pixels esse tile
					# está do começo da imagem dos tiles do alfabeto
			
			add a0, t0, t3	# a0 recebe o endereço da imagem do tile a ser impresso
			# a1 tem o endereço de onde imprimir a letra			
			li a2, 8		# numero de colunas de um tile do alfabeto
			li a3, 15		# numero de linhas de um tile do alfabeto
			call PRINT_IMG	
			
			li t0, 4800		# t1 recebe 15 (altura de um tile do alfabeto) * 320 
						# (tamanho de uma linha do frame)
			sub a1, a1, t0		# volta o endereço de a1 pelas linhas impressas			
			addi a1, a1, 8		# pula 8 colunas no bitmap já que o tile impresso tem
						# 8 colunas de tamanho 
			
			# Na verdade os tiles do alfabeto não estão ordenados em ordem alfabética, mas sim
			# em determinados grupos.
			# Nem todas as letras tem exatamente 8 x 15 pixels, na verdade esse tamanho é apenas
			# um limite definido pelo tamanho do maior simbolo nesse alfabeto. 
			# Por isso certos tiles acabam ficando com um excesso de colunas em branco, então
			# as letras estão arranjadas em grupos que indicam quantos pixels é necessário voltar
			# antes de imprimir o proximo tile para que cada letra fique mais ou menos uma do lado
			# da outra.
			
			lb t0, 0(a4)	# pega o elemento da matriz de tiles que foi impresso
			
			li t1, 1		# se o numero do tile for menor do que 55		
			li t2, 55		# então é necessário voltar 1 pixel
			blt t0, t2, PROXIMO_TILE_DIALOGO
			li t1, 2		# se o numero do tile for maior ou igual a 55 e menor do que 65
			li t2, 65		# então é necessário voltar 2 pixels
			blt t0, t2, PROXIMO_TILE_DIALOGO
			li t1, 4		# se o numero do tile for maior que 65 menor a 67 volta 4 pixels
			li t2, 67
			ble t0, t2, PROXIMO_TILE_DIALOGO			
			li t2, 5		# caso contrário volta 5 pixels
									
			PROXIMO_TILE_DIALOGO:
			
			sub a1, a1, t1	# atualiza o endereço onde o proximo tile será impresso de acordo com
					# o valor de t1 decidido acima		
						
			addi a4, a4, 1		# vai para o próximo elemento da matriz de tiles
									
			addi t5, t5, -1			# decrementando o numero de colunas de tiles restantes
			bne t5, zero, PRINT_DIALOGO_COLUNAS	# reinicia o loop se t5 != 0
		
		# Calculando o endereço de onde imprimir a segunda linha do dialogo
		mv a1, a7		# move para a1 o endereço do frame onde os tiles serão renderizados 
		li a2, 63 			# numero da coluna 
		li a3, 213			# numero da linha
		call CALCULAR_ENDERECO	
			
		mv a1, a0	# como retorno do procedimento acima a0 tem o endereço de inicio da segunda 
				# linha do dialogo
				
		addi t4, t4, -1				# decrementando o numero de linhas restantes
		bne t4, zero, PRINT_DIALOGO_LINHAS	# reinicia o loop se t4 != 0
				
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
	
# ====================================================================================================== #

PRINT_CAIXA_DE_DIALOGO:
	# Procedimento auxiliar a RENDERIZAR_DIALOGOS que imprime uma caixa de dialogo em uma posição
	# fixa no frame 0 ou 1. Para imprimir a caixa é usado "../Imagens/historia/dialogos/tiles_caixa_dialogo",
	# de modo que a impressão funciona de maneira similar a qualquer outra matriz de tiles.
	#
	# Argumentos:
	#	a0 = endereço base do frame 0 ou 1 indicando o frame onde a caixa será renderizada
 	
	addi sp, sp, -4		# cria espaço para 1 word na pilha
	sw ra, 0(sp)		# empilha ra

	# Calculando o endereço de onde imprimir a caixa no frame 0
		mv a1, a0		# move para a1 o endereço do frame onde a caixa será renderizada 
		li a2, 48 		# numero da coluna 
		li a3, 192		# numero da linha
		call CALCULAR_ENDERECO	
		
		# do retorno do procedimento acima a0 tem o endereço de onde imprimir a caixa

	la t0, matriz_tiles_caixa_dialogo	# carrega a matriz de tiles da caixa
	addi t0, t0, 8				# pula para onde começa os pixels no .data

	la t1, tiles_caixa_dialogo		# carrega a imagem com os tiles da caixa
	addi t1, t1, 8				# pula para onde começa os pixels no .data

	# O loop abaixo segue um funcionamento quase identico a PRINT_TILES. 
	# Não foi possível utilizar puramente o PRINT_TILES aqui porque ele utiliza muitos registradores, 
	# e para evitar usar ainda mais ele tem que fazer algumas suposições (que a matriz passada no 
	# argumento faz referência aos tiles que estão na imagem de s4, por exemplo) o que torna inviavel
	# utiliza-lo para imprimir a caixa de dialogo.

	li t2, 3		# numero de linhas de tiles a serem impressos

	PRINT_CAIXA_DIALOGO_LINHAS:
		li t3, 14		# numero de colunas de tiles a serem impressos
				
		PRINT_CAIXA_DIALOGO_COLUNAS:
			lb t4, 0(t0)	# pega 1 elemento da matriz de tiles e coloca em t4
		
			li t5, 256	# t5 recebe 16 * 16 = 256, ou seja, a área de um tile							
			mul t4, t4, t5	# t4 (número do tile) * (16 * 16) etorna quantos pixels esse tile
					# está do começo da imagem dos tiles
			
			add t4, t4, t1	# t4 recebe o endereço da imagem do tile a ser impresso
	
			# O loop abaixo emula um PRINT_IMG, a diferença é que como PRINT_IMG pode imprimir
			# imagens com uma tamanho arbitrário de colunas e linhas ele tem que utlizar instruções
			# load e store byte, mas como cada tile sempre tem 16 x 16 de tamanho é possível usar
			# load e store word para agilizar o processo
			
			li t5, 256	# numero de pixels de um tile (16 x 16)
										
			PRINT_TILE_CAIXA_DIALOGO_COLUNAS:
			lw t6, 0(t4)		# pega 4 pixels do .data do tile (t4) e coloca em t6
			
			sw t6, 0(a0)		# pega os 4 pixels de t6 e coloca no bitmap
	
			addi t4, t4, 4		# vai para os próximos pixels da imagem
			addi a0, a0, 4		# vai para os próximos pixels do bitmap
			addi t5, t5, -4		# decrementa o numero de pixels restantes
			
			li t6, 16		# largura de um tile
			rem t6, t5, t6		# se o resto de t5 / 16 não for 0 então ainda restam pixels
						# da linha atual para serem impressos
			bne t6, zero, PRINT_TILE_CAIXA_DIALOGO_COLUNAS	# reinicia o loop se t6 != 0
			
			addi a0, a0, -16	# volta o endeço do bitmap pelo numero de colunas impressas
			addi a0, a0, 320	# passa o endereço do bitmap para a proxima linha
			bne t5, zero, PRINT_TILE_CAIXA_DIALOGO_COLUNAS	# reinicia o loop se t5 != 0
	
			addi t0, t0, 1		# vai para o próximo elemento da matriz de tiles
			
			li t4, 5120		# t4 recebe 16 (altura de um tile) * 320 
						# (tamanho de uma linha do frame)
			sub a0, a0, t4		# volta o endereço de a0 pelas linhas impressas			
			addi a0, a0, 16		# pula 16 colunas no bitmap já que o tile impresso tem
						# 16 colunas de tamanho 
			
			addi t3, t3, -1			# decrementando o numero de colunas de tiles restantes
			bne t3, zero, PRINT_CAIXA_DIALOGO_COLUNAS	# reinicia o loop se t3 != 0
			
		addi a0, a0, -224	# 16 (largura de um tile)* 14 (numero de tiles impressos) = 224, 
					# ou seja, volta a0 pelo numero de colunas que foram impressas
					
		li t3, 5120		# t3 recebe 16 (altura de um tile) * 320 (tamanho de uma linha do frame)
		add a0, a0, t3		# avança o endereço de a0 para a proxima linha de tiles		
			
		addi t2, t2, -1				# decrementando o numero de linhas restantes
		bne t2, zero, PRINT_CAIXA_DIALOGO_LINHAS	# reinicia o loop se t2 != 0
				
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha

	ret
				
# ====================================================================================================== #																																			
.data
	.include "../Imagens/outros/balao_exclamacao.data"

	.include "../Imagens/historia/professor_carvalho/oak_cima.data"
	.include "../Imagens/historia/professor_carvalho/oak_cima_passo_direito.data"
	.include "../Imagens/historia/professor_carvalho/oak_cima_passo_esquerdo.data"
	.include "../Imagens/historia/professor_carvalho/oak_direita.data"
	.include "../Imagens/historia/professor_carvalho/oak_direita_passo_direito.data"
	.include "../Imagens/historia/professor_carvalho/oak_direita_passo_esquerdo.data"	
	.include "../Imagens/historia/professor_carvalho/oak_baixo.data"
	.include "../Imagens/historia/professor_carvalho/oak_baixo_passo_direito.data"
	.include "../Imagens/historia/professor_carvalho/oak_baixo_passo_esquerdo.data"	
	.include "../Imagens/historia/professor_carvalho/oak_esquerda.data"
	.include "../Imagens/historia/professor_carvalho/oak_esquerda_passo_direito.data"
	.include "../Imagens/historia/professor_carvalho/oak_esquerda_passo_esquerdo.data"	
			
	.include "../Imagens/historia/dialogos/tiles_caixa_dialogo.data"
	.include "../Imagens/historia/dialogos/matriz_tiles_caixa_dialogo.data"

	.include "../Imagens/historia/dialogos/tiles_alfabeto.data"
	
	.include "../Imagens/historia/dialogos/matriz_dialogo_oak_1.data"	
	.include "../Imagens/historia/dialogos/matriz_dialogo_oak_2.data"	
