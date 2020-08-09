![Wrapper for basic_ldap_auth Squid Proxy plugin](logo.png "Wrapper for basic_ldap_auth Squid Proxy plugin")

# basic_ldap_auth-wrapper

basic_ldap_auth-wrapper es un wrapper del script de autenticación contra LDAP para [Squid Cache](http://www.squid-cache.org/) [*basic_ldap_auth*](http://www.squid-cache.org/Versions/v4/manuals/basic_ldap_auth.html), que añade soporte para autenticar contra más de un LDAP, así como la posibilidad de utilizar usuario estáticos para permitir y denegar el acceso.

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
find basic_ldap_auth-wrapper/ -name "*.conf" -exec chmod 0640 {} \;
find basic_ldap_auth-wrapper/ -name "*.sh" -exec chmod 0750 {} \;
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

### Archivos de configuración

#### denied.conf

Este archivo incluye una lista de todos los usuarios a los cuales se les va a denegar el acceso sin necesidad de comprobar sus credenciales.

Los usuarios se insertan dentro del archivo, a razón de uno por línea.

#### static.conf

Este archivo incluye una lista de todos los usuarios con credenciales estáticas (que no están incluídos en el LDAP), a los cuales se les va a permitir el acceso.

El formato de este archivo puede ser:

- Texto plano (plain).
- Texto encriptado (NCSA).

En el archivo de texto plano, los usuarios se insertan dentro del archivo, a razón de uno por línea, especificando su nombre de usuario y su contraseña, separados por un espacio en blanco.

En el archivo de texto encriptado, los usuarios se administran a través de la utilidad *htpasswd*.

#### settings.conf

Es el archivo principal de configuración del script. Dentro de la plantilla que se adjunta están explicadas cada una de las opciones disponibles, así como el formato de las mismas.

## SELinux

En el caso de tener SELinux habilitado en el servidor, es posible que Squid no tenga permisos sobre basic_ldap_auth-wrapper.sh.

En estos momentos estoy investigando cuales son los privilegios necesarios para poder terner permisos de acceso. Mientras tanto, **es necesario deshabilitar SELinux** para una correcta ejecución.

NOTA: En la actualidad, el problema de compatibilidad con SELinux se soluciona ejecutando el comando
```
setsebool -P authlogin_nsswitch_use_ldap 1
```
