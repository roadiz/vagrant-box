#
# Roadiz Vagrant box generation script
#
package.box :
	make destroy;
	# Check box is up to date
	vagrant box update;
	# Launch vagrant build
	vagrant up;
	# Remove empty space to maximum compression during packaging
	vagrant ssh -c "sudo dd if=/dev/zero of=/EMPTY bs=1M || true; sudo rm -f /EMPTY;";
	# Create your package
	vagrant package --output package.box;

package_no_solr.box :
	make destroy;
	# Check box is up to date
	vagrant box update;
	# Launch vagrant build
	vagrant up --no-provision;
	vagrant provision --provision-with=roadiz,phpmyadmin,mailcatcher,devtools,purge;
	# Remove empty space to maximum compression during packaging
	vagrant ssh -c "sudo dd if=/dev/zero of=/EMPTY bs=1M || true; sudo rm -f /EMPTY;";
	# Create your package
	vagrant package --output package_no_solr.box;

.PHONY : clean clean-logs

clean-logs:
	rm -rf ./*.log;

destroy :
	vagrant halt;
	vagrant destroy -f;

# Delete generated assets
clean :
	rm -rf ./package.box;
	rm -rf ./package_no_solr.box;
	make clean-logs;
	make destroy;