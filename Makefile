VER=1.25.0
PKGFILE=mifosx-$(VER)-all.deb
PKGDIR=mifosplatform-$(VER).RELEASE

package: $(PKGFILE)

$(PKGFILE): debian/mifosx.list debian/community-app.list debian/mifosng-db.list debian/mifosng-provider.list debian/tomcat-conf.list debian/postinst.sh
	epm -g -nm -a all -v -f deb mifosx --output-dir . debian/mifosx.list

debian/mifosx.list: VERSION
	sed -i "/^%version/s/ .*/ $(VER)/" debian/mifosx.list

debian/community-app.list: $(PKGDIR)/apps/community-app
	mkepmlist -u tomcat7 -g tomcat7 --prefix /var/lib/tomcat7/webapps/ROOT/community-app/ $(PKGDIR)/apps/community-app > debian/community-app.list

debian/mifosng-db.list: $(PKGDIR)/database/migrations
	mkepmlist -u root -p root --prefix /usr/share/mifosx/database $(PKGDIR)/database

debian/mifosng-provider.list: $(PKGDIR)/mifosng-provider.war
	echo "f 644 tomcat7 tomcat7 /var/lib/tomcat7/webapps/mifosng-provider.war $(PKGDIR)/mifosng-provider.war" > debian/mifosng-provider.list

debian/tomcat-conf.list: tomcat-extras
	mkepmlist -u tomcat7 -g tomcat7 --prefix /usr/share/mifosx/tomcat7 tomcat-extras > debian/tomcat-conf.list

repo: package
	mkdir -p mifosx-packages
	cp $(PKGFILE) mifosx-packages
	dpkg-scanpackages mifosx-packages /dev/null > Packages
	gzip -c Packages > Packages.gz
	mkdir -p dists/stable/main/binary-i386 dists/stable/main/binary-amd64
	cp Packages Packages.gz dists/stable/main/binary-i386
	mv Packages Packages.gz dists/stable/main/binary-amd64
	
