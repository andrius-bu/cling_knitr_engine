# Note: RStudio needs to be running ...
# https://rstudio.github.io/rstudio-extensions/rstudioapi.html
# https://github.com/rstudio/rstudio/issues/6892
#SOLUTION: Run in RStudio CONSOLE: rmarkdown::render("my_rmd_code_file.Rmd")
# Create a global variable for the terminal:
while(length(rstudioapi::terminalList()) > 0){
  rstudioapi::terminalKill(rstudioapi::terminalList()[1])
}
ClingRStudioTerminal <<- rstudioapi::terminalCreate(caption = "RStudioClingTerminal", 
                                                    show = FALSE)
rstudioapi::terminalSend(ClingRStudioTerminal, "cling\n") 

# The knitr_engine for cling:
knitr::knit_engines$set(cling = function(options) {
  args <- ifelse(is.null(options$engine.opts$cling$args), "", options$engine.opts$cling$args)
  if(options$eval){
    # If we want to clear the environment - close the terminal and create a new one:
    if(sum(options$engine.opts$cling$clearEnv) == 1){
      # Quit cling:
      rstudioapi::terminalSend(ClingRStudioTerminal, ".q\n")
      # Close the terminal
      rstudioapi::terminalKill(ClingRStudioTerminal)
      # Create a new terminal instance
      ClingRStudioTerminal <<- rstudioapi::terminalCreate(caption = "RStudioClingTerminal", 
                                                      show = FALSE)
      # wait for it to start
      while (!rstudioapi::terminalRunning(ClingRStudioTerminal)) {
        Sys.sleep(0.1)
      }
      # Start cling
      rstudioapi::terminalSend(ClingRStudioTerminal, paste0("cling ", args, "\n"))
    }
    # https://cran.r-project.org/web/packages/rstudioapi/vignettes/terminal.html
    if (!rstudioapi::terminalRunning(ClingRStudioTerminal)) {
      # start the terminal shell back up, but don't bring to front
      rstudioapi::terminalActivate(ClingRStudioTerminal, show = FALSE)
      # wait for it to start
      while (!rstudioapi::terminalRunning(ClingRStudioTerminal)) {
        Sys.sleep(0.1)
      }
    }
    # Clear the current terminal window:
    rstudioapi::terminalClear(ClingRStudioTerminal)
    
    # https://stackoverflow.com/a/25105442
    # Redirect cling output to a temporary txt file:
    #rstudioapi::terminalSend(ClingRStudioTerminal, ".&> RStudioClingOutputTMP.txt\n")
    rstudioapi::terminalSend(ClingRStudioTerminal, ".1> RStudioClingOutputTMP_stdout.txt\n")
    rstudioapi::terminalSend(ClingRStudioTerminal, ".2> RStudioClingOutputTMP_sterr.txt\n")
    code <- paste(options$code, collapse = '\n')
    
    if((time_start <- Sys.time()) > 0){
      # Only run the code AFTER assigning the start time:
      rstudioapi::terminalSend(ClingRStudioTerminal, paste0(code, "\n"))
    }
    # To obtain the results programmatically, wait for cling to finish saving:
    while(tail(rstudioapi::terminalBuffer(ClingRStudioTerminal), 1) != "[cling]$ "){
      Sys.sleep(0.1)
    }
    time_end   <- Sys.time()
    
    suppressWarnings({
      # Read the output:
      out <- readLines("RStudioClingOutputTMP_stdout.txt")
      out <- paste(out, collapse = '\n')
      # Check if there are any errors:
      err <- readLines("RStudioClingOutputTMP_sterr.txt") 
      err <- paste(err, collapse = '\n')
    })
    if(length(err) > 0 & err != ""){
      if(!options$error) stop(err)
      out <- paste0(out, ifelse(out != "", "\n", ""),
                    paste0(rep("~", 80), collapse = ""),
                    "\n\nknitr: Errors while running chunk:\n", 
                    err,
                    paste0(rep("~", 80), collapse = ""),
                    "\n\nknitr: new variables NOT saved in session, however, existing variable values changed!")
      # Use .undo [n] to UNDO the input lines from this chunk:
      rstudioapi::terminalSend(ClingRStudioTerminal, paste0(".undo ", length(options$code), "\n"))
      # TODO: maybe undo only if !options$error ?
    }
    # Remove the file
    # writeLines("", "RStudioClingOutputTMP.txt")
    
    
    # Check if code created .png, .pdf, .jpg files:
    # browser()
    has_plots <- FALSE
    # Temporary disable auto plot creation - unsure how to correctly 
    # track the names and location of the files saved
    if(FALSE & grepl("\\.png|\\.jpg|\\.jpeg|\\.pdf", code)){
      # Get files of this type:
      tmp_img_files <- list.files(pattern = "\\.png$|\\.jpg$|\\.jpeg$|\\.pdf$")
      # Time difference between the image file modification time 
      # and the time that the code was executed
      # should be small
      # TODO: improve this check
      t_check <-  abs(time_start - file.info(tmp_img_files)$mtime - (time_end - time_start)) < 0.5
      tmp_img_files <- tmp_img_files[t_check]
      if(length(tmp_img_files) > 0){
        has_plots <- TRUE
      }else{
        # browser()
      }
      
    }
  }else{
    out <- ""
    has_plots <- FALSE
  }
  
  result <- list(code = "", out = out)
  if(options$echo){
    result$code <- options$code
  }
  
  # Add c++ highlighting:
  options$engine = 'cpp'
  
  # browser()
  # Return the results:
  if(has_plots){
    plt_out <- knitr::engine_output(
      options, 
      out = list(knitr::include_graphics(tmp_img_files))
    )
    result <- knitr::engine_output(
      options, 
      code = result$code,
      out = result$out
    )
    # browser()
    return(paste0(result, plt_out, sep = "\n\n"))
  }else{
    knitr::engine_output(options, result$code, out = result$out)
  }
})
