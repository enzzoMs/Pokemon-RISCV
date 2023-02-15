.text
		     			 			 
# ====================================================================================================== # 
# 					      DATA E INCLUDES		 		             	 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# Arquivo que junta todos os .include, incluindo os codigos, sprites, etc, e todos os .data utilizados	 #
# no jogo.												 #
#												 	 # 
# ====================================================================================================== #

# Codigos dos pokemons -----------------------------------------------------------------------------------

# O codigo de cada pokemon é codificado no seguinte formato FFF_RRR_TTT_PPP, onde:
# 	PPP -> número do pokemon, de modo que:
#		[ 001 ] -> BULBASAUR
#		[ 010 ] -> CHARMANDER
#		[ 011 ] -> SQUIRTLE
#		[ 100 ] -> CATERPIE
#		[ 101 ] -> DIGLETT
#	TTT -> tipo do pokemon, RRR -> tipo que ele é fraco, FFF -> tipo que ele é forte, todos de modo que:
#		[ 000 ] -> GRASS
#		[ 001 ] -> FIRE
#		[ 010 ] -> WATER
#		[ 011 ] -> GROUND
#		[ 100 ] -> BUG
# Sendo assim o codigo de cada Pokemon pode ser encontrado abaixo:
# 	BULBASAUR [Tipo GRASS, Fraco FIRE, Forte WATER]-> 1089
#	CHARMANDER [Tipo FIRE, Fraco WATER, Forte GRASS] -> 138
# 	SQUIRTLE [Tipo WATER, Fraco GRASS, Forte FIRE] -> 531
# 	CATERPIE [Tipo BUG, Fraco FIRE, Forte GRASS] -> 100
# 	DIGLETT [Tipo GROUND, Fraco GRASS, Forte FIRE] -> 541


.eqv BULBASAUR 1089
.eqv CHARMANDER 138
.eqv SQUIRTLE 531
.eqv CATERPIE 100
.eqv DIGLETT 541

.data

# Códigos ------------------------------------------------------------------------------------------------
	.include "tela_inicial.s"
	.include "inventario.s"		
	.include "historia.s"	
	.include "areas.s"
	.include "controles_movimentacao.s"	
	.include "combate.s"			
	.include "procedimentos_auxiliares.s"
	
.data	

# Menu Inicial -------------------------------------------------------------------------------------------

	.include "../Imagens/menu_inicial/matriz_tiles_menu_inicial.data"
	.include "../Imagens/menu_inicial/tiles_menu_inicial.data"
	.include "../Imagens/menu_inicial/menu_inicial_pikachu.data"
	.include "../Imagens/menu_inicial/menu_inicial_texto_aperte_enter.data"	

	# Musica
	# Numero de Notas a tocar
	NUM_NOTAS_MUSICA: .word 95
	# lista de nota, duração, nota, duração, nota, duração,...
	NOTAS_MUSICA: 52, 111, 55, 111, 59, 111, 62, 111, 55, 222, 55, 222, 55, 222, 55, 444, 55, 111, 55, 111, 55, 222, 55, 222, 55, 222, 55, 222, 55, 222, 57, 222, 57, 148, 57, 148, 57, 148, 57, 148, 57, 148, 54, 148, 62, 666, 59, 222, 62, 888, 60, 666, 65, 666, 60, 444, 62, 888, 65, 666, 64, 111, 63, 111, 62, 888, 60, 296, 59, 296, 60, 296, 62, 666, 59, 222, 62, 888, 60, 888, 64, 296, 64, 296, 60, 296, 59, 888, 65, 296, 64, 296, 60, 296, 62, 1111, 59, 222, 60, 222, 62, 222, 62, 666, 59, 222, 62, 888, 60, 666, 65, 666, 60, 444, 62, 888, 65, 666, 64, 111, 63, 111, 62, 888, 60, 296, 59, 296, 60, 296, 62, 666, 59, 222, 62, 888, 60, 666, 60, 666, 64, 444, 62, 666, 65, 222, 67, 222, 62, 444, 67, 222, 67, 666, 69, 444, 64, 222, 69, 222, 72, 222, 62, 1333, 64, 444, 65, 888, 67, 444, 65, 444, 64, 1333, 65, 444, 67, 888, 72, 444, 73, 444, 74, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 72, 296, 72, 296, 73, 296, 74, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 64, 296, 64, 296, 61, 296, 62, 666, 59, 222, 62, 888, 60, 666, 65, 666, 60, 444, 62, 888, 65, 666, 64, 111, 63, 111, 62, 888, 60, 296, 59, 296, 60, 296, 62, 666, 59, 222, 62, 888, 60, 888, 64, 296, 64, 296, 60, 296, 59, 888, 65, 296, 64, 296, 60, 296, 62, 1111, 59, 222, 60, 222, 62, 222, 62, 666, 59, 222, 62, 888, 60, 666, 65, 666, 60, 444, 62, 888, 65, 666, 64, 111, 63, 111, 62, 888, 60, 296, 59, 296, 60, 296, 62, 666, 59, 222, 62, 888, 60, 666, 60, 666, 64, 444, 62, 666, 65, 222, 67, 222, 62, 444, 67, 222, 67, 666, 69, 444, 64, 222, 69, 222, 72, 222, 62, 1333, 64, 444, 65, 888, 67, 444, 65, 444, 64, 1333, 65, 444, 67, 888, 72, 444, 73, 444, 74, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 72, 296, 72, 296, 73, 296, 74, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 50, 111, 64, 296, 64, 296, 61, 296 
		
