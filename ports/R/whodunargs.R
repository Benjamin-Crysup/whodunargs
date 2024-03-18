
# pass by value, ASS by value
library(R6)

.argopt.structPack.Bool = function(toAdd){
	if(toAdd){
		return(as.raw(c(1)))
	} else {
		return(as.raw(c(0)))
	}
}

.argopt.structPack.USLong = function(longV){
	b0 = 0
	b1 = 0
	b2 = 0
	b3 = 0
	b4 = bitwAnd(255, bitwShiftR(longV, 3*8))
	b5 = bitwAnd(255, bitwShiftR(longV, 2*8))
	b6 = bitwAnd(255, bitwShiftR(longV, 1*8))
	b7 = bitwAnd(255, bitwShiftR(longV, 0*8))
	bai = c(b0,b1,b2,b3,b4,b5,b6,b7)
	return(as.raw(bai))
}

.argopt.structPack.SLong = function(longV){
	if(longV >= 0){
		return(.argopt.structPack.USLong(longV))
	}
	b0 = 255
	b1 = 255
	b2 = 255
	b3 = 255
	b4 = bitwAnd(255, bitwShiftR(longV, 3*8))
	b5 = bitwAnd(255, bitwShiftR(longV, 2*8))
	b6 = bitwAnd(255, bitwShiftR(longV, 1*8))
	b7 = bitwAnd(255, bitwShiftR(longV, 0*8))
	bai = c(b0,b1,b2,b3,b4,b5,b6,b7)
	return(as.raw(bai))
}

.argopt.structPack.Double = function(longV){
	# test endian
	# unpack
	flatB = writeBin(longV, raw(8), endian="big")
	return(flatB)
}

.argopt.structPack.LenText = function(toAdd){
	addB = raw(0)
	if(!is.na(toAdd)){
		addB = charToRaw(toAdd)
	}
	return(c(.argopt.structPack.USLong(length(addB)), addB))
}

.argopt.structPack.Add.Bool = function(toR,toAdd){
	return(c(toR,.argopt.structPack.Bool(toAdd)))
}

.argopt.structPack.Add.USLong = function(toR,toAdd){
	return(c(toR,.argopt.structPack.USLong(toAdd)))
}

.argopt.structPack.Add.LenText = function(toR,toAdd){
	return(c(toR,.argopt.structPack.LenText(toAdd)))
}

.argopt.help.eatargs = function(argList,numEat){
	if(length(argList) == numEat){
		return(character(0))
	}
	return(argList[(numEat+1):length(argList)])
}

.argopt.help.dumpCommonInfo = function(opt,numExtra){
	toR = raw(0)
	toR = .argopt.structPack.Add.LenText(toR, opt$name)
	toR = .argopt.structPack.Add.USLong(toR, length(opt$sigils))
	for(sig in opt$sigils){
		toR = .argopt.structPack.Add.LenText(toR, sig)
	}
	toR = .argopt.structPack.Add.LenText(toR, opt$summary)
	toR = .argopt.structPack.Add.LenText(toR, opt$description)
	toR = .argopt.structPack.Add.LenText(toR, opt$usage)
	toR = .argopt.structPack.Add.Bool(toR, opt$isCommon)
	toR = .argopt.structPack.Add.LenText(toR, opt$typeCode)
	toR = .argopt.structPack.Add.LenText(toR, opt$extTypeCode)
	toR = .argopt.structPack.Add.USLong(toR, numExtra)
	return(toR)
}

.argopt.help.dumpToStdout = function(toDump){
	# R doesn't have an easy way to write binary to stdout
	# Windows doesn't have an equivalent to /dev/stdout (CON = /dev/tty)
	if(Sys.info()['sysname'] == "Windows"){
		# Thank you Simon Kissane
		# Holy Shit, this should not be this hard.
		con = pipe("powershell.exe -c \"[Console]::OpenStandardInput().CopyTo([Console]::OpenStandardOutput())\"","wb")
		writeBin(toDump,con)
		close(con)
	} else {
		con = file("/dev/stdout", "wb", raw=TRUE)
		writeBin(toDump,con)
		close(con)
	}
}

