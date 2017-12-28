# Vagrant box for Roadiz standard-edition development

Based on `bento/ubuntu-16.04`.

This box provides:

- Nginx
- php7.2-fpm
- MariaDB, with 2 databases `roadiz` and `roadiz_test` using *utf8mb4* character set
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
vagrant up && vagrant package --output package.box;
# Test locally before pushing to Vagrant cloud
vagrant box add roadiz-standard-edition-x.y.z package.box
```