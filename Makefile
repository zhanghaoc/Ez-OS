IMG = zhxOS.img
LIST = a.com b.com c.com d.com
SHELL:= /bin/bash

all: img clean

img: boot.com $(LIST)
	test -e $(IMG) && rm $(IMG)
	dd conv=sync if=boot.com of=$(IMG) bs=1440k count=1
	@n=1; \
	for i in $(LIST); do \
		dd conv=notrunc if=$$i of=$(IMG) seek=$$n; \
		let "n+=2"; \
		#echo $$n; \
	done

%.com : %.asm
	nasm $< -o $@
	
clean:
	rm -rf *com