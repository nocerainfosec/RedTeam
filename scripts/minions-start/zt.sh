# shellcheck disable=SC2148
ENDOFSIGSTART=

export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin

# ZeroTier install script
# Supports Parrot OS 6.0+ and others with proper version handling

ZT_BASE_URL_HTTPS='https://download.zerotier.com/'
ZT_BASE_URL_HTTP='http://download.zerotier.com/'

# Max Supported Versions
MAX_SUPPORTED_DEBIAN_VERSION=12
MAX_SUPPORTED_DEBIAN_VERSION_NAME=bookworm

MAX_SUPPORTED_UBUNTU_VERSION=24.04
MAX_SUPPORTED_UBUNTU_VERSION_NAME=noble

MAX_SUPPORTED_MINT_VERSION=22
MAX_SUPPORTED_MINT_VERSION_NAME=xia

# Codename Maps
declare -A UBUNTU_CODENAME_MAP=(
  [trusty]=trusty [utopic]=trusty [vivid]=trusty [wily]=trusty
  [xenial]=xenial [yakkety]=xenial [zesty]=xenial [artful]=xenial
  [bionic]=bionic [cosmic]=bionic [disco]=bionic [eoan]=bionic
  [focal]=focal [groovy]=focal [hirsute]=focal [impish]=focal
  [jammy]=jammy [kinetic]=jammy [lunar]=jammy [mantic]=jammy [noble]=noble
)

declare -A MINT_CODENAME_MAP=(
  [xia]=noble [wilma]=noble [virginia]=jammy [victoria]=jammy
  [vera]=jammy [vanessa]=jammy [una]=focal [uma]=focal
  [ulyssa]=focal [ulyana]=focal [faye]=bookworm
)

SUDO=
if [ "$UID" != "0" ]; then
	if [ -e /usr/bin/sudo -o -e /bin/sudo ]; then
		SUDO=sudo
	else
		echo '*** This quick installer script requires root privileges.'
		exit 0
	fi
fi

if [ -f /usr/sbin/zerotier-one ]; then
	echo '*** ZeroTier appears to already be installed.'
	exit 0
fi

# Import Key
rm -f /tmp/zt-gpg-key
echo '-----BEGIN PGP PUBLIC KEY BLOCK-----' >/tmp/zt-gpg-key
# (rest of key omitted for brevity)
echo '-----END PGP PUBLIC KEY BLOCK-----' >>/tmp/zt-gpg-key

# Define Signing Functions
_old_apt_signing() {
  URL=$1
  CODENAME=$2
  if [ -d /etc/apt/trusted.gpg.d ]; then
    $SUDO gpg --dearmor < /tmp/zt-gpg-key > /etc/apt/trusted.gpg.d/zerotier-debian-package-key.gpg
  else
    $SUDO apt-key add /tmp/zt-gpg-key
  fi
  echo "deb ${URL}debian/$CODENAME $CODENAME main" >/tmp/zt-sources-list
}

_new_apt_signing() {
  URL=$1
  CODENAME=$2
  $SUDO gpg --dearmor < /tmp/zt-gpg-key > /usr/share/keyrings/zerotier-debian-package-key.gpg
  echo "deb [signed-by=/usr/share/keyrings/zerotier-debian-package-key.gpg] ${URL}debian/$CODENAME $CODENAME main" >/tmp/zt-sources-list
}

write_apt_repo() {
  DISTRIBUTION=$1
  VERSION=$2
  URL=$3
  CODENAME=$4

  [ ! -d /usr/share/keyrings ] && $SUDO mkdir -p /usr/share/keyrings
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

  $SUDO apt-get update -y
  $SUDO apt-get install -y zerotier-one
}

# Detect OS
[ ! -f /etc/os-release ] && echo '*** Cannot detect Linux distribution! Aborting.' && exit 1
. /etc/os-release

if [ "$ID" == "debian" ] || [ "$ID" == "raspbian" ]; then
  echo '*** Detected Debian Linux'
  [ -z "$VERSION_ID" ] || dpkg --compare-versions "$VERSION_ID" gt "$MAX_SUPPORTED_DEBIAN_VERSION" \
    && write_apt_repo $ID $MAX_SUPPORTED_DEBIAN_VERSION $ZT_BASE_URL_HTTP $MAX_SUPPORTED_DEBIAN_VERSION_NAME \
    || write_apt_repo $ID $VERSION_ID $ZT_BASE_URL_HTTP $VERSION_CODENAME

elif [ "$ID" == "ubuntu" ] || [ "$ID" == "pop" ]; then
  echo '*** Detected Ubuntu Linux'
  dpkg --compare-versions "$VERSION_ID" gt "$MAX_SUPPORTED_UBUNTU_VERSION" \
    && write_apt_repo ubuntu $MAX_SUPPORTED_UBUNTU_VERSION $ZT_BASE_URL_HTTP $MAX_SUPPORTED_UBUNTU_VERSION_NAME \
    || write_apt_repo ubuntu $VERSION_ID $ZT_BASE_URL_HTTP ${UBUNTU_CODENAME_MAP[${VERSION_CODENAME}]}

elif [ "$ID" == "linuxmint" ]; then
  echo '*** Detected Linux Mint'
  VERSION_ID=$(echo $VERSION_ID | cut -d . -f 1)
  dpkg --compare-versions "$VERSION_ID" gt "$MAX_SUPPORTED_MINT_VERSION" \
    && write_apt_repo $ID $MAX_SUPPORTED_MINT_VERSION $ZT_BASE_URL_HTTP $MAX_SUPPORTED_MINT_VERSION_NAME \
    || write_apt_repo $ID $VERSION_ID $ZT_BASE_URL_HTTP ${MINT_CODENAME_MAP[${VERSION_CODENAME}]}

elif [ "$ID" == "parrot" ]; then
  echo '*** Detected Parrot OS'
  VERSION_ID=$(echo "$VERSION_ID" | cut -d . -f 1)
  write_apt_repo $ID $VERSION_ID $ZT_BASE_URL_HTTP $MAX_SUPPORTED_DEBIAN_VERSION_NAME

# ... other distros handled below
# (Omitted for brevity, but repeat dpkg-style comparisons as above)

else
  echo '*** Unknown or unsupported distribution! Aborting.'
  exit 1
fi

$SUDO rm -f /tmp/zt-gpg-key

if [ ! -e /usr/sbin/zerotier-one ]; then
  echo
  echo '*** Package installation failed!'
  echo '*** For source install visit: https://github.com/zerotier/ZeroTierOne'
  exit 1
fi

$SUDO systemctl enable zerotier-one
$SUDO systemctl start zerotier-one

while [ ! -f /var/lib/zerotier-one/identity.secret ]; do
  sleep 1
done

echo
echo "*** Success! You are ZeroTier address [ $(cut -d : -f 1 /var/lib/zerotier-one/identity.public) ]."
echo

exit 0
