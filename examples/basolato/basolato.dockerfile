FROM nimlang/nim:1.2.4

RUN apt install -y libpq-dev
ADD ./ /basolato
WORKDIR /basolato
ENV PATH $PATH:~/.nimble/bin
RUN nimble install https://github.com/itsumura-h/nim-basolato -y
RUN nimble c -d:release --threads:on -y main.nim

CMD ./main