#' Base class for argument description.
ArgumentOption = R6Class("ArgumentOption",
	public = list(
		#' @field Whether this argument is common (should be reported on --help).
		isCommon = TRUE,
		#' @field The reporting name of this argument.
		name = NA,
		#' @field The programatic strings to trigger this argument.
		sigils = character(0),
		#' @field A one-line summary of this argument.
		summary = "",
		#' @field A long form description of this argument.
		description = NA,
		#' @field An example description of this argument.
		usage = NA,
		#' @field A general type-code for this argument.
		typeCode = "",
		#' @field A specific type code for this argument.
		extTypeCode = "",
		#' @description
		#' Test whether this can parse the head of an argument list.
		#' @param argList The character vector of arguments.
		#' @return Whether it can.
		canParse = function(argList){
			arg0 = argList[[1]]
			for(sig in self$sigils){
				if(sig == arg0){
					return(TRUE)
				}
			}
			return(FALSE)
		},
		#' @description
		#' Parse the first thing in an argument list.
		#' @param argList The character vector of arguments.
		#' @param forProg The program this is parsing for.
		#' @return The remaining arguments.
		parse = function(argList, forProg){
			stop(self$name, " is defined as abstract base class...")
		},
		#' @description
		#' Run idiot checks. Stop if problem.
		idiotCheck = function(){
			# base is all good
			invisible(self)
		},
		#' @description
		#' Package up this option for external consumption.
		#' @return Raw bytes to describe this option.
		dumpInfo = function(){
			return(.argopt.help.dumpCommonInfo(self,0))
		}
	)
)

#' Class for handling help.
ArgumentOptionHelp = R6Class("ArgumentOptionHelp",
	inherit = ArgumentOption,
	public = list(
		#' @description
		#' Set up the argument.
		initialize = function(){
			self$isCommon = FALSE
			self$name = "Help"
			self$sigils = c("--help","-h","/?")
			self$summary = "Print out help information."
			self$typeCode = "meta"
		},
		parse = function(argList, forProg){
			forProg$needRun = FALSE
			forProg$needIdiot = FALSE
			write(forProg$name, stdout())
			write(forProg$summary, stdout())
			for(opt in forProg$options){
				if(opt$isCommon){
					write(paste("  ",opt$sigils[[1]]," : ",opt$summary, sep=""), stdout())
					if(!is.na(opt$usage)){
						write(paste("    ",opt$usage, sep=""), stdout())
					}
				}
			}
			return(character(0))
		}
	)
)

#' Class for handling version.
ArgumentOptionVersion = R6Class("ArgumentOptionVersion",
	inherit = ArgumentOption,
	public = list(
		#' @description
		#' Set up the argument.
		initialize = function(){
			self$isCommon = FALSE
			self$name = "Version"
			self$sigils = c("--version")
			self$summary = "Print out version information."
			self$typeCode = "meta"
		},
		parse = function(argList, forProg){
			forProg$needRun = FALSE
			forProg$needIdiot = FALSE
			write(forProg$version, stdout())
			return(character(0))
		}
	)
)

#' Class for dumping arguments.
ArgumentOptionArgdump = R6Class("ArgumentOptionArgdump",
	inherit = ArgumentOption,
	public = list(
		#' @description
		#' Set up the argument.
		initialize = function(){
			self$isCommon = FALSE
			self$name = "Argdump"
			self$sigils = c("--help_argdump")
			self$summary = "Print out argument information."
			self$typeCode = "meta"
		},
		parse = function(argList, forProg){
			forProg$needRun = FALSE
			forProg$needIdiot = FALSE
			progB = forProg$dumpBinary()
			.argopt.help.dumpToStdout(progB)
			return(character(0))
		}
	)
)

#' Class for marking to just idiot check arguments.
ArgumentOptionIdiot = R6Class("ArgumentOptionIdiot",
	inherit = ArgumentOption,
	public = list(
		#' @description
		#' Set up the argument.
		initialize = function(){
			self$isCommon = FALSE
			self$name = "Id10t Check"
			self$sigils = c("--help_id10t")
			self$summary = "Do not actually run, just check arguments."
			self$typeCode = "meta"
		},
		parse = function(argList, forProg){
			forProg$needRun = FALSE
			return(.argopt.help.eatargs(argList,1))
		}
	)
)

