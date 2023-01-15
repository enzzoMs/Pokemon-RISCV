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
	# inicial, e depois renderiza a animação do professor voltanto de onde ele veio.




