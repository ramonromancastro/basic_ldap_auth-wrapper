#!/bin/bash

# basic_ldap_auth-wrapper.sh is a wrapper for basic_ldap_auth.
# Copyright (C) 2018  Ramón Román Castro <ramonromancastro@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

###############################################################################
# CONSTANTS
###############################################################################

VERSION=1.4
CONFIG_FILE="settings.conf"
STATIC_USERS="static.conf"
DENIED_USERS="denied.conf"

###############################################################################
# DEFAULT CONFIGURATION
###############################################################################

STATIC_USERS_TYPE=plain
BASIC_NCSA_AUTH="/usr/lib64/squid/basic_ncsa_auth"
BASIC_LDAP_AUTH="/usr/lib64/squid/basic_ldap_auth"
LDAP_CONNECTION="ldaps://ldap.domain.com:636"
LDAP_BASE=("c=domain,c=com")
LDAP_OPTIONS="-v 3"
LDAP_FILTER="(uid=%s)"

###############################################################################
# MAIN CODE
###############################################################################

shopt -s extglob

if [ -f ${CONFIG_FILE} ]; then . ${CONFIG_FILE}; fi

while read input
do
	output="ERR"
	
	# Check denied users
	
	user=$(echo "$input" | awk '{ print $1 }')
	while read line; do
		if [ "$user" == "$line" ]; then output="DENIED"; break; fi
	done < "$DENIED_USERS"
	if [ "$output" == "DENIED" ]; then echo "ERR"; continue; fi
	
	# Check static users
	
	if grep "^${user}[: ]" ${STATIC_USERS} > /dev/null 2>&1; then
		if [ ${STATIC_USERS_TYPE} == "plain" ]; then
			while read line; do
				if [ "$input" == "$line" ]; then output="OK"; break; fi
			done < "$STATIC_USERS"
		else
			output=`echo "$input" | ${BASIC_NCSA_AUTH} ${STATIC_USERS} 2> /dev/null`
			output=${output%%*( )}
		fi
	else
		# Check LDAP users

		for BASEDN in "${LDAP_BASE[@]}"; do
			output=`echo "$input" | ${BASIC_LDAP_AUTH} -b "${BASEDN}" -f "${LDAP_FILTER}" -H ${LDAP_CONNECTION} ${LDAP_OPTIONS} 2> /dev/null`
			output=${output%%*( )}
			if [ "$output" == "OK" ]; then echo "$output"; break; fi
		done
	fi

	echo $output
done

shopt -u extglob