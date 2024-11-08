.data
bem_vindo_msg: .string "Bem-vindo a Mesa Virtual de Blackjack! Gostaria de começar uma nova mesa?\n Digite:\n [S] = Sim | [N] = Não "
instrucoes: .string "\nDigite 1 para Hit (pedir mais) ou 0 para Stand (parar):\n "
jogador_venceu_msg: .string "\nVocê venceu!\n"
dealer_venceu_msg: .string "\nDealer venceu!\n"
empate_msg: .string "\nEmpate!"
mao_jogador_msg: .string "\n Soma das cartas do jogador: "
mao_dealer_msg: .string "\n Soma das cartas do dealer: "
mao_final_jogador_msg: .string "\n Mão final do jogador: "
mao_final_dealer_msg: .string "\n Mão final do dealer: "
sua_nova_carta_msg: .string "\n Sua nova carta é: "
nova_carta_dealer_msg: .string "\n Dealer comprou uma nova carta com o valor de: "
erro_cartas_msg: .string "\nErro: Número de cartas invalido. O numero de cartas deve estar entre 1 e 21.\n"
carta_valor: .word 0
mao_jogador: .word 0
mao_dealer: .word 0
.text
.globl main

main:
    li a7, 4
    la a0, bem_vindo_msg
    ecall
    li a7, 12
    ecall
    li t0, 'S'
    li t1, 's'
    beq a0, t0, nova_mesa
    beq a0, t1, nova_mesa
    li t0, 'N'
    li t1, 'n'
    beq a0, t0, sair
    beq a0, t1, sair
    j sair

sair:
    li a7, 93
    ecall

nova_mesa:
    jal distribui_cartas
    jal jogada_jogador
    jal jogada_dealer         # Agora o dealer só joga depois do jogador
    jal verificar_vencedor
    j sair

    la t3, mao_jogador        # Carregar endereço da mão do jogador
    lw t4, 0(t3)              # Carregar a primeira carta na mão do jogador em t4

    li t5, 1                  # Carregar o valor maximo aceitavel (1) em t5
    li t6, 21                 # Carregar o valor maximo aceitavel (21) em t6

    blt t4, t5, erro_cartas   # Se t4 < 1, pular para erro_cartas
    bgt t4, t6, erro_cartas   # Se t4 > 21, pular para erro_cartas

    j sair                    # Sair se tudo estiver correto

erro_cartas:
    li a7, 4                  # Código para imprimir string
    la a0, erro_cartas_msg    # Carregar endereço da mensagem de erro
    ecall                     # Chamada do sistema para imprimir a mensagem
    j sair                    # Sair com mensagem de erro

distribui_cartas:
    li a7, 42
    li a1, 13
    ecall
    mv t1, a0
    la t2, mao_jogador
    sw t1, 0(t2)

    li a7, 42
    li a1, 13
    ecall
    mv t1, a0
    lw t0, 0(t2)
    add t0, t1, t0
    sw t0, 0(t2)

    # Gerar duas cartas para o dealer
    li a7, 42
    li a1, 13
    ecall
    mv t1, a0
    la t2, mao_dealer
    sw t1, 0(t2)

    li a7, 42
    li a1, 13
    ecall
    mv t1, a0
    lw t0, 0(t2)
    add t0, t1, t0
    sw t0, 0(t2)
    ret

jogada_jogador:
    la t2, mao_jogador
    lw t1, 0(t2)
    li a7, 4
    la a0, mao_jogador_msg
    ecall
    li a7, 1
    mv a0, t1
    ecall

    la t2, mao_dealer
    lw t1, 0(t2)
    li a7, 4
    la a0, mao_dealer_msg
    ecall
    li a7, 1
    mv a0, t1
    ecall

    li a7, 4
    la a0, instrucoes
    ecall

    li a7, 5
    ecall
    li t0, 1
    beq a0, t0, hit
    j jogada_jogador_fim

hit:
    li a7, 42
    li a1, 13
    ecall
    mv t1, a0

    li a7, 4
    la a0, sua_nova_carta_msg
    ecall
    li a7, 1
    mv a0, t1
    ecall

    la t2, mao_jogador
    lw t0, 0(t2)
    add t0, t0, t1
    sw t0, 0(t2)
    li t2, 21
    bge t0, t2, dealer_vencedor
    j jogada_jogador

jogada_jogador_fim:
    ret

jogada_dealer:
    la t2, mao_dealer
    lw t1, 0(t2)
    li a7, 4
    la a0, mao_dealer_msg
    ecall
    li a7, 1
    mv a0, t1
    ecall

    li t3, 21            # Verifica se a mão do dealer passou de 21
    bgt t1, t3, jogador_vencedor  # se a mão passou de 21, jogador ganhou

    li t1, 17            # Se a mão do dealer for menor que 17 ele continua comprando
    blt t0, t1, hit_dealer
    ret

hit_dealer:
    li a7, 42
    li a1, 13
    ecall
    mv t1, a0		# t1 agora tem o novo valor da carta

    # valor da nova carta
    li a7, 4
    la a0, nova_carta_dealer_msg
    ecall
    li a7, 1
    mv a0, t1
    ecall

    # Atualiza e mostra o valor total da mão do dealer
    la t2, mao_dealer
    lw t0, 0(t2)
    add t0, t0, t1            # Adiciona uma nova carta ao total do dealer
    sw t0, 0(t2)

    # Repete a jogada do dealer se a mão for menor que 17
    j jogada_dealer

verificar_vencedor:
    # Exibe valores finais da mão
    la t2, mao_jogador
    lw t1, 0(t2)
    li a7, 4
    la a0, mao_final_jogador_msg
    ecall
    li a7, 1
    mv a0, t1
    ecall

    la t2, mao_dealer
    lw t1, 0(t2)
    li a7, 4
    la a0, mao_final_dealer_msg
    ecall
    li a7, 1
    mv a0, t1
    ecall

    # Determinar o vencedor com base nos valores das mãos
    la t0, mao_jogador
    lw t1, 0(t0)
    la t0, mao_dealer
    lw t2, 0(t0)
    
    blt t1, t2, dealer_vencedor
    bgt t1, t2, jogador_vencedor
    
    # Em caso de empate
    li a7, 4
    la a0, empate_msg
    ecall
    j sair

jogador_vencedor:
    li a7, 4
    la a0, jogador_venceu_msg
    ecall
    j sair

dealer_vencedor:
    li a7, 4
    la a0, dealer_venceu_msg
    ecall
    j sair