#' A boolean flag option.
ArgumentOptionFlag = R6Class("ArgumentOptionFlag",
	inherit = ArgumentOption,
	public = list(
		#' @field The value of the flag.
		value = FALSE,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		initialize = function(name, sigils, summary){
			self$name = name
			self$sigils = sigils
			self$summary = summary
			self$typeCode = "flag"
		},
		parse = function(argList, forProg){
			self$value = TRUE
			return(.argopt.help.eatargs(argList,1))
		}
	)
)

#' Store the value of an enum.
ArgumentOptionEnumValue = R6Class("ArgumentOptionEnumValue",
	public = list(
		#' @field The name of this enum.
		flavor = NA,
		#' @field The set value for the enum.
		value = 0,
		#' @field The number of things registered.
		numRegistered = 0,
		#' @description
		#' Set up an enum.
		#' @param flavor The name of the enum.
		initialize = function(flavor){
			self$flavor = flavor
		}
	)
)

#' A categorical flag option.
ArgumentOptionEnum = R6Class("ArgumentOptionEnum",
	inherit = ArgumentOption,
	public = list(
		#' @field The flavor it refers to.
		flavor = NA,
		#' @field The id of this particular value.
		flavID = -1,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param flavor The value for this flavor of enum.
		initialize = function(name, sigils, summary, flavor){
			self$name = name
			self$sigils = sigils
			self$summary = summary
			self$typeCode = "enum"
			self$flavor = flavor
			self$flavID = flavor$numRegistered
			flavor$numRegistered = 1 + flavor$numRegistered
		},
		parse = function(argList, forProg){
			self$flavor$value = self$flavID
			return(.argopt.help.eatargs(argList,1))
		},
		#' @description
		#' Get whether this is the winning value.
		#' @return Whether it is.
		value = function(){
			return(self$flavor$value == self$flavID)
		},
		dumpInfo = function(){
			packFN = .argopt.structPack.LenText(self$flavor$flavor)
			packCV = .argopt.structPack.Bool(self$value())
			packX = c(packFN, packCV)
			packC = .argopt.help.dumpCommonInfo(self,length(packX))
			return(c(packC,packX))
		}
	)
)

#' An integer option.
ArgumentOptionInteger = R6Class("ArgumentOptionInteger",
	inherit = ArgumentOption,
	public = list(
		#' @field The value of the argument.
		value = 0,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			self$name = name
			self$sigils = sigils
			self$summary = summary
			self$usage = usage
			self$typeCode = "int"
		},
		parse = function(argList, forProg){
			if(length(argList) < 2){
				stop(argList[[1]], " requires a value to parse.")
			}
			self$value = strtoi(argList[[2]])
			if(is.na(self$value)){
				stop(argList[[2]], " is not a valid integer for ", argList[[1]], ".")
			}
			return(.argopt.help.eatargs(argList,2))
		},
		dumpInfo = function(){
			packX = .argopt.structPack.SLong(self$value)
			packC = .argopt.help.dumpCommonInfo(self,length(packX))
			return(c(packC,packX))
		}
	)
)

#' A float option.
ArgumentOptionFloat = R6Class("ArgumentOptionFloat",
	inherit = ArgumentOption,
	public = list(
		#' @field The value of the argument.
		value = 0.0,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			self$name = name
			self$sigils = sigils
			self$summary = summary
			self$usage = usage
			self$typeCode = "float"
		},
		parse = function(argList, forProg){
			if(length(argList) < 2){
				stop(argList[[1]], " requires a value to parse.")
			}
			self$value = as.double(argList[[2]])
			if(is.na(self$value)){
				stop(argList[[2]], " is not a valid float for ", argList[[1]], ".")
			}
			return(.argopt.help.eatargs(argList,2))
		},
		dumpInfo = function(){
			packX = .argopt.structPack.Double(self$value)
			packC = .argopt.help.dumpCommonInfo(self,length(packX))
			return(c(packC,packX))
		}
	)
)

