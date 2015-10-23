#! /usr/bin/env Rscript

# Exit codes.
error <- data.frame(
    io = 10,
    argparse = 11,
    filetype = 12
)

# Install required packages.
is.installed <- function(pkg) {
    return(pkg %in% rownames(installed.packages()))
}
is.attached <- function(pkg) {
    return(pkg %in% .packages())
}
install.and.attach <- function(pkg) {
    if(!(is.installed(pkg))) {
        install.packages(pkg)
    }
    if(!(is.attached(pkg))) {
        library(pkg, character.only = TRUE)
    }
}
required.packages <- c("getopt", "tools")
loading.output <- sapply(required.packages, invisible(install.and.attach))

# Process options.
no.args <- 0
required <- 1
optional <- 2
input.args <- matrix(c(
    "candidates", "c", required, "character",
    "assessors",  "a", required, "character",
    "exams",      "e", required, "character",
    "locations",  "l", required, "character"
), byrow = TRUE, ncol = 4)
optional.args <- matrix(c(
    "outfile",    "o", optional, "character",
    "verbose",    "v", optional, "character",
    "help",       "h", optional, "character"
), byrow = TRUE, ncol = 4)
spec <- rbind(input.args, optional.args)
opt <- getopt(spec)
usage <- function() {
    cat("lachesis.r -c FILENAME -a FILENAME -e FILENAME -l FILENAME [-o FILENAME]\n")
    cat("\n")
    cat("Generates a roster that assigns assessors to cases in an exam matrix\n")
    cat("and timetables candidates to cycle between assessors at a venue.\n")
    cat("\n")
    cat("Valid filetypes are csv, xls and xlsx.")
    cat("\n")
    cat("    --candidates -c    Spreadsheet with candidate info.\n")
    cat("    --assessors  -a    Spreadsheet with assessor info.\n")
    cat("    --exams      -e    Spreadsheet with exam matrix info.\n")
    cat("    --locations  -l    Spreadsheet with venue info.\n")
    cat("    --outfile    -o    Spreadsheet for storing final master roster.\n")
    cat("    --verbose    -v    Print debugging information to stderr.\n")
    cat("    --help       -h    Print this usage information.\n")
    cat("\n")
    cat("If --outfile is not given, will output to stdout.\n")
}
if(!is.null(opt$help)) {
    usage()
    quit(status = 0)
}
verbose <- FALSE
if(!is.null(opt$verbose)) {
    verbose <- TRUE
}

# Validate options.
validate.option <- function(option.name) {
    option <- opt[[option.name]]
    if(is.null(option)) {
        cat("Required option not given:", option.name, "\n")
        return(FALSE)
    }
    if(option.name != "outfile" && !file.exists(option)) {
        cat("File does not exist:", option, "\n")
        return(FALSE)
    }
    return(TRUE)
}
required.args <- which(spec[,3] == required)
opt.output <- sapply(spec[required.args, 1], validate.option)
if(!all(opt.output)) {
    quit(status = error$argparse)
}
output <- "stdout"
if(!is.null(opt$outfile)) {
    output <- opt$outfile
}

# Extract data from input files.
if(verbose) {
    sink("/dev/stderr")
    cat("Reading data files ... ")
    sink()
}
load.data <- function(option.name) {
    filename <- opt[[option.name]]
    if(!file.exists(filename)) {
        cat("File does not exist:", filename, "\n")
        quit(status = error$io)
    }
    x <- file_ext(filename)
    input <- NULL
    if(x == "csv") {
        input <- read.csv(filename)
    } else if (x %in% c("xls", "xlsx")) {
        suppressMessages(install.and.attach("xlsx"))
        input <- read.xlsx(filename, 1)
    } else {
        cat("Unknown file extension", x, "for file name", filename, "\n")
        quit(status = error$filetype)
    }
    if(verbose) {
        sink("/dev/stderr")
        cat(filename, "... ")
        sink()
    }
    return(input)
}
data <- lapply(input.args[,1], load.data)
cat("done.\n")
names(data) <- input.args[,1]
data$exams <- data$exams[1:7] # Only keep relevant data.
