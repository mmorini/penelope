SCRIPTS = scripts

s:
	$(SCRIPTS)/make_s.sh

w:
	$(SCRIPTS)/make_w.sh

s-static:
	$(SCRIPTS)/make_s_static.sh

w-static:
	$(SCRIPTS)/make_w_static.sh

clean:
	-rm -f abtps-? abtps-?-? core.* .libs/lt-* gmon.out *.o DUMP.TXT dump.png

s-install:
	$(SCRIPTS)/make_s_static.sh
	cp -f abtps-s abtps-s.scm ../abtps-s


#w-install:
#	$(SCRIPTS)/make_w_static_sized.sh
#	cp -f abtps-w abtps-w.scm ../abtps-w

w-install-sized:
	$(SCRIPTS)/make_w_static_sized.sh
	cp -f abtps-w-? ../abtps-w


s-install-sized:
	$(SCRIPTS)/make_s_static_sized.sh
	cp -f abtps-s-? ../abtps-s

