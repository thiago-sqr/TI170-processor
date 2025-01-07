REQUISITOS DO COMPILADOR DE ASSEMBLY
Identificar e remover comentários;
Implementar o conjunto mínimo de instruções;
* Nota mínima sobe para 8 se:
Realizar análise semântica (quando identifica uma palavra que não pertence ao assembly, acusar erro);
* Nota mínima sobe para 9 se:
Realizar análise sintática (e.g.: se uma operação exigir dois operandos e houver apenas uma linha seguinte, acusar erro de sintaxe).

---

TAMANHO DA PALAVRA
Pelo menos 8bits.

REGISTRADORES OBRIGATÓRIOS
* 3 Registradores para operações matemáticas (operandos e resultado) - recomendado;
* Registrador de Flags (Zero Flag, Carry Flag, Sinal, Paridade, Interrupção, Direção, Overflow).

CONJUNTO MÍNIMO DE INSTRUÇÕES
* Movimentação e Transferência de Dados e Manipulação de Bits
Movimentação de dados;
Manipulação de bit;
Deslocamento de bit à direita;
Desclocamento de bit à esquerda.

* Operações Aritméticas
Soma;
Subtração;
Multiplicação;
Divisão;
Resto da divisão (módulo).

* Operações Relacionais
Comparação;

* Operações Lógicas
E;
Ou;
Negação;
Ou-exclusivo;

* Saltos e desvios (Nota mínima sobe para 8)
Saltos incondicionais e retorno. E.g.: JMP, GOTO, CALL, RET do x86;
Saltos condicionais (Se zero, se diferente de zero, se maior que, se menor que) e retono. E.g.: JZ, JZN do x86;

* Outros
Macros e Constantes;
Operações de I/O. E.g.: IN, OUT;
Faze nada. E.g: NOP, HALT;
Chamada de interrupção. E.g.: INT (Nota mínima sobe para 8).

INSTRUÇÕES EXTRAS (OPCIONAIS)
* Operações Aritméticas
Incremento;
Decremento.

* Operações Lógicas
Não-e;
Não-Ou;
Não-ou-exclusivo.

FUNCIONALIDADES EXTRAS (Sugestões)
Nota mínima sobe para 8 (0,5 Cada) se:
* Registradores extras: registradores de variáveis temporárias, argumento de funções e valores de retorno, registrador de valor constante zero, registrador de operações aritméticas, registrador acumulador, registrador para operações de vetores e strings, registradores de segmentos (códigos, dado, pilha) etc;
* Pilha (não esquecer de implementar as instruções de PUSH e POP);
* Implementar memória cache;
* Implementar recursos de temporização;
* Criar um módulo externo ao processador simulando uma RAM;
* Criar um módulo externo ao processador simulando um teclado;
* Criar um módulo externo ao processador simulando um monitor;
* Criar um controlador de DMA externo ao processador.
Nota mínima sobe para 10 se:
* Implementar aritmética em ponto flutuante - não recomendo, pode ser muito complicado;

NO RELATÓRIO, EXPLICITAR
Diagrama de Blocos;
Tabela de Opcodes;
Tabela de Interrupções: serviços de Vídeo (Setar modo de vídeo, posição de cursor, escrever caractere, string), serviços de disco (ler setores, escrever setores), serviços de teclado, serviços de real-time clock, etc. - Nota mínima sobe para 8;
Tabela de Exceções (e.g.: breakpoint, instrução ilegal, address access fault, etc.) - Nota mínima sobe para 8;
Tabela de Registradores;
Mapa de Memória e Endereçamento.
