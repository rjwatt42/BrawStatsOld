#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

source("plotStatistic.R")
source("plotES.R")
source("plotReport.R")

source("drawVariable.R")
source("drawPopulation.R")
source("drawPrediction.R")

source("drawSample.R")
source("drawDescription.R")
source("drawInference.R")
source("drawMeta.R")
source("drawExplore.R")
source("drawLikelihood.R")

source("sampleMake.R")
source("sampleAnalyse.R")
source("sampleLikelihood.R")
source("samplePower.R")
source("sampleRead.R")
source("sampleCheck.R")
source("Johnson_M.R")
source("sampleShortCut.R")

source("reportSample.R")
source("reportDescription.R")
source("reportInference.R")
source("reportExpected.R")
source("reportMetaAnalysis.R")
source("reportExplore.R")
source("reportLikelihood.R")

source("runMetaAnalysis.R")
source("runExplore.R")
source("runLikelihood.R")
source("runBatchFiles.R")

source("wsRead.R")
source("typeCombinations.R")

source("drawInspect.R")
source("isSignificant.R")

graphicSource="Main"

####################################

shinyServer(function(input, output, session) {
  
  source("myGlobal.R")
  source("runDebug.R")
  
####################################
# BASIC SET UP that cannot be done inside ui.R  
  shinyjs::hideElement(id= "EvidenceHypothesisApply1")
  shinyjs::hideElement(id= "EvidenceHypothesisApply")
  shinyjs::hideElement(id= "LGEvidenceHypothesisApply")
  shinyjs::hideElement(id= "Using")
  shinyjs::hideElement(id="EvidenceExpectedStop")
  updateSelectInput(session, "IVchoice", choices = variables$name, selected = variables$name[1])
  updateSelectInput(session, "IV2choice", choices = c("none",variables$name), selected = "none")
  updateSelectInput(session, "DVchoice", choices = variables$name, selected = variables$name[3])
  
  if (switches$doCheating) {
    exploreDesignChoices<<-c(exploreDesignChoices,"Cheating")
  } else {
    shinyjs::hideElement(id="Cheating")
    shinyjs::hideElement(id="LGEvidenceCheating")
    shinyjs::hideElement(id="LGExploreCheating")
    shinyjs::hideElement(id="LGlikelihoodCheating")
  }
  
  if (switches$doReplications) {
    exploreDesignChoices<<-c(exploreDesignChoices,"Replications")
  }
  
  if (switches$doWorlds) {
    exploreHypothesisChoices<<-c(exploreHypothesisChoices,"Worlds")
  }
  
  updateSelectInput(session,"Explore_typeD",choices=designChoices[exploreDesignChoices])
  updateSelectInput(session,"LGExplore_typeD",choices=designChoices[exploreDesignChoices])
  updateSelectInput(session,"Explore_typeH",choices=hypothesisChoices2[exploreHypothesisChoices])
  updateSelectInput(session,"LGExplore_typeH",choices=hypothesisChoices2[exploreHypothesisChoices])
  
####################################
  
  source("serverKeys.R",local=TRUE)

  observeEvent(input$LoadExtras,
               {
                 if (input$LoadExtras)
                 loadExtras()
               })
####################################
# other housekeeping
  observeEvent(input$allScatter,{
    allScatter<<-input$allScatter
  }
  )

  observeEvent(input$Explore_VtypeH, {
      if (input$Explore_VtypeH=="levels") {
        updateSelectInput(session,"Explore_typeH",selected="DV")
      }
  }
  )
  
  observeEvent(input$sN, {
    n<-input$sN
    if (!is.null(n) && !is.na(n)) {
    if (n<1 && n>0) {
      n<-rw2n(input$rIV,n,2)
      updateNumericInput(session,"sN",value=n)
    }
    }
  }
  )
  
  observeEvent(input$Hypothesis,{
    if (input$Hypothesis=="World") {
      updateTabsetPanel(session,"HypothesisDiagram",selected = "World")
    }
  })
  
  observeEvent(input$Evidence,{
    if (input$Evidence=="Expected") {
      updateTabsetPanel(session,"Graphs",selected = "Expected")
    }
    if (input$Evidence=="MetaAnalysis") {
      updateTabsetPanel(session,"Graphs",selected = "MetaAnalysis")
    }
  })
  
  observeEvent(input$world_distr, {
    if (input$world_distr!="Single" && input$world_distr_k==0) {
      updateNumericInput(session,"world_distr_k",value=0.2)
    }
  }
  )
  
  observeEvent(input$STMethod, {
    STMethod<<-input$STMethod
    switch (STMethod,
            "NHST"={
              updateNumericInput(session,"alpha",value=alpha)
              shinyjs::hideElement("evidencePrior")
              shinyjs::hideElement("STPrior")
              shinyjs::hideElement("evidenceLLR1")
              shinyjs::hideElement("evidenceLLR2")
              shinyjs::hideElement("llr1")
              shinyjs::hideElement("llr2")
            },
            "sLLR"={
              shinyjs::hideElement("evidencePrior")
              shinyjs::hideElement("STPrior")
              shinyjs::showElement("evidenceLLR1")
              shinyjs::showElement("evidenceLLR2")
              shinyjs::showElement("llr1")
              shinyjs::showElement("llr2")
              },
            "dLLR"={
              shinyjs::showElement("evidencePrior")
              shinyjs::showElement("STPrior")
              shinyjs::hideElement("evidenceLLR1")
              shinyjs::hideElement("evidenceLLR2")
              shinyjs::hideElement("llr1")
              shinyjs::hideElement("llr2")
            }
    )
  })
  observeEvent(input$alpha, {
    alpha<<-input$alpha
    alphaLLR<<-0.5*qnorm(1-alpha/2)^2
  })
  
  observeEvent(input$evidenceInteractionOnly,{
    showInteractionOnly<<-input$evidenceInteractionOnly
  })
  
  observeEvent(input$pScale,{
    pPlotScale<<-input$pScale
  })
  
  observeEvent(input$wScale,{
    wPlotScale<<-input$wScale
  })
  
  observeEvent(input$nScale,{
    nPlotScale<<-input$nScale
  })
  
  
####################################
# generic warning dialogue
  
  hmm<-function (cause) {
    showModal(
      modalDialog(style = paste("background: ",subpanelcolours$hypothesisC,";",
                                "modal {background-color: ",subpanelcolours$hypothesisC,";}"),
                  title="Careful now!",
                  size="s",
                  cause,
                  
                  footer = tagList( 
                    actionButton("MVproceed", "OK")
                  )
      )
    )
  }
  
  observeEvent(input$MVproceed, {
    removeModal()
  })
  
####################################
# QUICK HYPOTHESES
  
  
  observeEvent(input$Hypchoice,{
    result<-getTypecombination(input$Hypchoice)
    validSample<<-FALSE
    
    setIVanyway(result$IV)
    setIV2anyway(result$IV2)
    setDVanyway(result$DV)
    
    updateSelectInput(session,"sIV1Use",selected=result$IV$deploy)
    updateSelectInput(session,"sIV2Use",selected=result$IV2$deploy)

    # 3 variable hypotheses look after themselves
    #
    if (!is.null(IV2)) {
      editVar$data<<-editVar$data+1
    }    
  })
  
  observeEvent(input$Effectchoice,{
    switch (input$Effectchoice,
            "e0"={
              updateNumericInput(session,"rIV",value=0)    
              updateNumericInput(session,"rIV2",value=0)    
              updateNumericInput(session,"rIVIV2",value=0)    
              updateNumericInput(session,"rIVIV2DV",value=0)    
            },
            "e1"={
              updateNumericInput(session,"rIV",value=0.3)    
              updateNumericInput(session,"rIV2",value=-0.3)    
              updateNumericInput(session,"rIVIV2",value=0.0)    
              updateNumericInput(session,"rIVIV2DV",value=0.5)    
            },
            "e2"={
              updateNumericInput(session,"rIV",value=0.2)    
              updateNumericInput(session,"rIV2",value=0.4)    
              updateNumericInput(session,"rIVIV2",value=-0.8)    
              updateNumericInput(session,"rIVIV2DV",value=0.0)    
            }
    )
    
  })
  
source("sourceUpdateData.R",local=TRUE)
  
####################################
# VARIABLES  
  # make basic variables    
  IV<-variables[1,]
  IV2<-variables[2,]
  DV<-variables[3,]
  MV<-IV

  source("sourceInspectVariables.R",local=TRUE)
  source("sourceVariables.R",local=TRUE)
  
  source("sourceLGDisplay.R",local=TRUE)
  
  source("sourceUpdateVariables.R",local=TRUE)
  source("sourceUpdateSystem.R",local=TRUE)
  
  source("sourceSystemDiagrams.R",local=TRUE)
  
  source("sourceSingle.R",local=TRUE)
  source("sourceMetaAnalysis.R",local=TRUE)
  source("sourceExpected.R",local=TRUE)
  
  source("sourceExplore.R",local=TRUE)
  
  source("sourceLikelihood.R",local=TRUE)
  source("sourceFiles.R",local=TRUE)
  # end of everything        
})

