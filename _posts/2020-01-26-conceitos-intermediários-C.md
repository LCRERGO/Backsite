---
layout: post
title: "Conceitos Intermediários de C"
date: dom jan 26 13:11:07 -03 2020
categories: tech programming C
---
# De 101 para 3301
"Você precisa aprender as regras como um profissional para depois quebrá-las
como um artista". Essa citação de Picasso nunca foi tão verdadeira, e muitas
vezes para entender e refatorar código em C é necessário entender alguns
conceitos que não são ensinados em aulas de programação; de gotos a ponteiros
de função é isso que veremos um pouco hoje.

# Goto
Apesar da grande polêmica do fluxo estrutural do código e quase extermínio dos
gotos, o uso de gotos hoje em dia, pode ser algo mal visto por muitos, mas em
alguns casos pode tornar o código mais legível e elegante. Especialmente quando
se trata de manipulação de alocação de memória e tratamento condicional. Por
exemplo, considere o seguinte trecho de código:
```C
if (condicao_1) {
    /* Satisfeita: 1 */
    if (condicao_2) {
        /* Satisfeita: 1, 2 */
        if (condicao_3) {
            /* Satisfeita: 1, 2, 3 */
            if (condicao_4) {
                /* Satisfeita: 1, 2, 3, 4 */
                ...
                /* Um grande trecho de código a seguir */
            }            
        }        
    }
}
```
É fácil perceber que da maneira que está organizado a legibilidade do código é
prejudicada, e em muitos manuais de estilo de código existe um número de
caracteres máximo que pode haver em uma linha(79 no meu caso), e se metade
desse range é composto de identação você acaba perdendo muito de expressividade
de código. Agora considere um trecho alternativo com gotos:

```C
if (!condicao_1) goto finish;
/* Satisfeita: 1 */
if (!condicao_2) goto finish;
/* Satisfeita: 1, 2 */
if (!condicao_3) goto finish;
/* Satisfeita: 1, 2, 3 */
if (!condicao_4) goto finish;
/* Satisfeita: 1, 2, 3, 4 */
...
finish:
...
/* Um grande trecho de código a seguir */
```
Esse é apenas um exemplo de como gotos podem ser utilizados para minimizar o
código e melhorar a expressividade.

# Extern
O uso de **extern** com frequência causa confusão e para entendê-la antes é
necessário entender a diferença entre a definição de uma variável e a
declaração de uma variável. Uma definição é quando você diz ao compilador para
alocar memória para a variável; uma declaração por sua vez é quando você diz ao
compilador que irá utilizar uma variável que já foi definida em algum outro
lugar do código. Por exemplo:
> `int vet[5] = {0};`

Diz ao compilador para alocar memória para um array de 5 inteiros e atribuir
para sua primeira posição o nome `vet`. Se `vet` estiver definida fora de qualquer
função(variável global), então será alocada estaticamente e estará disponível
para qualquer parte do programa.  
Se o programa consiste de vários módulos(arquivos fonte) e um deles(não sendo o
módulo em que `vet` está definido) necessita de `vet`, é necessário declará-lo
no tal módulo da seguinte maneira:
> `extern int vet[5];`

Só é permitido inicializar uma variável onde ela é definida. Por mais que você
possa declarar variáveis direatamente dentro do módulo no qual é preciso
acessar a variável, é recomendado que seja escrito um arquivo de
cabeçalho(header file) com o mesmo nome no qual a variável é definida. Por
exemplo, se `vet` estiver definida em spam.c, então sua declaração deve estar
em spam.h. Então basta incluir spam.h no módulo em que é necessário utilizar
`vet`. Mas uma vez isso é apenas uma recomendação e não uma regra, é tarefa do
programador quebrá-la se achar necessário.

Todas as variáveis globais são alocadas estaticamente e passam a ter um escopo
para todo o programa por padrão. Isso trás um novo significado para o
classificador de armazenamento **static**: é possivel previnir que outros
módulos referenciem uma variável. Ou seja, se você definir uma variável fora de
todas as funções com o especificador de armazenamento **static**, não será
possível referir-se a ele com o uso de **extern**.