#' A string option.
ArgumentOptionString = R6Class("ArgumentOptionString",
	inherit = ArgumentOption,
	public = list(
		#' @field The value of the argument.
		value = "",
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			self$name = name
			self$sigils = sigils
			self$summary = summary
			self$usage = usage
			self$typeCode = "string"
		},
		parse = function(argList, forProg){
			if(length(argList) < 2){
				stop(argList[[1]], " requires a value to parse.")
			}
			self$value = argList[[2]]
			return(.argopt.help.eatargs(argList,2))
		},
		dumpInfo = function(){
			packX = .argopt.structPack.LenText(self$value)
			packC = .argopt.help.dumpCommonInfo(self,length(packX))
			return(c(packC,packX))
		}
	)
)

#' An integer vector option.
ArgumentOptionIntegerVector = R6Class("ArgumentOptionIntegerVector",
	inherit = ArgumentOption,
	public = list(
		#' @field The value of the argument.
		value = 0,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			self$name = name
			self$sigils = sigils
			self$summary = summary
			self$usage = usage
			self$typeCode = "intvec"
			self$value = integer(0)
		},
		parse = function(argList, forProg){
			if(length(argList) < 2){
				stop(argList[[1]], " requires a value to parse.")
			}
			pValue = strtoi(argList[[2]])
			if(is.na(pValue)){
				stop(argList[[2]], " is not a valid integer for ", argList[[1]], ".")
			}
			self$value = as.integer(c(self$value, pValue))
			return(.argopt.help.eatargs(argList,2))
		}
	)
)

#' An float vector option.
ArgumentOptionFloatVector = R6Class("ArgumentOptionFloatVector",
	inherit = ArgumentOption,
	public = list(
		#' @field The value of the argument.
		value = 0.0,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			self$name = name
			self$sigils = sigils
			self$summary = summary
			self$usage = usage
			self$typeCode = "floatvec"
			self$value = numeric(0)
		},
		parse = function(argList, forProg){
			if(length(argList) < 2){
				stop(argList[[1]], " requires a value to parse.")
			}
			pValue = as.double(argList[[2]])
			if(is.na(pValue)){
				stop(argList[[2]], " is not a valid float for ", argList[[1]], ".")
			}
			self$value = c(self$value, pValue)
			return(.argopt.help.eatargs(argList,2))
		}
	)
)

#' An string vector option.
ArgumentOptionStringVector = R6Class("ArgumentOptionStringVector",
	inherit = ArgumentOption,
	public = list(
		#' @field The value of the argument.
		value = "",
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			self$name = name
			self$sigils = sigils
			self$summary = summary
			self$usage = usage
			self$typeCode = "stringvec"
			self$value = character(0)
		},
		parse = function(argList, forProg){
			if(length(argList) < 2){
				stop(argList[[1]], " requires a value to parse.")
			}
			self$value = c(self$value, argList[[2]])
			return(.argopt.help.eatargs(argList,2))
		}
	)
)

#' An integer vector option.
ArgumentOptionIntegerGreedyVector = R6Class("ArgumentOptionIntegerGreedyVector",
	inherit = ArgumentOption,
	public = list(
		#' @field The value of the argument.
		value = 0,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			self$name = name
			self$sigils = sigils
			self$summary = summary
			self$usage = usage
			self$typeCode = "intvecg"
			self$value = integer(0)
		},
		parse = function(argList, forProg){
			i = 2
			while(i <= length(argList)){
				pValue = strtoi(argList[[i]])
				if(is.na(pValue)){
					break
				}
				self$value = as.integer(c(self$value, pValue))
				i = i+1
			}
			return(.argopt.help.eatargs(argList,i-1))
		}
	)
)

#' An float vector option.
ArgumentOptionFloatGreedyVector = R6Class("ArgumentOptionFloatGreedyVector",
	inherit = ArgumentOption,
	public = list(
		#' @field The value of the argument.
		value = 0.0,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			self$name = name
			self$sigils = sigils
			self$summary = summary
			self$usage = usage
			self$typeCode = "floatvecg"
			self$value = numeric(0)
		},
		parse = function(argList, forProg){
			i = 2
			while(i <= length(argList)){
				pValue = as.double(argList[[i]])
				if(is.na(pValue)){
					break
				}
				self$value = c(self$value, pValue)
				i = i+1
			}
			return(.argopt.help.eatargs(argList,i-1))
		}
	)
)

