scriptRenameFreebox
===================

SHELL> Un petit script permettant de renommer à distance les différents éléments téléchargés sur la FreeBox v6 
(firmware 1.1.9.1) dans le but d'enlever des caractères ASCII du nom des fichiers.

Versions des outils utilisés :
-FreeBox v6 (firmware 1.1.9.1)
-curl 7.21.0: libcurl/7.21.0 OpenSSL/0.9.8o zlib/1.2.3.4 libidn/1.15 libssh2/1.2.6

Configuration : Editez le scriptRenameFreebox et modifiez les deux variables suivantes avec vos données:
- freeboxIpAddress='IP.IP.IP.IP'
- freeboxPasswd='motDePasse'

Utilisation : "bash scriptRenameFreebox"

=====================
Inspiré des scripts de Zakhar 
http://forum.ubuntu-fr.org/viewtopic.php?id=449105
