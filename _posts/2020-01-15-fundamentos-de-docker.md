---
layout: post
title: "Fundamentos de Docker"
date: qua jan 15 12:27:14 -03 2020
categories: tech devops
---
# Bootstrap
Você já teve problemas para aprender uma nova linguagem ou um novo conceito 
e se deparar com o problema de ter de lidar com o conflito de depêndencias do
sistema? Ou ainda trocar de máquina de desenvolvimento e a sua aplicação de
repente parar de funcionar? É nesse contexto que o Docker vem para mudar o 
jogo.  
O Docker é uma forma de "containerizar" uma aplicação, ou seja, agrupar todas
as dependências de uma aplicação em um só lugar(container) e separá-las do
resto do sistema. Isso tem o contra da aplicação acabar consumindo mais espaço
do que normalmente consumiria, mas na maior parte dos casos isso pode ser 
relevado. Ao contrário da alternativa de máquinas virtuais, não há uma perda
de desenpenho grande, visto que o Kernel utilizado pelo container continua
sendo o do Host e não uma virtualização de Kernel a partir de um Hipervisor.  
Mas, afinal de contas como tudo isso funciona? Basicamente containers são
criados a partir de imagens e imagens são agrupadas em registros, sendo o mais
famoso deles o [Docker Hub](https://hub.docker.com). Então tudo o que é preciso
para utilizar o docker é pegar uma imagem como base, encapsular a aplicação em
um Dockerfile e lançar containers.
![Docker Environment](/assets/img/posts/docker_env.png)

# Hello World
Bom, para experimentar o Docker vamos criar um simples web server capaz de
exibir um Hello World na tela. Não vou abordar como instalar o Docker nesse
artigo, pois a documentação do Docker já é bem explicativa quanto à isso, então
a primeira coisa que deve ser feita é criar um diretório para que possamos
trabalhar:
> `mkdir docker-test && cd docker-test`

Então é necessário escolher uma imagem como base para a nossa aplicação, a
partir do comando `"docker search` ou pela barra de busca do Docker Hub; por se
tratar de um web service eu vou escolher uma imagem com node para trabalhar com
Elm a partir do comando:
> `docker pull node`

Agora é necessário criar um Dockerfile para realizar as configurações da
aplicação, lembrando que se você estiver apenas utilizando o Docker para
experimentar uma nova linguagem apenas um `docker run -it
nome_do_interpretador` pode ser o suficiente para você. Mas para aplicações
maiores um Dockerfile é requirido. Vou usar o seguinte arquivo(Main.elm) 
para minha aplicação:
```elm
module Main exposing (..)
import Html exposing (text)

main = text "Hello World!"
```

E o seguinte Dockerfile:
```Dockerfile
FROM node
MAINTAINER Lucas Cruz dos Reis<lcr.ergo@gmail.com>

WORKDIR /app
RUN npm install --unsafe-perm -g elm
RUN echo "Y" | elm init
COPY Main.elm src/

EXPOSE 8000
CMD ["elm", "reactor"]
```

E a explicação de cada declaração do Dockerfile:
- FROM: indica a imagem base para a aplicação.
- MAINTAINER: indica o criador da imagem, primariamente para propósitos de
  documentação.
- WORKDIR: indica em qual diretório do container a imagem poderá utilizar.
- RUN: executa um comando dentro do container
- EXPOSE: indica a porta em que o container vai estar escutando por um 
  processo.
- CMD: O primeiro comando de execução da imagem(deve ser único).  

Para montar a imagem basta fazer um:  
>`docker build -t nome_da_imagem .`  

Vale lembrar que a cada declaração um novo container é criado para executar os
comandos quando ocorre o build, por isso se por algum motivo o build falhar
podem existir containers órfãos. E por fim para executar a aplicação basta
utilizar um:  
> `docker run -d -P nome_da_imagem`  

Uma porta aleatória será alocada na máquina host para a aplicação e a aplicação
será posta em background(detached mode); para encontrar a porta em que a
aplicação está executando antes é necessário encontrar o id do container a
partir de:  
> `docker ps`

Então basta executar um:  
> `docker port id_do_container`  

Para encontrar a porta em que a aplicação está sendo executada. Então é só
acessá-la a partir do browser.

# Shutdown
Para remover containers que não estão mais sendo utilizados, antes é necessário
pará-los com um: 
> `docker stop id_do_container`  

E removê-los com: 
> `docker rm id_do_container`

Por fim para remover imagens basta utilizar:
> `docker rmi nome_da_imagem`  

# Considerações Finais
E isso concluiu nosso introdução ao Docker, há ainda como gerenciar várias
aplicações em um sistema coeso com o Docker Compose e Kubernetes, mas isso fica
para outro dia.
