
echo -n "Enter MySQL root password: "
stty -echo
read MYSQL_ROOT_PW
stty echo
echo
f=`mktemp`
mysql --user=root --password="$$MYSQL_ROOT_PW" -e"SHOW DATABASES" > $$f
EXISTS=0
RESULT=`cat $$f | grep "mifosplatform-tenants"`
if [ "$$RESULT" = "mifosplatform-tenants" ]; then
	EXISTS=1
fi
RESULT=`cat $$f | grep "mifostenant-default"`
if [ "$$RESULT" = "mifostenant-default" ]; then
	EXISTS=1
fi
echo -n > $$f
if [ $$EXISTS -eq 1 ]; then
	echo -n "Database exists. Delete and re-create? "
	read option
	if [ $$option = n ] || [ $$option = N ]; then
		echo "Exiting.."
		exit 2
	fi
fi
echo -n "Enter Mifos Database Username (default root): "
read USR
if [ "" = "$$USR" ]; then
	USR=root
	PASS="$$MYSQL_ROOT_PW"
else
	echo -n "Enter Password for Mifos User: ";
	stty -echo
	read PASS
	stty echo
	echo
fi
for d in mifosplatform-tenants mifostenant-default; do
	echo "DROP DATABASE IF EXISTS \`$$d\`;
CREATE DATABASE \`$$d\`;
GRANT ALL PRIVILEGES ON \`$$d\`.* TO $$USR@localhost IDENTIFIED BY '$$PASS';" >> $$f
done
mysql -u root -p"$$MYSQL_ROOT_PW" < $$f
rm $$f
mysql -u $$USR -p"$$PASS" mifosplatform-tenants < /usr/share/mifosx/database/mifospltaform-tenants-first-time-install.sql
mysql -u $$USR -p"$$PASS" mifostenant-default < /usr/share/mifosx/database/migrations/sample_data/load_sample_data.sql
cp -i /etc/tomcat7/server.xml /etc/tomcat7/server.xml.orig
cp /usr/share/mifosx/tomcat7/server.xml /etc/tomcat7/server.xml
arch=`dpkg --print-architecture`
dt=/etc/default/tomcat7
grep -q "^JAVA_HOME" $$dt || sed -i "/^#JAVA_HOME/aJAVA_HOME=" $$dt
sed -i "/^JAVA_HOME/s/.*/JAVA_HOME=\/usr\/lib\/jvm\/java-7-openjdk-$$arch/" $$dt
sed -i "/^JAVA_OPTS/s/128m/1024m/" $$dt
useradd -d /usr/share/mifosx mifos
chown -R mifos:mifos /usr/share/mifosx
keytool -keystore /usr/share/mifosx/.keystore -keyalg RSA -storepass tomcat7 -keypass tomcat7 -alias mifosx -genkey
service tomcat7 restart

