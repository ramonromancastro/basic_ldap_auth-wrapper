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

#
# INSTALL
#
# 1. touch /etc/squid/basic_ldap_auth-wrapper.static; chmod 640 /etc/squid/basic_ldap_auth-wrapper.static
# 2. touch /etc/squid/basic_ldap_auth-wrapper.denied; chmod 640 /etc/squid/basic_ldap_auth-wrapper.denied
# 3. vi /etc/squid/squid.conf
#   ...
#   auth_param  basic program        /etc/squid/basic_ldap_auth-wrapper.sh
#   auth_param  basic children       10
#   auth_param  basic realm          Introduzca su usuario y clave de acceso de navegación Web
#   auth_param  basic credentialsttl 12 hours
#   auth_param  basic casesensitive  on
#   acl         basic_ldap_users     proxy_auth REQUIRED
#   ...
#   http_access allow basic_ldap_users all
#   ...
#

#
# FILE FORMAT
#
# - basic_ldap_auth-wrapper.static. "Static" users list with format:
#     <USERNAME> <CLEAR_PASSWORD>
#
# - basic_ldap_auth-wrapper.denied. Denied users list with format:
#     <USERNAME>

###############################################################################
# CONSTANTS
###############################################################################

VERSION=1.2

###############################################################################
# CONFIGURATION
###############################################################################

# Location of basic_ldap_auth-wrapper.static file
STATIC_USERS="/etc/squid/basic_ldap_auth-wrapper.static"

# Location of basic_ldap_auth-wrapper.denied file
DENIED_USERS="/etc/squid/basic_ldap_auth-wrapper.denied"

# Location of basic_ldap_auth
BASIC_LDAP_AUTH="/usr/lib64/squid/basic_ldap_auth"

# LDAP connection protocol, server and port
LDAP_CONNECTION="ldaps://ldap.domain.com:636"

# LDAP base to serach users. May be more than one separated by blanks
LDAP_BASE=("o=group1,c=domain,c=com" "o=group2,c=domain,c=com")

# LDAP options passed to basic_ldap_auth
LDAP_OPTIONS="-v 3"

# LDAP filter passed to basic_ldap_auth
LDAP_FILTER="(&(uid=%s)(!(objectClass=sympaMailList)))"

###############################################################################
# MAIN CODE
###############################################################################

while read input
do
	# Check denied users
	
	output="ERR"
	result="ERR"
	
	user=$(echo "$input" | awk '{ print $1 }')
	while read line; do
		if [ "$user" == "$line" ]; then result="DENIED"; break; fi
	done < "$DENIED_USERS"
	if [ "$result" == "DENIED" ]; then echo $output; continue; fi
	
	# Check LDAP users
	
	for BASEDN in "${LDAP_BASE[@]}"; do
		result=`echo "$input" | ${BASIC_LDAP_AUTH} -b "${BASEDN}" -f "${LDAP_FILTER}" -H ${LDAP_CONNECTION} ${LDAP_OPTIONS} 2> /dev/null`
		if [ "$result" == "OK" ]; then echo "$result"; break; fi
	done

	if [ "$result" == "OK" ]; then continue; fi

	# Check static users

	while read line; do
		if [ "$input" == "$line" ]; then output="OK"; break; fi
	done < "$STATIC_USERS"
	
	# RETURN
	
	echo $output
done