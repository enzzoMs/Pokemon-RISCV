.text

# Especificando o tempo de sleep em ms de cada uma das opções possíveis para o registrador s9 tal como
# explicado abaixo

.eqv FPGA_OU_RARS 0
.eqv FPGRARS 20

# ====================================================================================================== #
#     					        IMPORTANTE!!!!						 #
# ====================================================================================================== #
# Antes de iniciar o jogo é necessário definir o valor de s9 de acordo com a plataforma que o jogo vai	 #
# ser rodado (RARS, FPGRARS ou na FPGA). 								 #
# Esse registrador precisa ser inicializado corretamente porque é ele que vai definir o tempo de SLEEP   #
# ideal durante os procedimentos de movimentação da tela (movimentação em pallet) para a plataforma   	 #
# escolhida.												 #
# As opções possíveis são:										 #
#	'FPGRARS' ou 'FPGA_OU_RARS' 									 #
# Obs: mesmo com a opção 'FPGA_OU_RARS' selecionada o RARS provavelmente não vai conseguir executar a	 #
# movimentação rápido o suficiente, por isso é melhor usar o FPGRARS					 #
# ------------------------------------------------------------------------------------------------------ #
	li s9, FPGRARS
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
#	s0 = guarda a posição atual do personagem no frame 0, marcado pelo endereço do pixel na parte	 #
# 		superior esquerda do sprite do RED							 #
#	s1 = orientação do personagem, convencionado da seguinte forma:					 #
#		[ 0 ] = virado para a esquerda								 # 
#		[ 1 ] = virado para a direita								 #
#		[ 2 ] = virado para cima 								 #
#		[ 3 ] = virado para baixo								 #
#	s2 = guarda o endereço de inicio da subseção 20 x 15 na matriz de tiles que está atualmente 	 #
#		sendo mostrada na tela									 #
#	s3 = o tamanho de uma linha na matriz de tiles							 # 
#	s4 = endereço base da imagem contendo os tiles da área atual					 #
#	s5 = guarda a posição atual do personagem na matriz de tiles					 #
#	s6 = guarda o endereço da posição atual do personagem na matriz de movimentação da área em que	 #
#		ele está										 #
#	s7 = tamanho de uma linha da matriz de movimentação da área atual				 #
#	s8 = determina como será o próximo passo do RED durante as animações de movimento, de modo que   #
#		[ 0 ] = próximo passo será dado com o pé esquerdo					 #
#		[ Qualquer outro valor] = próximo passo será dado com o pé direito			 #
#	s9 = define o tempo de SLEEP durante os procedimentos de movimentação da tela (movimentação	 #
#		em Pallet). O valor de s9 pode ser trocado acima.					 #
#	s10 = [ 0 ] -> se o RED não estiver indo ou não está em um tile de grama 			 #
#	      [ Qualquer outro valor] = caso estiver indo para um tile de grama	 			 #
#	s11 = usado no combate para guardar o codigo do pokemon inimigo e o pokemon escolhido pelo 	 #
#		jogador. O valor é convencionado no formato [11 bits do pokemon do RED][11 bits do 	 #
#		pokemon inimigo], onde os 11 bits se referem ao codigo do pokemon. Para consulta os	 #
#		codigos válidos podem ser encontrados em data.s						 #
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

# Inicializando menus, história e área iniciais 

#call INICIALIZAR_TELA_INICIAL		# Chama o procedimento em tela_inicial.s

#call INICIALIZAR_INTRO_HISTORIA		# Chama o procedimento em intro_historia.s

li a4, 64	# a4 recebe 32, ou 1_0_000_00 em binário, de acordo com a conveção para a codificação
		# de transições de áreas (ver detalhes em areas.s)
		# Dessa forma a0 codifica: 
		# 1(indicativo de transição de área)X000(para o quarto do RED)00(Entrando por lugar nenhum) 				

call RENDERIZAR_AREA

# Loop principal de gameplay do jogo

LOOP_PRINCIPAL_JOGO:
	# Verifica se alguma tecla relacionada a movimentação (w, a, s ou d) ou inventario (i) foi apertada
	call VERIFICAR_TECLA_JOGO
	
	j  LOOP_PRINCIPAL_JOGO
				

# ====================================================================================================== #


.data
	#.include "Codigos/tela_inicial.s"
	#.include "Codigos/intro_historia.s"
	.include "Codigos/inventario.s"		
	.include "Codigos/historia.s"	
	.include "Codigos/areas.s"
	.include "Codigos/controles_movimentacao.s"	
	.include "Codigos/combate.s"			
	.include "Codigos/procedimentos_auxiliares.s"