#' An string vector option.
ArgumentOptionStringGreedyVector = R6Class("ArgumentOptionStringGreedyVector",
	inherit = ArgumentOption,
	public = list(
		#' @field The value of the argument.
		value = "",
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			self$name = name
			self$sigils = sigils
			self$summary = summary
			self$usage = usage
			self$typeCode = "stringvecg"
			self$value = character(0)
		},
		parse = function(argList, forProg){
			i = 2
			while(i <= length(argList)){
				if((i>2) && startsWith(argList[[i]], "--")){
					break
				}
				self$value = c(self$value, argList[[i]])
				i = i+1
			}
			return(.argopt.help.eatargs(argList,i-1))
		}
	)
)

#' An argument that does nothing (useful for ending a greedy vector).
ArgumentOptionNull = R6Class("ArgumentOptionNull",
	inherit = ArgumentOption,
	public = list(
		#' @description
		#' Set up the argument.
		initialize = function(){
			self$name = "Null"
			self$sigils = "--.-"
			self$summary = "Ignored option."
			self$typeCode = "meta"
		},
		parse = function(argList, forProg){
			return(.argopt.help.eatargs(argList,1))
		}
	)
)

.argopt.help.packFileIOExtra = function(forOpt, hasCur){
	toR = raw(0)
	if(hasCur){
		toR = .argopt.structPack.Add.LenText(toR, forOpt$value)
	}
	toR = .argopt.structPack.Add.USLong(length(forOpt$validExts))
	for(ext in forOpt$validExts){
		toR = .argopt.structPack.Add.LenText(toR, ext)
	}
	return(toR)
}

#' Select a file to read.
ArgumentOptionFileRead = R6Class("ArgumentOptionFileRead",
	inherit = ArgumentOptionString,
	public = list(
		#' @field The extensions this can hit.
		validExts = NA,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			super$initialize(name, sigils, summary, usage)
			self$extTypeCode = "fileread"
			self$validExts = list()
		},
		dumpInfo = function(){
			packX = .argopt.help.packFileIOExtra(self,TRUE)
			packC = .argopt.help.dumpCommonInfo(self,length(packX))
			return(c(packC,packX))
		}
	)
)

#' Select a file to write.
ArgumentOptionFileWrite = R6Class("ArgumentOptionFileWrite",
	inherit = ArgumentOptionString,
	public = list(
		#' @field The extensions this can hit.
		validExts = NA,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			super$initialize(name, sigils, summary, usage)
			self$extTypeCode = "filewrite"
			self$validExts = list()
		},
		dumpInfo = function(){
			packX = .argopt.help.packFileIOExtra(self,TRUE)
			packC = .argopt.help.dumpCommonInfo(self,length(packX))
			return(c(packC,packX))
		}
	)
)

#' Select a files to read.
ArgumentOptionFileReadVector = R6Class("ArgumentOptionFileReadVector",
	inherit = ArgumentOptionStringVector,
	public = list(
		#' @field The extensions this can hit.
		validExts = NA,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			super$initialize(name, sigils, summary, usage)
			self$extTypeCode = "fileread"
			self$validExts = list()
		},
		dumpInfo = function(){
			packX = .argopt.help.packFileIOExtra(self,FALSE)
			packC = .argopt.help.dumpCommonInfo(self,length(packX))
			return(c(packC,packX))
		}
	)
)

#' Select a files to write.
ArgumentOptionFileWriteVector = R6Class("ArgumentOptionFileWriteVector",
	inherit = ArgumentOptionStringVector,
	public = list(
		#' @field The extensions this can hit.
		validExts = NA,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			super$initialize(name, sigils, summary, usage)
			self$extTypeCode = "filewrite"
			self$validExts = list()
		},
		dumpInfo = function(){
			packX = .argopt.help.packFileIOExtra(self,FALSE)
			packC = .argopt.help.dumpCommonInfo(self,length(packX))
			return(c(packC,packX))
		}
	)
)

