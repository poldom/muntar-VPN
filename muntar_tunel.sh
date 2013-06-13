#!/bin/bash

# Comprobar que expect estigui instal·lat

if [ "$(dpkg -l |grep '^ii  expect')" != "" ]; then

#Recollida de dades

	read -e -p "Quina és la IP de la teva antena?" -i "192.168.1.1" HOST_UB
	read -e -p "Quin és el nom d'usuari per accedir a la teva antena?" -i "root" USER_UB
	read -e -p "Quina és la contrasenya per accedir a la teva antena?" -i "guifi" PASS_UB
	read -e -p "Quina és la IP del servidor VPN?" -i "10.228.20.198" HOST_VPN
	read -e -p "Quin és el teu nom d'usuari del servidor VPN?" USER_VPN
	read -e -p "Quina és la teva contrasenya del servidor VPN?" PASS_VPN

#Generar fitxer temporal temp
	
	echo ppp.1.name=$USER_VPN > temp
	echo ppp.1.password=$PASS_VPN >> temp
	echo ppp.1.status=disabled >> temp
	echo ppp.status=disabled >> temp
	echo pptp.1.serverip=$HOST_VPN >> temp
	echo pptp.status=enabled >> temp
	
# Enviar scripts a l'antena

	VAR=$(expect -c "
		spawn scp rc.poststart $USER_UB@$HOST_UB:/etc/persistent/
		expect \"password:\"
		send \"$PASS_UB\r\"
		expect -re \"$USER_UB.*\"
		send \"logout\"

		spawn scp tunel $USER_UB@$HOST_UB:/etc/persistent/
		expect \"password:\"
		send \"$PASS_UB\r\"
		expect -re \"$USER_UB.*\"
		send \"logout\"

		spawn scp ip-up $USER_UB@$HOST_UB:/etc/persistent/
		expect \"password:\"
		send \"$PASS_UB\r\"
		expect -re \"$USER_UB.*\"
		send \"logout\"

		spawn scp ip-down $USER_UB@$HOST_UB:/etc/persistent/
		expect \"password:\"
		send \"$PASS_UB\r\"
		expect -re \"$USER_UB.*\"
		send \"logout\"

		spawn scp temp $USER_UB@$HOST_UB:/etc/persistent/
		expect \"password:\"
		send \"$PASS_UB\r\"
		expect -re \"$USER_UB.*\"
		send \"logout\"
	")
	echo "==============="
	echo "$VAR"

# Afegir línies al fitxer /var/tmp/system.cfg. Falta comprovar si ja existeixen

VAR=$(expect -c "
	spawn ssh $USER_UB@$HOST_UB 
	expect \"password:\"
	send \"$PASS_UB\r\"
	expect \"\\\\$\"
	send \"cat /etc/persistent/temp >> /var/tmp/system.cfg\r\"
	expect -re \"$USER_UB.*\"
	send \"rm /etc/persistent/temp\r\"
	expect -re \"$USER_UB.*\"
	send \"logout\"
")
echo "==============="
echo "$VAR"

# Grabar dades a la memòria de l'antena i reiniciar l'antena

VAR=$(expect -c "
	spawn ssh $USER_UB@$HOST_UB
	expect \"password:\"
	send \"$PASS_UB\r\"
	expect \"\\\\$\"
	send \"cd /vat/tmp\r\"
	expect -re \"$USER_UB.*\"
	send \"cfgmtd -w -p /etc/ \r\"
	expect -re \"$USER_UB.*\"
	send \"reboot\r\"
	expect -re \"$USER_UB.*\"
	send \"logout\"
")
echo "==============="
echo "$VAR"

# Esborrar fitxer temp

rm temp

# Idees pendents: Afegir fitxer configuració antena, si es vol, i aplicar-lo.
# Idees pendents 2: Fer-ho amb netcat


else
	echo "Per fer funcionar l'script cal que instal·lis l'expect: sudo apt-get install expect"
fi
