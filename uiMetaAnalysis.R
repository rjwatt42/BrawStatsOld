# world tab

metaPanel<-function(prefix="",asTable=FALSE,doAnyway=FALSE) {
  
  metaTable<-
    wellPanel(
      style = paste("background: ",subpanelcolours$simulateC,";"),
      tags$table(width = "100%",class="myTable",
                 tags$tr(
                   tags$td(width = "30%", tags$div(style = localStyle, "No studies:")
                   ),
                   tags$td(width = "30%", tags$div(style = localStyle, ""),
                           numericInput(paste0(prefix,"meta_nStudies"), label=NULL,value=metaAnalysis$nstudies,step=100)
                   ),
                   tags$td(width = "15%"),
                   tags$td(width = "5%"),
                   tags$td(width = "15%", tags$div(style = localStyle, "p(sig)")
                   ),
                   tags$td(width = "5%", tags$div(style = localStyle, ""),
                            checkboxInput(paste0(prefix,"meta_psigStudies"), label=NULL,value=metaAnalysis$sig_only)
                   ),
                 ),
                 tags$tr(
                   tags$td(width = "30%",tags$div(style = localStyle, "Analysis:")
                   ),
                   tags$td(width = "30%",
                           selectInput(paste0(prefix, "meta_fixedAnal"),label=NULL,
                                       choices=c("fixed","random"),
                                       selected=metaAnalysis$meta_fixedAnal,
                                       selectize=FALSE
                           )
                   ),
                   tags$td(width = "15%", tags$div(style = localStyle, "nulls:")),
                   tags$td(width = "5%", tags$div(style = localStyle, ""),
                           checkboxInput(paste0(prefix,"meta_nullAnal"), label=NULL,value=metaAnalysis$meta_nullAnal)
                   ),
                   tags$td(width = "15%", tags$div(style = localStyle, "p(bias)")),
                   tags$td(width = "5%", tags$div(style = localStyle, ""),
                           checkboxInput(paste0(prefix,"meta_psigAnal"), label=NULL,value=metaAnalysis$meta_psigAnal)
                   ),
                 )
      ),
      tags$table(width = "100%",class="myTable",
                 tags$tr(
                   tags$td(width = "15%", tags$div(style = localStyle, "Runs:")),
                   tags$td(width = "35%", 
                           selectInput(paste0(prefix,"meta_runlength"),label=NULL,
                                       c("1" = "1",
                                         "2" = "2",
                                         "10" = "10",
                                         "50" = "50",
                                         "100" = "100",
                                         "250" = "250",
                                         "500" = "500",
                                         "1000" = "1000"),
                                       selected = "1",
                                       selectize=FALSE)
                   ),
                   tags$td(width = "15%", tags$div(style = localStyle, "")),
                   tags$td(width = "10%", tags$div(style = localStyle, "Append:")),
                   tags$td(width = "5%", checkboxInput(paste0(prefix,"meta_append"), label=NULL,value=metaAnalysis$append)),
                   tags$td(width = "20%",actionButton(paste0(prefix,"metaRun"), "Run")
                   )
                 )
      )
    )
  if (!asTable) {
    metaTable<-tabPanel("MetaAnalysis",value="MetaAnalysis",
                        style = paste("background: ",subpanelcolours$evidenceC),
                        metaTable)
  }
  return(metaTable)
  # if (switches$doMetaAnalysis || doAnyway){
  #   return(metaTable)
  # } else {
  #   return(c())
  # }
}

