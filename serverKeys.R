####################################
#KEYBOARD: capture keyboard events

serverKeys <- function(session,input) {
if (switches$doKeys) {
  keyrespond<-observeEvent(input$pressedKey,{
    # print(input$keypress)
    
    if (input$keypress==16) shiftKeyOn<<-TRUE
    if (input$keypress==17) controlKeyOn<<-TRUE
    if (input$keypress==18) altKeyOn<<-TRUE
    
    
    # control-alt-l - switch to online version
    if (is_local && input$keypress==76 && controlKeyOn && altKeyOn){
      switches$doReplications<<-FALSE
      switches$doWorlds<<-FALSE
      removeTab("Design","Replicate",session)
      removeTab("Hypothesis","World",session)
      removeTab("HypothesisDiagram","World",session)
      removeTab("FileTab","Batch",session)
    }
    
    # control-alt-m - switch to offine version
    if (input$keypress==77 && controlKeyOn && altKeyOn){
      if (!switches$doReplications) {
        insertTab("Design",replicationTabReserve,"Anomalies","after",select=FALSE,session)
        switches$doReplications<<-TRUE
      }
      if (!switches$doWorlds) {
        insertTab("Hypothesis",worldTabReserve,"Effects","after",select=FALSE,session)
        insertTab("HypothesisDiagram",worldDiagramReserve,"Hypothesis","after",select=FALSE,session)
        switches$doWorlds<<-TRUE
      }
    }
    
    # control-V
    if (is_local && input$keypress==86 && controlKeyOn){
      mergeVariables<<-FALSE
      # get the raw data
      raw_h1<-read_clip()
      header<-strsplit(raw_h1[1],"\t")[[1]]
      raw_data<-read_clip_tbl()
      # read_clip_tbl doesn't like some characters like | and =
      colnames(raw_data)<-header
      if (nrow(raw_data)>0 && ncol(raw_data)>0)
        getNewVariables(raw_data)
    }
    
    # control-c
    if (is_local && input$keypress==67 && controlKeyOn){
      data<-exportData()
      write_clip(data,allow_non_interactive = TRUE)
    }
    
    # control-alt-e set world to exp(0.2)
    if (input$keypress==69 && controlKeyOn && altKeyOn){
      updateSelectInput(session,"world_distr",selected="Exp")
      updateSelectInput(session,"world_distr_rz",selected="z")
      updateNumericInput(session,"world_distr_k",value=0.2)
    }
    
    # control-alt-n set sample size to big (1000)
    if (input$keypress==78 && controlKeyOn && altKeyOn){
      updateNumericInput(session,"sN",value=1000)
    }
    
    # control-alt-r set effect size to 0.3
    if (input$keypress==82 && controlKeyOn && altKeyOn){
      updateNumericInput(session,"rIV",value=0.3)
    }
    
    # control-alt-3 set IV2
    if (input$keypress==51 && controlKeyOn && altKeyOn){
      updateSelectInput(session,"IV2choice",selected="IV2")
    }
    
    # control-alt-w set sample usage to within
    if (input$keypress==87 && controlKeyOn && altKeyOn){
      updateSelectInput(session,"sIV1Use",selected="Within")
      updateSelectInput(session,"sIV2Use",selected="Within")
    }
    
    # control-alt-d do debug
    if (input$keypress==68 && controlKeyOn && altKeyOn){
      toggleModal(session, modalId = "debugOutput", toggle = "open")
      IV<-updateIV()
      IV2<-updateIV2()
      DV<-updateDV()
      
      effect<-updatePrediction()
      design<-updateDesign()
      evidence<-updateEvidence()
      expected<-updateExpected()
      
      validSample<<-TRUE
      
      if (is.null(IV2)) {
        nc=7
        effect$rIV=0.3
      } else {
        nc=12
        effect$rIV=0.3
        effect$rIV2=-0.3
        effect$rIVIV2DV=0.5
      }
      design$sN<-1000
      
      expected$nSims<-100
      expected$EvidenceExpected_type<-"EffectSize"
      expected$append<-FALSE
      
      if (is.null(IV2)) {
        result<-doSampleAnalysis(IV,IV2,DV,effect,design,evidence)
      }
      doExpectedAnalysis(IV,IV2,DV,effect,design,evidence,expected)
      op<-testDebug(IV,IV2,DV,effect,design,evidence,expected,result,expectedResult)
      
      if (!is.null(IV2)) {
        effect$rIVIV2=0.25
        doExpectedAnalysis(IV,IV2,DV,effect,design,evidence,expected)
        op<-c(op,testDebug(IV,IV2,DV,effect,design,evidence,expected,result,expectedResult))
        
        effect$rIVIV2=-0.25
        doExpectedAnalysis(IV,IV2,DV,effect,design,evidence,expected)
        op<-c(op,testDebug(IV,IV2,DV,effect,design,evidence,expected,result,expectedResult))
      }
      
      output$plotPopUp<-renderPlot(reportPlot(op,nc,length(op)/nc,2))
      return()
    }
    
  })
  
  keyrespondUp<-observeEvent(input$keyrelease,{
    if (input$keyrelease==18) altKeyOn<<-FALSE
    if (input$keyrelease==17) controlKeyOn<<-FALSE
    if (input$keyrelease==16) shiftKeyOn<<-FALSE
  })
  
}

}