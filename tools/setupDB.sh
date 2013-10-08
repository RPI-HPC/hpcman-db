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
createdb "$PGDATABASE" \
    	&& createlang plpgsql -d "$PGDATABASE" \
        && psql -f time_latest.sql \
	&& psql -f images.sql \
	&& psql -f principalStates.sql \
	&& psql -f principals.sql \
        && psql -f Authenticators.sql \
        && psql -f Personae.sql \
        && psql -f PasswordTypes.sql \
        && psql -f Passwords.sql \
	&& psql -f sites.sql \
	&& psql -f cluster_sharing.sql \
	&& psql -f clusters.sql \
        && psql -f SiteAdmins.sql \
        && psql -f FilesystemTypes.sql \
        && psql -f Filesystems.sql \
	&& psql -f sponsors.sql \
	&& psql -f GroupStates.sql \
	&& psql -f Groups.sql \
	&& psql -f projectTags.sql \
	&& psql -f projectTagging.sql \
        && psql -f Projects.sql \
	&& psql -f ProjectClusterAccess.sql \
        && psql -f ProjectOwners.sql \
	&& psql -f ProjectParents.sql \
	&& psql -f UserAccountsStates.sql \
	&& psql -f UserAccounts.sql \
	&& psql -f UserAccountActivity.sql \
        && psql -f FilesystemProjectQuotas.sql \
        && psql -f FilesystemUserQuotas.sql \
        && psql -f FilesystemGroupQuotas.sql \
	&& psql -f GroupMembers.sql \
	&& psql -f VirtualSites.sql \
	&& psql -f VirtualSitesAllowed.sql \
	&& psql -f VirtualSiteMembers.sql \
	&& psql -f VirtualSiteGroupMembers.sql \
	&& psql -f VSUserAccount.sql \
        && psql -f VSGroupMembers.sql \
	&& psql -f VSGroups.sql \
	&& psql -f VSUserInformation.sql \
	&& psql -f VSChangePassword.sql \
	&& psql -f VOAssoc.sql \
	&& psql -f rcsmap.sql \
	&& psql -f CPUTime.sql \
	&& psql -f firewall.sql \
 	&& : psql -f ProjectRules.sql \
        && [ "$popFlag" -eq 1 ] \
	&& psql -d "$PGDATABASE" -f popTestDB.sql
