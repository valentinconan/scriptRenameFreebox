#! /bin/bash
#
# @uthor : valentinconan
#
# https://github.com/valentinconan/scriptRenameFreebox
#

freeboxIpAddress='IP.IP.IP.IP'
freeboxPasswd='motDePasse'
#Pour les caracteres speciaux, comme un & par exemple, mettre la valeur ASCII, soit %26

#Chemin du repertoire de telechargement
downloadDir='/Disque dur/T�l�chargements/'

tmpFile=$( mktemp )

# ==== Function ==== Recuperation liste des fichiers ==== 
function refreshList
{
	liste=$(curl -s -b FBXSID=$fbxSid -e http://$freeboxIpAddress/download.php http://$freeboxIpAddress/download.cgi -d '{"jsonrpc":"2.0","method":"download.list"}' -H 'X-Requested-With: XMLHttpRequest' -H 'Content-Type: application/json; charset=utf-8' -H 'Accept: application/json, text/javascript, */*') || { err=$?; echo "Erreur recuperation liste"; exit ${err}; }

	liste=$(echo ${liste} | sed 's/.*\[//;s/\].*//;s/},/}#/g')
}
# ==== Login ==== 
echo -ne "\n========================================================"
echo -ne "\nConnexion FreeBox"

resultCurl=$( mktemp )
curl -S -d "login=freebox&passwd=$freeboxPasswd" http://$freeboxIpAddress/login.php -v > $resultCurl 2>&1 
if grep -q "Set-Cookie:" $resultCurl; then
    echo -e "\t\t\t\t<  OK  >"
	echo -e "========================================================"
else
    echo -e "\t\t\t\t<ERREUR>"
	echo -ne "\n========================================================"
    echo -e "\nImpossible de joindre la FreeBox ou mot de passe incorrect.\nutiliser 'ping $freeboxIpAddress' pour tester la connexion.\n"
    rm $resultCurl > /dev/null 2>&1
    exit 1
fi

# ==== Recuperation du SID
fbxSid=`grep "FBXSID" $resultCurl | cut -f 3 -d ' ' | sed "s/FBXSID=//" | sed "s/;//" | sed "s/\r//" `

i=1
# ==== Decoupage de liste en items representant un seul fichiers ==== 
while true; do
  refreshList #recupere la liste dans la variable $liste
  item=$(echo ${liste} | cut -d '#' -f ${i})
  temp=$(echo $item | grep '"status":"done"')
  if [ -z ${temp} ]; then
	echo -ne "\nVerification que la liste est vide"
	echo -e "\t\t<  OK  >"
	break;
  fi

  # ==== On ne renomme que les fichiers termines ==== 
  if echo $item | grep '"status":"done"' >/dev/null; then
    name=$(echo ${item} | sed 's/.*,"name":"//;s/".*//')
	id=$(echo ${item} | sed 's/.*,"id"://;s/,.*//')
    url=$(echo ${item} | sed 's/.*,"url":"//;s/".*//')
    url=$(echo ${url} | sed 's/\\//g')
    realName=$( echo ${name} | sed 's/%20/ /g' | sed 's/%2B/+/g' | sed 's/%2C/,/g'| sed 's/%28/(/g'| sed 's/%29/)/g'| sed 's/%C3%A9/�/g' | sed 's/%C3/�/g' )
	# echo "name : $name"
	# echo "rname: $realName "
	# echo "id   : $id"
	
    # ==== Renommage ==== #si le nom a besoin d etre renomme, je renomme
	if [ "$name" != "$realName" ]; then
		echo -ne "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		echo -ne "\nRenommage du fichier"
		curl -s -b FBXSID=$fbxSid http://$freeboxIpAddress/fs.cgi -d "{\"jsonrpc\":\"2.0\",\"method\":\"fs.move\",\"params\":[\"${downloadDir}${name}\",\"${downloadDir}${realName}\"]}"\
			 -H 'Content-Type: application/json; charset=utf-8' -H 'X-Requested-With: XMLHttpRequest' -H 'Accept: application/json, text/javascript, */*' >/dev/null || { err=$?; echo -e "\t\t\t\t<  ERREUR  >" ; exit ${err}; }
		echo -e "\t\t\t\t<  OK  >\n" 
		echo -e "\tOriginal : \E[1m$name\E[0m "
		echo -e "\tFinal    : \E[1m$realName\E[0m"
	fi   
	
	# ==== Suppression ==== supprimer de la liste l element courant  
		echo -ne "\nSuppression de la liste"
		curl -s -b FBXSID=$fbxSid http://$freeboxIpAddress/download.cgi -d "{\"jsonrpc\":\"2.0\",\"method\":\"download.remove\",\"params\":[\"http\",$id]}"\
		 -H 'Content-Type: application/json; charset=utf-8' -H 'X-Requested-With: XMLHttpRequest' -H 'Accept: application/json, text/javascript, */*' >/dev/null || { err=$?; echo -e "\t\t\t\t<  ERREUR  >" ; exit ${err}; }
		echo -e "\t\t\t\t<  OK  >" 
		echo -ne "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
  fi
   i=$((i+1))
done
rm $resultCurl 2>/dev/null

echo -ne "\n========================================================"
echo -ne "\nDeconnexion Freebox"
echo -e "\t\t\t\t<  OK  >"
echo -ne "========================================================\n\n"

exit 0	
