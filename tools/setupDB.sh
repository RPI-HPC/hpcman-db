#!/bin/bash

# 
# Drop and re-create the hpcman user management DB, for testing purposes.
# This should be run on a host that allows Unix socket connections to
#  psql running locally where the currently running user can create and 
#  delete databases
#

export PGDATABASE=hpcman
popFlag=0

while [ $# -ge 1 ]; do
    case "$1" in
        -help|-\?)
	    echo "Usage:" 1>&2
	    echo "  $0 -h PGHOST -u PGUSER -d PGDATABASE -p" 1>&2
	    exit 0
	    ;;
	-h|-H)
	    shift
	    export PGHOST="$1"
	    shift
	    ;;
	-u|-U)
	    shift
	    export PGUSER="$1"
	    shift
	    ;;
	-d|-D)
	    shift
	    export PGDATABASE="$1"
	    shift
	    ;;
	-p|-P)
	    popFlag=1
	    shift
	    ;;
	*)
	    echo "Unexpected! '$1'" 1>&2
	    exit 1
	    ;;
    esac
done

dropdb "$PGDATABASE" || true
psql -c 'DROP GROUP hpcagent' || true
psql -c 'CREATE GROUP hpcagent' 
psql -c 'DROP GROUP vspasswdadmin' || true
psql -c 'CREATE GROUP vspasswdadmin' 


createdb "$PGDATABASE"
if [ $? -ne 0 ]; then
	echo "Error: failed to create database!"
	exit 1
fi

createlang plpgsql -d "$PGDATABASE"
ret=$?
if [ $ret -ne 0 ] && [ $ret -ne 2 ]; then
	echo "Error: failed to install plpgsql! ($ret)"
	exit 1
fi

SCHEMA_DIR="../schema"

# order is important!
SCHEMA_FILES="
time_latest.sql
images.sql
principalStates.sql
principals.sql
Authenticators.sql
Personae.sql
PasswordTypes.sql
Passwords.sql
sites.sql
cluster_sharing.sql
clusters.sql
SiteAdmins.sql
FilesystemTypes.sql
Filesystems.sql
sponsors.sql
GroupStates.sql
Groups.sql
projectTags.sql
projectTagging.sql
Projects.sql
ProjectClusterAccess.sql
ProjectOwners.sql
ProjectParents.sql
UserAccountsStates.sql
UserAccounts.sql
UserAccountActivity.sql
FilesystemProjectQuotas.sql
FilesystemUserQuotas.sql
FilesystemGroupQuotas.sql
GroupMembers.sql
VirtualSites.sql
VirtualSitesAllowed.sql
VirtualSiteMembers.sql
VirtualSiteGroupMembers.sql
VSUserAccount.sql
VSGroupMembers.sql
VSGroups.sql
VSUserInformation.sql
VSChangePassword.sql
VOAssoc.sql
rcsmap.sql
CPUTime.sql
firewall.sql"

export ON_ERROR_STOP=1

for f in $SCHEMA_FILES; do
	echo "Installing $f"
	psql -v ON_ERROR_STOP=1 -1 -f "$SCHEMA_DIR/$f"
	if [ $? -ne 0 ]; then
		echo "Install failed; aborting."
		exit 1
	fi
done

if [ "$popFlag" -eq 1 ]; then
	psql -f popTestDB.sql
fi
