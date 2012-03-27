RELEASE=2.0

PACKAGE=fence-agents-pve
PKGREL=2
FAVER=3.1.7
FADIR=fence-agents-${FAVER}.11-d264
FASRC=${FADIR}.tar.gz


DEB=${PACKAGE}_${FAVER}-${PKGREL}_amd64.deb

all: ${DEB}

${DEB} deb: ${FASRC}
	rm -rf ${FADIR}
	tar xf ${FASRC}
	cp -av debian ${FADIR}/debian
	cat ${FADIR}/doc/COPYRIGHT >>${FADIR}/debian/copyright
	cd ${FADIR}; dpkg-buildpackage -rfakeroot -b -us -uc
	lintian ${DEB}

${RHCSRC} download:
	rm -rf fence-agents.git
	git clone git://git.fedorahosted.org/fence-agents.git fence-agents.git
	cd fence-agents.git; ./autogen.sh; ./configure; make dist
	mv fence-agents.git/fence-agents-*.tar.gz .

.PHONY: upload
upload: ${DEB}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/${PACKAGE}*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEB} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

distclean: clean

clean:
	rm -rf *~ debian/*~ *.deb ${FADIR} ${PACKAGE}_* fence-agents.git

.PHONY: dinstall
dinstall: ${DEB}
	dpkg -i ${DEB}
