# basic_ldap_auth-wrapper

basic_ldap_auth-wrapper es un wrapper del script de autenticación contra LDAP para [Squid Cache] (http://www.squid-cache.org/) [*basic_ldap_auth*] (http://www.squid-cache.org/Versions/v4/manuals/basic_ldap_auth.html), que añade soporte para autenticar contra más de un LDAP, así como la posibilidad de utilizar usuario estáticos para permitir y denegar el acceso.

## Instrucciones de instalación

### Instalación del script

```bash
# Clone repository
cd /path/to/destination
git clone https://github.com/ramonromancastro/basic_ldap_auth-wrapper.git
# Initialize config files
cd basic_ldap_auth-wrapper
cp settings.conf.template settings.conf
cp static.conf.template static.conf
cp denied.conf.template denied.conf
# Set files ownership and permissions
cd ..
chown root:squid -R basic_ldap_auth-wrapper
find basic_ldap_auth-wrapper/ -name "*.conf" -exec chmod 640 {} \;
find basic_ldap_auth-wrapper/ -name "*.sh" -exec chmod 750 {} \;
```

### Configuración de Squid

```bash
vi /etc/squid/squid.conf
...
auth_param basic program /path/to/basic_ldap_auth-wrapper/basic_ldap_auth-wrapper.sh
auth_param basic children 10
auth_param basic realm Enter username and password
auth_param  basic credentialsttl 12 hours
auth_param  basic casesensitive  on
acl basic_ldap_users proxy_auth REQUIRED
...
http_access allow basic_ldap_users all
...
```

## SELinux

En el caso de tener SELinux habilitado en el servidor, es posible que Squid no tenga permisos sobre basic_ldap_auth-wrapper.sh.

En estos momentos estoy investigando cuales son los privilegios necesarios para poder terner permisos de acceso. Mientras tanto, **es necesario deshabilitar SELinux** para una correcta ejecución.
