
source("whodunargs.R")

TestProgram = R6Class("TestProgram",
	inherit = StandardProgram,
	public = list(
		flagO = NA,
		enumV = NA,
		enumOA = NA,
		enumOB = NA,
		intO = NA,
		fltO = NA,
		strO = NA,
		intvO = NA,
		fltvO = NA,
		strvO = NA,
		initialize = function(){
			super$initialize("TestProg", "A simple test program", "Use it.", "(C) ???")
			self$flagO = ArgumentOptionFlag$new("Test Flag", "--flag", "A flag option to test parsing.")
				self$addArgument(self$flagO)
			self$enumV = ArgumentOptionEnumValue$new("Test Enum")
			self$enumOA = ArgumentOptionEnum$new("Test Enum 1","--enumA","The first enum test.",self$enumV)
				self$addArgument(self$enumOA)
			self$enumOB = ArgumentOptionEnum$new("Test Enum 2","--enumB","The second enum test.",self$enumV)
				self$addArgument(self$enumOB)
			self$intO = ArgumentOptionInteger$new("Test Int","--int","An integer test","--int 8")
				self$addArgument(self$intO)
			self$fltO = ArgumentOptionFloat$new("Test Float","--float","A float test","--float 8.6")
				self$addArgument(self$fltO)
			self$strO = ArgumentOptionString$new("Test String","--string","A string test","--string abc")
				self$addArgument(self$strO)
			self$intvO = ArgumentOptionIntegerVector$new("Test Int Vector","--intvec","An integer vector test","--intvec 8")
				self$addArgument(self$intvO)
			self$fltvO = ArgumentOptionFloatVector$new("Test Float Vector","--floatvec","A float vector test","--floatvec 8.6")
				self$addArgument(self$fltvO)
			self$strvO = ArgumentOptionStringVector$new("Test String Vector","--stringvec","A string vector test","--stringvec abc")
				self$addArgument(self$strvO)
		},
		baseRun = function(){
			if(self$flagO$value){
				print("Flagged")
			}
			if(self$enumOA$value()){
				print("E 1")
			} else {
				print("E 2")
			}
			print(self$intO$value)
			print(self$fltO$value)
			print(self$strO$value)
			print(self$intvO$value)
			print(self$fltvO$value)
			print(self$strvO$value)
			invisible(self)
		}
	)
)

comArgs = commandArgs(trailingOnly=TRUE)
testP = TestProgram$new()
testP$parse(comArgs)$run()


