import sys

import whodunargs

class TestProgram(whodunargs.StandardProgram):
	def __init__(self):
		whodunargs.StandardProgram.__init__(self)
		self.name = "WDAExample"
		self.summary = "A simple example for whodunargs."
		self.usage = "python3 WDAExample"
		self.version = "WDAExample 0.0\nCopyright (C) 2023 Benjamin Crysup\nLicense LGPLv3: GNU LGPL version 3\nThis is free software: you are free to change and redistribute it.\nThere is NO WARRANTY, to the extent permitted by law.\n"
		# a flag option
		self.flagOpt = whodunargs.ArgumentOptionFlag("--bye","Test Flag","Test Flag")
		self.options.append(self.flagOpt)
		# an enum option
		self.enumVal = whodunargs.ArgumentOptionEnumValue("radio")
		self.enumOptA = whodunargs.ArgumentOptionEnum("--doa", "Enum A", "The first enum value.", self.enumVal)
		self.options.append(self.enumOptA)
		self.enumOptB = whodunargs.ArgumentOptionEnum("--dob", "Enum B", "The second enum value.", self.enumVal)
		self.options.append(self.enumOptB)
		self.enumOptC = whodunargs.ArgumentOptionEnum("--doc", "Enum C", "The third enum value.", self.enumVal)
		self.options.append(self.enumOptC)
		# an integer option
		self.intOpt = whodunargs.ArgumentOptionInteger("--qual","Quality","A simple integer option.","--qual 20")
		self.intOpt.value = 20
		self.options.append(self.intOpt)
		# a float option
		self.fltOpt = whodunargs.ArgumentOptionFloat("--pow","Power","A simple float option.","--pow 1.0")
		self.fltOpt.value = 1.0
		self.options.append(self.fltOpt)
		# a string option
		self.strOpt = whodunargs.ArgumentOptionString("--name","Name","A simple string option.","--name abc")
		self.strOpt.value = "abc"
		self.options.append(self.strOpt)
		# an integer vector option
		self.intvOpt = whodunargs.ArgumentOptionIntegerVector("--dims","Dimensions","A simple integer vector option.","--dims 10")
		self.options.append(self.intvOpt)
		# a float vector option
		self.fltvOpt = whodunargs.ArgumentOptionFloatVector("--cols","Collisions","A simple float vector option.","--cols 0.4")
		self.options.append(self.fltvOpt)
		# a string vector option
		self.strvOpt = whodunargs.ArgumentOptionStringVector("--tags","Tags","A simple string vector option.","--tags bad")
		self.options.append(self.strvOpt)
		# a file read option
		self.filerOpt = whodunargs.ArgumentOptionFileRead("--in","Input","A file read option.","--in /home/ben/in.tsv")
		self.filerOpt.validExts.add(".tsv")
		self.options.append(self.filerOpt)
		# a file write option
		self.filewOpt = whodunargs.ArgumentOptionFileWrite("--out","Output","A file write option.","--out /home/ben/in.csv")
		self.filewOpt.validExts.add(".csv")
		self.options.append(self.filewOpt)
		# a folder read option
		self.foldrOpt = whodunargs.ArgumentOptionFolderRead("--builddir","Build Directory","A folder read option.","--builddir /home/ben/")
		self.options.append(self.foldrOpt)
		# a folder write option
		self.foldwOpt = whodunargs.ArgumentOptionFolderWrite("--workd","Working Directory","A folder write option.","--workd /home/ben/")
		self.options.append(self.foldwOpt)
		# many file reads
		self.filervOpt = whodunargs.ArgumentOptionFileReadVector("--refs","References","A file read vector option.","--refs /home/ben/in.bmp")
		self.options.append(self.filervOpt)
		# many file writes
		self.filewvOpt = whodunargs.ArgumentOptionFileWriteVector("--logs","Log Output","A file write vector option.","--logs /home/ben/in.midi")
		self.options.append(self.filewvOpt)
	def baseRun(self):
		self.useOut.write(bytes("Hello\n","utf-8"))
		if self.flagOpt.value:
			self.useOut.write(bytes("Goodbye\n","utf-8"))


toRun = TestProgram()
toRun.parse(sys.argv[1:])
toRun.run()