# Áreas --------------------------------------------------------------------------------------------------
	# Casa da RED
	.include "../Imagens/areas/casa_red/tiles_casa_red.data"
	.include "../Imagens/areas/casa_red/matriz_tiles_casa_red.data"
	.include "../Imagens/areas/casa_red/matriz_movimentacao_casa_red.data"	
		
	# Pallet 	
	.include "../Imagens/areas/pallet/tiles_pallet.data"
	.include "../Imagens/areas/pallet/matriz_tiles_pallet.data"
	.include "../Imagens/areas/pallet/matriz_movimentacao_pallet.data"	
		
	# Laboratório
	.include "../Imagens/areas/laboratorio/tiles_laboratorio.data"
	.include "../Imagens/areas/laboratorio/matriz_tiles_laboratorio.data"
	.include "../Imagens/areas/laboratorio/matriz_movimentacao_laboratorio.data"
		
	# Transição entre áreas 
	.include "../Imagens/areas/transicao_de_areas/seta_transicao_cima.data"
	.include "../Imagens/areas/transicao_de_areas/seta_transicao_baixo.data"
	.include "../Imagens/areas/transicao_de_areas/mensagem_sair_area.data"
	.include "../Imagens/areas/transicao_de_areas/mensagem_entrar_area.data"	

# Combate ------------------------------------------------------------------------------------------------
	# Tela de combate
	.include "../Imagens/combate/matriz_tiles_tela_combate.data"
	.include "../Imagens/combate/tiles_combate_e_inventario.data"
	.include "../Imagens/combate/tiles_caixa_pokemon_combate.data"	
	.include "../Imagens/combate/matriz_tiles_caixa_pokemon_combate.data"					
	.include "../Imagens/combate/seta_direcao_caixa_pokemon_combate.data"	
	.include "../Imagens/combate/combate_barra_de_vida.data"	
																					
	# Elementos de menu
	.include "../Imagens/combate/seta_proximo_dialogo_combate.data"		
	.include "../Imagens/outros/caractere_barra.data"																		
				
	# Efeitos		
	.include "../Imagens/combate/efeito_de_ataque.data"
	.include "../Imagens/combate/pokebola_captura.data"																																																																											
	.include "../Imagens/outros/balao_exclamacao.data"
																																																																																																																																																																																																																																																																																																																																																																																																																																																																												
	# Essa matriz de tiles em especial representa uma parte da tela de combate e será usada durante a ação
	# de ataque para limpar o sprite do pokemon inimigo e do RED da tela
	matriz_tiles_combate_limpar_pokemon:
		.word 4, 4 		
		.byte 2,2,2,2,
		      2,2,2,2,
		      5,6,7,8,
		      13,14,15,16			
		
# Movimentação --------------------------------------------------------------------------------------------
									
	# Sprites do RED
	.include "../Imagens/red/red_direita.data"
	.include "../Imagens/red/red_direita_passo_esquerdo.data"
	.include "../Imagens/red/red_direita_passo_direito.data"
	.include "../Imagens/red/red_cima.data"
	.include "../Imagens/red/red_cima_passo_esquerdo.data"
	.include "../Imagens/red/red_cima_passo_direito.data"	
	.include "../Imagens/red/red_baixo.data"
	.include "../Imagens/red/red_baixo_passo_esquerdo.data"
	.include "../Imagens/red/red_baixo_passo_direito.data"	
	.include "../Imagens/red/red_esquerda.data"
	.include "../Imagens/red/red_esquerda_passo_esquerdo.data"
	.include "../Imagens/red/red_esquerda_passo_direito.data"	
	
	# Movimentação na grama
	.include "../Imagens/outros/tiles_grama_animacao.data"	

