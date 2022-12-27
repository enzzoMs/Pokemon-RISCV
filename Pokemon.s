.text

# ====================================================================================================== # 
# 					Pokémon FireRed/LeafGreen				         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo contém a lógica central do jogo incluindo o loop principal e a chamada de procedimentos   #
# adquados para renderizar os elementos visuais.							 #
#													 #
# ====================================================================================================== #
# 				    TABELA DE REGISTRADORES SALVOS					 #
# ====================================================================================================== #
#													 #
#	s0 = guarda a posição do personagem no frame 0, marcado pelo endereço do pixel na parte superior #
# 		esquerda do sprite do RED				 		 		 #
#	s1 = orientação do personagem, convencionado da seguinte forma:					 #
#		[ 0 ] = virado para a esquerda								 # 
#		[ 1 ] = virado para a direita								 #
#		[ 2 ] = virado para cima 								 #
#		[ 3 ] = virado para baixo								 #
#	s2 = guarda o endereço de inicio da subsecção (320 x 240) da área onde o personagem está  	 #
#	s3 = o tamanho de uma linha da imagem da área atual						 # 
#	s4 = guarda o endereço da posição atual do personagem na matriz de movimentação da área em que	 #
#		ele está										 #
#	s5 = tamanho de uma linha da matriz de movimentação da área atual
#	s6 = determina como será o próximo passo do RED durante as animações de movimento, de modo que   #
#		[ 0 ] = próximo passo será dado com o pé esquerdo					 #
#		[ Qualquer outro valor] = próximo passo será dado com o pé direito			 #
#													 #											 
# ====================================================================================================== #
# Observações:											         #
# 													 #
# -> Este é o arquivo principal do jogo e através dele são chamados outros procedimentos para a execução #  
# de determinadas funções. Caso esses procedimentos chamem outros procedimentos é usado a pilha e o      #
# registrador sp (stack pointer) para guardar o endereço de retorno, de modo que os procedimentos possam #
# voltar até esse arquivo.										 #
# 													 #
# ====================================================================================================== #

# Inicializando registradores salvos
	
	# Inicializando s0
	# O sprite do personagem sempre fica numa posição fixa na tela, o endereço dessa posição é 
	# armazenado em s0
	li a1, 0xFF000000		# seleciona como argumento o frame 0
	li a2, 148 			# numero da coluna do RED = 148
	li a3, 108			# numero da linha do RED = 108
	call CALCULAR_ENDERECO
	
	mv s0, a0		# move para s0 o valor retornado pelo procedimento chamado acima

# Inicializando menus, história e área iniciais 

call INICIALIZAR_TELA_INICIAL		# Chama o procedimento em tela_inicial.s

call INICIALIZAR_INTRO_HISTORIA		# Chama o procedimento em intro_historia.s

li a0, 0xE0	# a0 recebe 0xE0, ou 1110_0000 em binário, de acordo com a conveção para a codificação
		# de transições de áreas (ver detalhes em areas.s)
		# Dessa forma a0 codifica: 
		# 1(indicativo de transição de área)11(sem nenhuma animação de transição) +
		# 000(para o quarto do RED)00(Entrando por lugar nenhum) 
		
call RENDERIZAR_AREA		# chama o procedimento em areas.s
		

# Loop principal de gameplay do jogo

LOOP_PRINCIPAL_JOGO:
	call VERIFICAR_TECLA_MOVIMENTACAO
	
	j  LOOP_PRINCIPAL_JOGO
				

# ====================================================================================================== #

.data
	.include "Codigos/tela_inicial.s"
	.include "Codigos/intro_historia.s"
	.include "Codigos/areas.s"
	.include "Codigos/controles_movimentacao.s"	
	.include "Codigos/procedimentos_auxiliares.s"
