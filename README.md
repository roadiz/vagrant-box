# Vagrant box for Roadiz standard-edition development

Based on `ubuntu/trusty64`.

This box provides:

- NGinx
- PHP7.1-FPM
- MariaDB
- Apache Solr
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