# História -------------------------------------------------------------------------------------------------

.data
	# Sprites do Professor Carvalho
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
	
	# Caixa de dialogo				
	.include "../Imagens/historia/dialogos/tiles_caixa_dialogo.data"
	.include "../Imagens/historia/dialogos/matriz_tiles_caixa_dialogo.data"

	# Alfabeto usado no dialogo
	.include "../Imagens/historia/dialogos/tiles_alfabeto.data"

	# Escolha de pokemon inicial
	.include "../Imagens/historia/escolha_pokemon_inicial/matriz_dialogo_escolha_pokemon_sim.data"
	.include "../Imagens/historia/escolha_pokemon_inicial/matriz_dialogo_escolha_pokemon_nao.data"	
	
	.include "../Imagens/historia/escolha_pokemon_inicial/matriz_tiles_caixa_escolha_pokemon.data"	
	.include "../Imagens/historia/escolha_pokemon_inicial/tiles_caixa_escolha_pokemon.data"	
		
	# Matrizes com os dialogos da historia	
	.include "../Imagens/historia/dialogos/matriz_dialogo_oak_pallet_1.data"	
	.include "../Imagens/historia/dialogos/matriz_dialogo_oak_pallet_2.data"	
	.include "../Imagens/historia/dialogos/matriz_dialogo_oak_laboratorio_1.data"	
	.include "../Imagens/historia/dialogos/matriz_dialogo_oak_laboratorio_2.data"	
	.include "../Imagens/historia/dialogos/matriz_dialogo_oak_intro.data"	
		
	# Intro com dialogos
	.include "../Imagens/historia/intro/matriz_tiles_intro.data"	
	.include "../Imagens/historia/intro/tiles_intro.data"	
	.include "../Imagens/historia/intro/intro_professor_carvalho.data"		
		

	# Esses valores vão ser usados no final de RENDERIZAR_ESCOLHA_DE_POKEMON_INICIAL para atualizar a matriz
	# de tiles de Pallet, permitindo que o resto do mapa seja renderizado
	NOVA_LINHA_DE_TILES_PALLET: .byte 4,5,103,104,104,105,76,67,67,53,102,106,107,107,108,102,103,104,104,
				  104,104,105,4,5

# Inventario ---------------------------------------------------------------------------------------------		

	# Inicializando os itens do inventario
	NUMERO_DE_POKEBOLAS: .byte 5
	POKEMONS_DO_RED: .word 0,0,0,0,0

	# Pokemons do jogo			
	.include "../Imagens/pokemons/pokemons.data"		
		
	# Tela de inventario
	.include "../Imagens/inventario/matriz_tiles_inventario.data"
	
	# Elementos do menu
	.include "../Imagens/inventario/tiles_numeros.data"
	.include "../Imagens/inventario/pokebola_inventario.data"
	.include "../Imagens/inventario/pokemons_tipos.data"
	.include "../Imagens/inventario/seta_tipo_forte_fraco.data"
	.include "../Imagens/inventario/pokebola_grande.data"
	
																	
