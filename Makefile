#
# Roadiz Vagrant box generation script
#
package.box :
	# Check box is up to date
	vagrant box update;
	# Launch vagrant build
	vagrant up;
	# Remove empty space to maximum compression during packaging
	vagrant ssh -c "sudo dd if=/dev/zero of=/EMPTY bs=1M || true; sudo rm -f /EMPTY;";
	# Create your package
	vagrant package --output package.box;

.PHONY : clean clean-logs

clean-logs:
	rm -rf ./*.log;

# Delete generated assets
clean :
	rm -rf ./package.box;
	rm -rf ./*.log;
	vagrant destroy -f;