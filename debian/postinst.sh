
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
if [ $$EXISTS -eq 1 ]; then
	echo -n "Database exists. Delete and re-create? "
	read option
	if [ $$option = n ] || [ $$option = N ]; then
		echo "Exiting.."
		exit 2
	fi
fi
echo -n "Enter Mifos Database Username (default root): "
read USER
if [ "" = "$$USER" ]; then
	USER=root
	PASS="$$MYSQL_ROOT_PW"
else
	echo -n "Enter Password for Mifos User: ";
	stty -echo
	read PASS
	stty echo
	echo
fi
for d in mifosplatform-tenants mifostenant-default; do
	echo -e "DROP DATABASE IF EXISTS \`$$d\`;
CREATE DATABASE \`$$d\`;
GRANT ALL PRIVILEGES ON \`$$d\`.* TO $$USER@localhost IDENTIFIED BY '$$PASS';" >> $$f
done
mysql -u root -p"$$MYSQL_ROOT_PW" < $$f
rm $$f
mysql -u $$USER -p"$$PASS" mifosplatform-tenants < /usr/share/mifosx/database/mifosplatform-tenants-first-time-install.sql
mysql -u $$USER -p"$$PASS" mifostenant-default < /usr/share/mifosx/database/migrations/sample_data/load_sample_data.sql
service tomcat7 restart