#' Select a files to read.
ArgumentOptionFileReadGreedyVector = R6Class("ArgumentOptionFileReadGreedyVector",
	inherit = ArgumentOptionStringGreedyVector,
	public = list(
		#' @field The extensions this can hit.
		validExts = NA,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			super$initialize(name, sigils, summary, usage)
			self$extTypeCode = "fileread"
			self$validExts = list()
		},
		dumpInfo = function(){
			packX = .argopt.help.packFileIOExtra(self,FALSE)
			packC = .argopt.help.dumpCommonInfo(self,length(packX))
			return(c(packC,packX))
		}
	)
)

#' Select a files to write.
ArgumentOptionFileWriteGreedyVector = R6Class("ArgumentOptionFileWriteGreedyVector",
	inherit = ArgumentOptionStringGreedyVector,
	public = list(
		#' @field The extensions this can hit.
		validExts = NA,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			super$initialize(name, sigils, summary, usage)
			self$extTypeCode = "filewrite"
			self$validExts = list()
		},
		dumpInfo = function(){
			packX = .argopt.help.packFileIOExtra(self,FALSE)
			packC = .argopt.help.dumpCommonInfo(self,length(packX))
			return(c(packC,packX))
		}
	)
)

#' Select a folder to read.
ArgumentOptionFolderRead = R6Class("ArgumentOptionFolderRead",
	inherit = ArgumentOptionString,
	public = list(
		#' @field The extensions this can hit.
		validExts = NA,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			super$initialize(name, sigils, summary, usage)
			self$extTypeCode = "folderread"
			self$validExts = list()
		},
		dumpInfo = function(){
			packX = .argopt.help.packFileIOExtra(self,TRUE)
			packC = .argopt.help.dumpCommonInfo(self,length(packX))
			return(c(packC,packX))
		}
	)
)

#' Select a folder to write.
ArgumentOptionFolderWrite = R6Class("ArgumentOptionFolderWrite",
	inherit = ArgumentOptionString,
	public = list(
		#' @field The extensions this can hit.
		validExts = NA,
		#' @description
		#' Set up the argument.
		#' @param name The reporting name.
		#' @param sigils The sigil(s) to use to invoke this argument.
		#' @param summary A one-line description of the thing.
		#' @param usage An example of how to use the thing.
		initialize = function(name, sigils, summary, usage){
			super$initialize(name, sigils, summary, usage)
			self$extTypeCode = "folderwrite"
			self$validExts = list()
		},
		dumpInfo = function(){
			packX = .argopt.help.packFileIOExtra(self,TRUE)
			packC = .argopt.help.dumpCommonInfo(self,length(packX))
			return(c(packC,packX))
		}
	)
)

#' Base class for programs.
StandardProgram = R6Class("StandardProgram",
	public = list(
		#' @field The reporting name of this program.
		name = NA,
		#' @field A one-line summary of this program.
		summary = "",
		#' @field A long form description of this program.
		description = NA,
		#' @field An example description of this program.
		usage = NA,
		#' @field Version string for this program.
		version = "",
		#' @field The options this program supports.
		options = NA,
		#' @field Whether this needs to run.
		needRun = TRUE,
		#' @field Whether this needs to idiot check its arguments.
		needIdiot = TRUE,
		#' @field Whether there was an error.
		wasError = FALSE,
		#' @description
		#' Set up the basics for a program.
		#' @param name The reporting name of the program.
		#' @param summary A one-line summary.
		#' @param usage An example usage.
		#' @param version The string to print for --version.
		initialize = function(name, summary, usage, version){
			self$name = name
			self$summary = summary
			self$usage = usage
			self$version = version
			self$options = list(
				ArgumentOptionHelp$new(),
				ArgumentOptionVersion$new(),
				ArgumentOptionArgdump$new(),
				ArgumentOptionIdiot$new()
			)
		},
		#' @description
		#' Add an argument to this program.
		#' @param toAdd The argument to add.
		addArgument = function(toAdd){
			self$options[[length(self$options)+1]] = toAdd
			invisible(self)
		},
		#' @description
		#' Parse command line arguments.
		#' @param allArgs The options to parse.
		parse = function(allArgs){
			# parse them
			tmpArgs = allArgs
			while(length(tmpArgs) > 0){
				notParse = TRUE
				for(opt in self$options){
					if(opt$canParse(tmpArgs)){
						notParse = FALSE
						tmpArgs = opt$parse(tmpArgs,self)
						break
					}
				}
				if(notParse){
					stop(tmpArgs[[1]], " is not a known flavor of argument.")
				}
			}
			# idiot check
			if(self$needIdiot){
				for(opt in self$options){
					opt$idiotCheck()
				}
				self$idiotCheck()
			}
			invisible(self)
		},
		#' @description
		#' Dump this to a binary format for external consumption.
		#' @return The raw bytes to throw out.
		dumpBinary = function(){
			toR = raw(0)
			toR = .argopt.structPack.Add.LenText(toR, self$name)
			toR = .argopt.structPack.Add.LenText(toR, self$summary)
			toR = .argopt.structPack.Add.LenText(toR, self$description)
			toR = .argopt.structPack.Add.LenText(toR, self$usage)
			toR = .argopt.structPack.Add.USLong(toR, length(self$options))
			for(opt in self$options){
				curOR = opt$dumpInfo()
				toR = c(toR,curOR)
			}
			return(toR)
		},
		#' @description
		#' Run The program.
		run = function(){
			if(self$needRun){
				self$baseRun()
			}
			invisible(self)
		},
		#' @description
		#' Do any extra idiot checks.
		idiotCheck = function(){
			invisible(self)
		},
		#' @description
		#' Actually do the run.
		baseRun = function(){
			stop(self$name, " is defined as abstract base class...")
		}
	)
)

