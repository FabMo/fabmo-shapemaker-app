partmaker.fma: clean *.html js/*.js css/*.css icon.png package.json
	zip partmaker.fma *.html js/*.js css/*.css *.pde icon.png package.json

.PHONY: clean

clean:
	rm -rf partmaker.fma