# Ponteiros de Função
Talvez um dos recursos mais elegantes de C seja também um dos mais confusos.
Ponteiros de função são uma forma de tratar funções como "First Class Citizens"
um dos pré-requisitos para o paradigma funcional. Talvez a grande dificuldade
desses ponteiros não seja o conceito em si, mas sim a sintaxe utilizada, se em
uma declaração de variável temos:
> `int i;`

Ou seja o tipo(int) do lado esquerdo e o identificador do lado direito(i), em
um ponteiro de função o identificador fica em algum lugar no **meio** da declaração:
> `int (\*op) (int, int)`

Nesse exemplo estamos dizendo que op é um ponteiro de uma função que tem como
parâmetros dois inteiros(int, int) e um retorno do tipo int. De maneira geral,
é interessante utilizar ponteiros de função quando há trechos de código que
fazem a mesma coisa semânticamente, mas de maneiras diferentes; padrão de
design conhecido como *Strategy*, por exemplo:
```C
int sum(int a, int b) { return a+b; }
int mult(int a, int b) { return a*b; }

int operate(int (*op) (int, int), int a, int b) { return op(a,b); }

int
main(int argc, char *argv[])
{
    printf("sum: %d\n", operate(sum, 4, 5));
    printf("mult: %d\n", operate(mult, 4, 5));

    return 0;
}
```

Óbvio que esse é um exemplo simples, mas é fácil perceber que isso pode
facilmente escalar e tornar códigos estremamente complexos em algo mais
semanticamente legível.

# Unions
Quando estamos aprendendo a programar em C, aprendemos sobre uma estrutura de
dados heterogênea, chamada *struct* ou na qual podemos agrupar informações
correlatas em um "tipo"(eu sempre coloquei assim pra poder ficar mais fácil de
entender). Mas algo que poucos ensinam é que em C existe uma estrutura irmã à
*stuct* chamada *union*, na qual apenas um componente pode estar ativo por vez:
```C
union num {
    int i;
    double d;
    char c;
};

union num test;
test.i = 10;
test.c = 'b';
test.d = 42.5;
```
No exemplo acima o union test tem como valor ao final da execução de 42.5, por
mais que os outros campos tenham sido atribuídos anteriormente. Isso é útil por
exemplo para realizar conversão entre tipos, pois nada impede acessar o
conteúdo de `test.i` ou `test.c` após atribuir o valor 42.5 à `test.d` por mais
que o valor de saída não faça sentido. É importante resaltar que o tamanho
total da union será igual ao tamanho do maior campo, no nosso exemplo, 8
bytes(tamanho de um double). Algo semelhante ao que ocorre no struct padding.

# Ponteiros Void
Ponteiros void ou ponteiros de propósito geral, não têm um tipo predefinido e
por isso podem armazenar o endereço de memória de qualquer tipo. São bastante
úteis para implementar um tipo primitivo de polimorfismo em C, pois não é
necessário saber o tipo de uma variável para retorná-la. Entretanto se for
preciso utilizar uma inferência de tipos para auxiliar na compilação e no
debugging é recomendado utilizar o type casting para a manipulação desse tipo
de ponteiros.

Esse tipo de ponteiro é muito utilizado na definição de funções da biblioteca
padrão de C por causa de sua versatilidade. Por exemplo:
``` C
void *memcpy(void *dest, const void *src, size_t n);
```

Nos diz que o tipo de dados manipulado por memcpy não interfere em sua
implementação, e que o programador também deve lidar com essa função não
dependendo do tipo de retorno.

# Quod Demonstratum
Como pode-se ver existem construtos bastante interessantes na linguagem C que
devem ser utilizados pelos programadores se quiserem tornar sua vida mais
fácil. Desde uma forma de saltar pelo código até uma maneira de se estabelecer
generalidade, o controle que essas estruturas nos dão não deve ser subestimado.
