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
  if(options$eval){
    # If we want to clear the environment - close the terminal and create a new one:
    if(sum(options$engine.opts$cling == 'ClearClingEnv') == 1){
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
      rstudioapi::terminalSend(ClingRStudioTerminal, "cling\n")
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
    rstudioapi::terminalSend(ClingRStudioTerminal, paste0(code, "\n"))
    
    # To obtain the results programmatically, wait for cling to finish saving:
    while(tail(rstudioapi::terminalBuffer(ClingRStudioTerminal), 1) != "[cling]$ "){
      Sys.sleep(0.1)
    }
    
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
  }else{
    out <- ""
  }
  
  # Add c++ highlighting:
  options$engine = 'cpp'
  
  # Return the results:
  knitr::engine_output(options, options$code, out)
})