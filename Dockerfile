FROM node
MAINTAINER Ramon de Graaff

ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy

RUN apt-get update
RUN apt-get install -y openssl sqlite3
RUN useradd -ms /bin/bash etherpad
USER etherpad
WORKDIR /home/etherpad/ 
RUN git clone https://github.com/StratumAuhuur/CTFPad.git
WORKDIR /home/etherpad/CTFPad/ 
RUN git clone https://github.com/ether/etherpad-lite.git
RUN npm install
WORKDIR /home/etherpad/CTFPad/etherpad-lite/
RUN if [ ! -f settings.json ]; then mv settings.json.template settings.json; fi
WORKDIR /home/etherpad/CTFPad/
RUN if [ ! -f key.pem ]; then openssl genrsa -out key.pem 4096; fi
RUN if [ ! -f cert.pem ]; then openssl req -new -nodes -key key.pem -out csr.pem -subj "/C=US/ST=Some-State/L=Springfield/O=Internet Widgits Pty Ltd/CN=etherpad"; fi
RUN if [ ! -f cert.pem ]; then openssl x509 -req -days 3650 -in csr.pem -signkey key.pem -out cert.pem; fi
RUN if [ ! -f config.json ]; then mv config.json.example config.json; fi
RUN if [ ! -f ctfpad.sqlite ]; then sqlite3 ctfpad.sqlite < ctfpad.sql; fi
RUN mkdir uploads

EXPOSE 1234
EXPOSE 1235
ENTRYPOINT ["/usr/local/bin/node", "/home/etherpad/CTFPad/main.js"] 

