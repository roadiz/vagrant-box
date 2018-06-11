#
# Roadiz Vagrant box generation script
#

package.box :
	# Launch vagrant build
	vagrant up;
	# Remove empty space to maximum compression during packaging
	vagrant ssh -c "sudo dd if=/dev/zero of=/EMPTY bs=1M && sudo rm -f /EMPTY";
	# Create your package
	vagrant package --output package.box;

.PHONY : clean

# Delete generated assets
clean :
	rm -rf ./package.box;
	vagrant destroy -f;