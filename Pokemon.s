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
#	s0 = número da COLUNA atual do personagem na tela, marcado pelo pixel na parte superior esquerda #
#       do sprite do RED.										 #
#	s1 = número da LINHA atual do personagem na tela, marcado pelo pixel na parte superior esquerda  #
#       do sprite do RED.										 #
#	s2 = orientação do personagem, convencionado da seguinte forma:					 #
#		[ 0 ] = virado para a esquerda								 # 
#		[ 1 ] = virado para a direita								 #
#		[ 2 ] = virado para cima 								 #
#		[ 3 ] = virado para baixo								 #
#	s3 = guarda o endereço base da imagem da área atual onde o personagem está  			 #	
#	s4 = determina como será o próximo passo do RED durante as animações de movimento, de modo que   #
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


call INICIALIZAR_TELA_INICIAL		# Chama o procedimento em tela_inicial.s

call INICIALIZAR_INTRO_HISTORIA	# Chama o procedimento em intro_historia.s

call RENDERIZAR_QUARTO_RED		# chama o procedimento em areas.s
		

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
