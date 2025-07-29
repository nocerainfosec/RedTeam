write_apt_repo() {
	DISTRIBUTION=$1
	VERSION=$2
	URL=$3
	CODENAME=$4

	if [ ! -d /usr/share/keyrings ]; then
		$SUDO mkdir -p /usr/share/keyrings
	fi

	$SUDO apt-get update -y
	$SUDO apt-get install -y gpg
	$SUDO chmod a+r /tmp/zt-gpg-key

	if [[ "$DISTRIBUTION" == "ubuntu" ]] && dpkg --compare-versions "$VERSION" lt "22.04"; then
		_old_apt_signing $URL $CODENAME
	elif [[ "$DISTRIBUTION" == "debian" || "$DISTRIBUTION" == "raspbian" ]] && dpkg --compare-versions "$VERSION" lt "10"; then
		_old_apt_signing $URL $CODENAME
	elif [[ "$DISTRIBUTION" == "ubuntu" ]] && dpkg --compare-versions "$VERSION" ge "22.04"; then
		_new_apt_signing $URL $CODENAME
	elif [[ "$DISTRIBUTION" == "debian" || "$DISTRIBUTION" == "raspbian" ]] && dpkg --compare-versions "$VERSION" ge "10"; then
		_new_apt_signing $URL $CODENAME
	elif [[ "$DISTRIBUTION" == "kali" || "$DISTRIBUTION" == "parrot" ]]; then
		_new_apt_signing $URL $CODENAME
	elif [[ "$DISTRIBUTION" == "linuxmint" ]] && dpkg --compare-versions "$VERSION" eq "6"; then
		_new_apt_signing $URL $CODENAME
	elif [[ "$DISTRIBUTION" == "linuxmint" ]] && dpkg --compare-versions "$VERSION" ge "21"; then
		_new_apt_signing $URL $CODENAME
	elif [[ "$DISTRIBUTION" == "linuxmint" ]] && dpkg --compare-versions "$VERSION" ge "20" && dpkg --compare-versions "$VERSION" lt "21"; then
		_old_apt_signing $URL $CODENAME
	else
		echo "Unsupported distribution $DISTRIBUTION $VERSION"
		exit 1
	fi

	$SUDO mv -f /tmp/zt-sources-list /etc/apt/sources.list.d/zerotier.list
	$SUDO chown 0 /etc/apt/sources.list.d/zerotier.list
	$SUDO chgrp 0 /etc/apt/sources.list.d/zerotier.list

	echo
	echo '*** Installing zerotier-one package...'

	if [ -d /var/lib/zerotier-one ]; then
		$SUDO rm -f /etc/init.d/zerotier-one /etc/systemd/system/multi-user.target.wants/zerotier-one.service /var/lib/zerotier-one/zerotier-one /usr/local/bin/zerotier-cli /usr/bin/zerotier-cli /usr/local/bin/zero
	fi

	cat /dev/null | $SUDO apt-get update
	cat /dev/null | $SUDO apt-get install -y zerotier-one
}
