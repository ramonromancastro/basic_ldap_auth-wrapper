# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## 1.4 - 2020-08-09
### Added
- Los usuarios estáticos pueden estar definidos en un archivo NCSA (Gracias a **Ulrich Mück**).
- Añadida la variable de configuración STATIC_USERS_TYPE para definir el tipo de archivo de los usuarios estáticos (plain|ncsa).
- Añadida la variable de configuración BASIC_NCSA_AUTH.

### Fixed

### Changed
- Los usuarios estátivos se comprueban ahora antes que los usuarios LDAP.

## 1.3 - 2019-02-26
### Added
- Primera versión del script