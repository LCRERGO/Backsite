---
layout: post 
title: "Haxe Setup Com Docker"
date: "2020-04-04 14:39:52 -0300"
categories: GameDesign DevOps
---
# De onde viemos
Recentemente tenho tentado aprender a programar em [Haxe](https://haxe.org/) 
com o framework [Heaps](https://heaps.io/) para estudar um pouco sobre game 
design(para quem não sabe esse framework é responsável por jogos como 
[Dead Cells](https://dead-cells.com/) e [Northguard](http://northgard.net/)),
mas a dificuldade de se programar nessa linguagem/framework veio muito mais 
por causa da maneira em que as partes interagem entre si do que de uma sintaxe
rebuscada ou por uma lógica obscura, então resolvi detalhar a maneira com a
qual eu configurei o meu setup para começar a criar jogos.

# Quem somos
Uma das maiores dificuldades que encontrei foi a de que no site oficial do
Heaps claramente o setup é destinado para um público alvo: usuários de Windows
que desejam utilizar o Visual Studio Code, então se for esse o seu caso eu
recomendo que leia a documentação que é estremamente bem explicada para essa
ocasião, mas se desejar uma solução mais minimalista esse post é para você.  
Para estabelecer o nosso ambiente de desenvolvimento tive bastantes problemas
com instalações locais na minha máquina, desde conflito de versões até
problemas de permissão, então para evitar dores de cabeça e termos o mínimo de
trabalho vamos utilizar o Docker.
# Para onde vamos
A primeira coisa de que precisamos é de uma imagem base; por sorte o Docker tem
uma imagem oficial chamada Haxe que é bastante atualizada, portanto:
```
docker pull haxe
``` 
Para testarmos o nosso ambiente de desenvolvimento vamos usar o seguinte
arquivo com o nome Main.hx:
```Haxe
class Main extends hxd.App {
    override function init() {
        var tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        tf.text = "Hello World !";
    }
    static function main() {
        new Main();
    }
}
```  
Então temos de subir uma instância da imagem haxe e conectar nosso
diretório à uma pasta no container para ser mais simples transferir arquivos
de um lado para o outro.
```
docker run -it -v $(pwd):/app haxe bash
```
Basicamente eu estou rodando um container da imagem Haxe em modo 
interativo(-it), colocando conectando um volume(-v) e iniciando um processo
padrão do bash, pois caso contrário o compilador de haxe será chamado e o
container vai sair automaticamente.  
Então, basta ir até o diretório montado no container e compilar, certo?
Mas infelizmente, nosso container não vem com heaps instalado por padrão 
e teremos de instalar a biblioteca manualmente com o haxelib.
```
cd /app; haxelib install heaps
```
E finalmente podemos compilar:
```
haxe -main Main -js main.js -lib heaps
```
Então para testar o código basta anexar o arquivo gerado em um arquivo HTML tal
qual:
```html
<!DOCTYPE>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Hello Heaps</title>
    <style>
        body { margin:0;padding:0;background-color:black; }
        canvas#webgl { width:100%;height:100%; } 
    </style>
</head>
<body>
    <canvas id="webgl"></canvas>
    <script type="text/javascript" src="main.js"></script>
</body>
</html>
```
# Espaço, A Fronteira Final
A partir desse setup é bem simples compilar programas em Haxe, se necessário
salvar esse container como uma imagem e ficar mais simples de utilizar basta
usar um:
```
docker commit hash/nome_container imagem_resultante
```
