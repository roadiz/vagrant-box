# Vagrant box for Roadiz standard-edition development

https://app.vagrantup.com/roadiz/boxes/standard-edition
Based on `bento/ubuntu-18.04`.

This box provides:

- Nginx
- php7.4-fpm
- MariaDB 10.4, with 2 databases `roadiz` and `roadiz_test` using *utf8mb4* character set
- Apache Solr, with one core `roadiz`
- PhpMyAdmin
- Mailcatcher

## Optional devtools

- Composer
- NPM
- Yarn

## Usage

```shell
vagrant login;

make;

# Test locally before pushing to Vagrant cloud
vagrant box add roadiz-standard-edition-x.y.z package.box
vagrant box add roadiz-standard-edition-no-solr-x.y.z package_no_solr.box
```

### MariaDB access

- Host: `localhost`
- Databases: `roadiz` or `roadiz_test`
- User: `roadiz`
- Pass: `roadiz`

### Solr access

- Host: `localhost`
- Core: `roadiz` and `roadiz_test`
- Port: 8983
- User/Pass: *none*

### Mailcatcher access

- Host: `localhost`
- Port: 1080
