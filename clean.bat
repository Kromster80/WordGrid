;Delete folders recursively
FOR /D /R %%X IN (__history) DO RD /S /Q "%%X"
FOR /D /R %%X IN (dcu) DO RD /S /Q "%%X"

erase /F /Q /S *.~* *.ddp *.drc *.dcp *.dcu
erase /F /Q /S *.o *.or *.ppu *.compiled
erase /F /Q /S *.log *.tmp thumbs.db *.ion *.skincfg
erase /F /Q /S *.identcache *.local

erase /F /Q /S /A:H *.~* *.ddp *.drc *.dcp *.dcu
erase /F /Q /S /A:H *.o *.or *.ppu *.compiled
erase /F /Q /S /A:H *.log *.tmp thumbs.db *.ion *.skincfg
erase /F /Q /S /A:H *.identcache *.local
