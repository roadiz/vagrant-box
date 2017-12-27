# Vagrant box for Roadiz standard-edition development

Based on `ubuntu/xenial64`.

This box provides:

- Nginx
- php7.2-fpm
- MariaDB, with 2 databases `roadiz` and `roadiz_test` using *utf8mb4* character set
- Apache Solr, with one core `roadiz`
- Composer
- NPM
- Yarn
- PhpMyAdmin
- Mailcatcher

## Usage

```shell
vagrant login;
vagrant up && vagrant package --output package.box;
# Test locally before pushing to Vagrant cloud
vagrant box add roadiz-standard-edition-x.y.z package.box
```