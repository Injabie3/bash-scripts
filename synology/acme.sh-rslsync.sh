#!/bin/bash
# Injabie3 - 2024-04-24
# Let's Encrypt for Resilio Sync
#
# Description:
# A script to renew the Let's Encrypt certificate and then subsequently copy it
# into a directory to use with Resilio Sync on a Synology NAS.
#
# Pre-requisites:
# acmesh-official/acme.sh is used to manage the certificate. Detailed instructions
# can be found at https://github.com/acmesh-official/acme.sh/wiki/Synology-NAS-Guide
# tl;dr: This script assumes that acme.sh is located at `/usr/local/share/acme.sh`.
#
# Usage:
# 1. Add the contents of this script to your Task Scheduler in DSM.
# 2. Stop the Resilio Sync service.
# 3. Ensure your sync.conf file has the following keys set in the webui section:
#    "force_https": true,
#    "ssl_certificate": "/volume1/@appstore/resiliosync/var/cert/cert.pem",
#    "ssl_private_key": "/volume1/@appstore/resiliosync/var//cert/privkey.pem"
#
#    On DSM 7 and Resilio Sync 2.7.3, if Resilio Sync is installed on Volume 1, then
#    this file is located at: `/volume1/@appstore/resiliosync/var/`.
# 4. Restart the Resilio Sync service.

#################
# Configuration #
#################
export fqdnForNas=nas.example.com
export acmeShRoot=/usr/local/share/acme.sh
export synologyCertDir=/usr/syno/etc/certificate/system/default
export rslsyncCertDir=/volume1/@appstore/resiliosync/var/cert

# Here's the actual script
${acmeShRoot}/acme.sh --renew -d "${fqdnForNas}" --home ${acmeShRoot}
cp ${synologyCertDir}/cert.pem ${rslsyncCertDir}/cert.pem
cp ${synologyCertDir}/privkey.pem ${rslsyncCertDir}/privkey.pem
chown rslsync:resiliosync ${rslsyncCertDir}/cert.pem
chown rslsync:resiliosync ${rslsyncCertDir}/privkey.pem
chmod 600 ${rslsyncCertDir}/cert.pem
chmod 600 ${rslsyncCertDir}/privkey.pem