# Matrizes de texto --------------------------------------------------------------------------------------		
# Uma matriz de texto é uma matriz em que cada elemento representa um tile de tiles_alfabeto.data, sendo usados
# para imprimir um nome geralmente curto na tela. Os labels estão no formato matriz_texto_Y, onde Y é o texto
# que a matriz se refere. Geralmente são usados no combate e inventario.

	matriz_texto_atacar: .word 6, 1 
		.byte 39,60,39,36,39,35
			
	matriz_texto_item: .word 4, 1 
		.byte 57,60,22,27
		     
	matriz_texto_fugir: .word 5, 1 
		.byte 62,40,61,57,35

	matriz_texto_um: .word 3, 1 
		.byte 40,69,77			# inclui espaço no final
		     
	matriz_texto_selvagem: .word 9, 1 
		.byte 77,71,4,76,11,0,5,4,69	# inclui espaço no começo     	
		     
	matriz_texto_apareceu: .word 9, 1 
		.byte 0,9,0,70,4,2,4,73,74		# inclui exclamação no final 

	matriz_texto_escolha_o_seu_pokemon: .word 22, 1 		# inclui exclamação no final 
		.byte 22,71,2,8,76,6,0,77,8,77,71,4,73,77,24,25,26,29,27,25,28,74	
			
	matriz_texto_escolhido: .word 11, 1 		# inclui espaço no começo e ponto no final
		.byte 77,4,71,2,8,76,6,78,3,8,54
		
	matriz_texto_o_que_o: .word 8, 1 		# inclui espaço no final
		.byte 25,77,10,73,4,77,8,77		

	matriz_texto_vai: .word 4, 1 		# inclui espaço no começo
		.byte 77,11,0,78
		
	matriz_texto_fazer: .word 6, 1 		# inclui interrogação no final
		.byte 66,0,15,4,70,55

	matriz_texto_tenta_fugir: .word 13, 1 		# inclui espaço no começo e exclamação no final
		.byte 77,72,4,7,72,0,77,66,73,5,78,70,74
		
	matriz_texto_tres_pontos: .word 2, 1 		# inclui espaço no final
		.byte 65,77
		
	matriz_texto_a_fuga_falhou: .word 14, 1 		# inclui ponto no final
		.byte 39,77,66,73,5,0,77,66,0,76,6,8,73,54
		
	matriz_texto_a_fuga_funcionou: .word 17, 1 		# inclui exclamação no final
		.byte 39,77,66,73,5,0,77,66,73,7,2,78,8,7,8,73,74
		
	matriz_texto_ataca: .word 7, 1 		# inclui espaço no começo e exclamação no final
		.byte 77,0,72,0,2,0,74	
		
	matriz_texto_muito_efetivo: .word 15, 1 		# inclui exclamação e espaço no final
		.byte 27,73,78,72,8,77,4,66,4,72,78,11,8,74,77
		
	matriz_texto_pouco_efetivo: .word 15, 1 		# inclui ponto e espaço no final
		.byte 24,8,73,2,8,77,4,66,4,72,78,11,8,54,77											

	matriz_texto_o_ataque: .word 8, 1 		
		.byte 25,77,0,72,0,10,73,4

	matriz_texto_deu: .word 4, 1 		# inclui espaço no final
		.byte 3,4,73,77
				
	matriz_texto_de_dano: .word 8, 1 		# inclui ponto no final
		.byte 3,4,77,3,0,7,8,54
		
	matriz_texto_vitoria: .word 7, 1 		
		.byte 31,57,60,25,35,57,39		

	matriz_texto_derrota: .word 7, 1 		
		.byte 34,22,35,35,25,60,39
		
	matriz_texto_voce_ganhou: .word 12, 1 		# inclui espaço no final	
		.byte 31,8,2,20,77,5,0,7,6,8,73,77
		
	matriz_texto_pokebola: .word 8, 1 		
		.byte 24,25,26,29,37,25,38,39	
							
	matriz_texto_voce_nao_tem_nenhuma: .word 20, 1 			
		.byte 31,8,2,20,77,7,16,8,77,72,4,69,77,7,4,7,6,73,69,0	
		
	matriz_texto_ponto: .word 1, 1 			# so o tile de um ponto		
		.byte 54
									
	matriz_texto_inventario_cheio: .word 17, 1 			# inclui ponto no final	
		.byte 57,7,11,4,7,72,19,70,78,8,77,2,6,4,78,8,54

	matriz_texto_a_captura_falhou: .word 17, 1 		# inclui ponto no final
		.byte 39,77,2,0,9,72,73,70,0,77,66,0,76,6,8,73,54
		
	matriz_texto_a_captura_funcionou: .word 20, 1 		# inclui exclamação no final
		.byte 39,77,2,0,9,72,73,70,0,77,66,73,7,2,78,8,7,8,73,74

	# Nomes dos pokemons
	matriz_texto_bulbasaur: .word 9, 1 
		.byte 37,40,38,37,39,30,39,40,35
			
	matriz_texto_caterpie: .word 8, 1 
		.byte 36,39,60,22,35,24,57,22
		       
	matriz_texto_charmander: .word 10, 1 
		.byte 36,33,39,35,27,39,28,34,22,35
			 
	matriz_texto_diglett: .word 7, 1 
		.byte 34,57,61,38,22,60,60
		      
	matriz_texto_squirtle: .word 8, 1 
		.byte 30,59,40,57,35,60,38,22

	matriz_texto_inventario: .word 10, 1
		.byte 57,7,11,4,7,72,19,70,78,8
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
