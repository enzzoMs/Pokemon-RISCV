.text

# ====================================================================================================== # 
# 					Pokémon FireRed/LeafGreen				         #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Este arquivo contém a lógica central do jogo incluindo o loop principal e a chamada de procedimentos   #
# adquados para renderizar os elementos visuais.							 #
#													 #
# ====================================================================================================== #

call CARREGAR_TELA_INICIAL



loop : j loop	 # loop eterno 

# ====================================================================================================== #

.data
	.include "Codigos/tela_inicial.s"