#' A set of possible programs.
StandardProgramSet = R6Class("StandardProgramSet",
	public = list(
		#' @field The reporting name of this set.
		name = NA,
		#' @field A one-line summary of this set.
		summary = "",
		#' @field Version string for this set.
		version = "",
		#' The names of the programs in question.
		progNames = NA,
		#' The constructors of the programs in question.
		progCons = NA,
		#' @description
		#' Set up the basics for a set.
		#' @param name The reporting name of the program.
		#' @param summary A one-line summary.
		#' @param version The string to print for --version.
		initialize = function(name, summary, version){
			self$name = name
			self$summary = summary
			self$version = version
			self$progNames = character(0)
			self$progCons = list()
		},
		#' @description
		#' Add a program to this thing.
		#' @param pclass The class of program to add.
		addProgram = function(pclass){
			addCon = pclass$new
			addName = pclass$new()$name
			self$progNames = c(self$progNames, addName)
			self$progCons[[length(self$progCons)+1]] = addCon
			invisible(self)
		},
		#' @description
		#' Parse command line arguments.
		#' @param allArgs The options to parse.
		#' @return The program to run, or NA if nothing should run.
		parse = function(allArgs){
			#  idiot check
				if(length(allArgs) == 0){
					stop(self$name, " requires the name of the program you want to run.")
				}
			# figure out if first argument is special
				firstArg = allArgs[[1]]
				if((firstArg == "--help") || (firstArg == "-h") || (firstArg == "/?")){
					write(self$name, stdout())
					write(self$summary, stdout())
					write("", stdout())
					for(spc in self$progCons){
						curOP = spc()
						write(curOP$name, stdout())
						write(curOP$summary, stdout())
					}
					return(NA)
				}
				if(firstArg == "--version"){
					write(self$version, stdout())
					return(NA)
				}
				if(firstArg == "--help_argdump"){
					toR = raw(0)
					toR = .argopt.structPack.Add.LenText(toR, self$name)
					toR = .argopt.structPack.Add.LenText(toR, self$summary)
					toR = .argopt.structPack.Add.USLong(toR, length(self$progNames))
					for(spc in self$progCons){
						curOP = spc()
						toR = .argopt.structPack.Add.LenText(toR, curOP$name)
						toR = .argopt.structPack.Add.LenText(toR, curOP$summary)
					}
					.argopt.help.dumpToStdout(toR)
					return(NA)
				}
			# find the requested program
				i = 1
				gotProg = NA
				while(i <= length(self$progNames)){
					if(self$progNames[[i]] == firstArg){
						gotProg = self$progCons[[i]]()
						break
					}
					i = i + 1
				}
				if(is.na(gotProg)){
					stop(firstArg, " is not a known program.")
				}
			# let it parse and return
				gotProg$parse(.argopt.help.eatargs(argList,1))
			return(gotProg)
		}
	)
)



