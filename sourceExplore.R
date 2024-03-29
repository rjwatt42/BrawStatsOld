# EXPLORE    
# UI changes  
# set explore variable from UI
# calculations
# outputs (graph and report)

# local variables
lastExplore<-explore
showProgress<-TRUE

notRunningExplore<-TRUE

# main variable    
resetExplore<-function(){
  exploreResult<<-list(result=list(count=0,rIVs=c(),pIVs=c(),rIV2=c(),pIV2=c(),rIVIV2DV=c(),pIVIV2DV=c(),rpIVs=c(),nvals=c(),wIVs=c(),psig25=c(),psig=c(),psig75=c(),vals=c(),ks=c(),pnulls=c(),Ss=c()),
                       nullresult=list(count=0,rIVs=c(),pIVs=c(),rIV2=c(),pIV2=c(),rIVIV2DV=c(),pIVIV2DV=c(),rpIVs=c(),nvals=c(),wIVs=c(),psig25=c(),psig=c(),psig75=c(),vals=c()),
                       nsims=0,
                       Explore_show=NA,
                       Explore_typeShow=NA,
                       evidence=evidence
  )
}
resetExplore()

# UI changes
# go to the explore tabs 
# and set the explore run valid
observeEvent(c(input$exploreRunH,input$exploreRunD,input$exploreRunM),{
  if (any(c(input$exploreRunH,input$exploreRunD,input$exploreRunM))>0) {
    validExplore<<-TRUE
    updateTabsetPanel(session, "Graphs",selected = "Explore")
    updateTabsetPanel(session, "Reports",selected = "Explore")
  }
},priority=100)
observeEvent(c(input$LGexploreRunH,input$LGexploreRunD,input$LGexploreRunM),{
  if (any(c(input$LGexploreRunH,input$LGexploreRunD,input$LGexploreRunM)>0))
  {validExplore<<-TRUE
  }
},priority=100)

# and watch for IV2 appearing
observeEvent(input$IV2choice,{
  if (input$IV2choice=="none") {
    updateSelectInput(session,"Explore_typeH", choices=hypothesisChoices2[exploreHypothesisChoices])
  }
  else {
    updateSelectInput(session,"Explore_typeH", choices=hypothesisChoices3)
  }
})
# watch for changes to design
observeEvent(input$Explore_typeD,{
  if (input$Explore_typeD=="SampleSize") {
    updateNumericInput(session,"Explore_nRange",value=250,min=10,step=50)
    updateNumericInput(session,"LGExplore_nRange",value=250,min=10,step=50)
  }
  if (input$Explore_typeD=="Repeats") {
    updateNumericInput(session,"Explore_nRange",value=7,min=1,step=1)
    updateNumericInput(session,"LGExplore_nRange",value=7,min=1,step=1)
  }
})

# here's where we start a run
observeEvent(c(input$exploreRunH,input$exploreRunD,input$exploreRunM,
               input$LGexploreRunH,input$LGexploreRunD,input$LGexploreRunM),
             {
               runPressed<-c(input$exploreRunH,input$exploreRunD,input$LGexploreRunH,input$LGexploreRunD)
               if (switches$doMetaAnalysis) runPressed<-c(runPressed,input$exploreRunM,input$LGexploreRunM)
               
               if (notRunningExplore) {
                 if (input$evidenceLongHand) {
                   gain<-1
                 } else {
                   gain<-1
                 }
                 switch (input$ExploreTab,
                         "Hypothesis"={
                           if (!input$ExploreAppendH) {resetExplore()}
                           exploreResult$nsims<<-exploreResult$result$count+as.numeric(input$Explore_lengthH)*gain
                         },
                         "Design"={
                           if (!input$ExploreAppendD) {resetExplore()}
                           exploreResult$nsims<<-exploreResult$result$count+as.numeric(input$Explore_lengthD)*gain
                         },
                         "MetaAnalysis"={
                           if (!input$ExploreAppendM) {resetExplore()}
                           exploreResult$nsims<<-exploreResult$result$count+as.numeric(input$Explore_lengthM)*gain
                         }
                 )
                 if (any(runPressed)) {
                   updateActionButton(session,"exploreRunH",label=stopLabel)
                   updateActionButton(session,"exploreRunD",label=stopLabel)
                   updateActionButton(session,"exploreRunM",label=stopLabel)
                   updateActionButton(session,"LGexploreRunH",label=stopLabel)
                   updateActionButton(session,"LGexploreRunD",label=stopLabel)
                   updateActionButton(session,"LGexploreRunM",label=stopLabel)
                   notRunningExplore<<-FALSE
                 }
               } else {
                 exploreResult$nsims<<-exploreResult$result$count
                 updateActionButton(session,"exploreRunH",label="Run")
                 updateActionButton(session,"exploreRunD",label="Run")
                 updateActionButton(session,"exploreRunM",label="Run")
                 updateActionButton(session,"LGexploreRunH",label="Run")
                 updateActionButton(session,"LGexploreRunD",label="Run")
                 updateActionButton(session,"LGexploreRunM",label="Run")
                 notRunningExplore<<-TRUE
               }
             },priority=100)


# set explore variable from UI    
# update explore values    
updateExplore<-function(){
  explore<-lastExplore
  if (is.element(input$ExploreTab,c("Hypothesis","Design","MetaAnalysis"))) {
    switch (input$ExploreTab,
            "Hypothesis"={
              l<-list(Explore_type=input$Explore_typeH,
                      Explore_show=input$Explore_showH, 
                      Explore_typeShow=input$Explore_typeShowH, 
                      Explore_whichShow=input$Explore_whichShowH, 
                      Explore_length=as.numeric(input$Explore_lengthH),
                      Append=input$ExploreAppendH)  
            },
            "Design"={
              l<-list(Explore_type=input$Explore_typeD,
                      Explore_show=input$Explore_showD, 
                      Explore_typeShow=input$Explore_typeShowD, 
                      Explore_whichShow=input$Explore_whichShowD, 
                      Explore_length=as.numeric(input$Explore_lengthD),
                      Append=input$ExploreAppendD)  
            },
            "MetaAnalysis"={
              l<-list(Explore_type=input$Explore_typeM,
                      Explore_show=input$Explore_showM, 
                      Explore_typeShow=explore$Explore_typeShow, 
                      Explore_whichShow=explore$Explore_whichShow, 
                      Explore_length=as.numeric(input$Explore_lengthM),
                      Append=input$ExploreAppendM)  
            }
    )
    explore<-c(l,list(Explore_npoints=input$Explore_npoints,Explore_xlog = input$Explore_xlog,
                      Explore_quants=input$Explore_quants,
                      Explore_esRange=input$Explore_esRange,Explore_nRange=input$Explore_nRange,
                      Explore_metaRange=input$Explore_metaRange,Explore_Mxlog = input$Explore_Mxlog,Explore_nrRange=input$Explore_nRange,
                      ExploreFull_ylim=input$ExploreFull_ylim,
                      ExploreTheory=input$evidenceTheory,ExploreLongHand=input$evidenceLongHand,
                      Explore_family=input$ExploreTab)
    )
    
    if (is.element(explore$Explore_type,c("IV","IV2","DV"))) {
      explore$Explore_type<-paste(explore$Explore_type,input$Explore_VtypeH,sep="")
    }
  }
  if (!input$evidenceLongHand) {
    explore$Explore_length<-explore$Explore_length*10
  }
  lastExplore<<-explore
  explore
} 

# Main calculations    
doExploreAnalysis <- function(IV,IV2,DV,effect,design,evidence,metaAnalysis,explore,result,nsim=1,doingNull=FALSE) {
  if (debug) {print("     doExploreAnalysis - start")}
  if (is.null(result$rIVs) || nrow(result$rIVs)<exploreResult$nsims) {
    if (nsim==exploreResult$nsims) {showProgress<-FALSE} else {showProgress<-TRUE}
    result$nsims<-exploreResult$nsims
    result<-exploreSimulate(IV,IV2,DV,effect,design,evidence,metaAnalysis,explore,result,nsim,doingNull,showProgress)
  }
  result
}


# Explore outputs
# show explore analysis        
makeExploreGraph <- function() {
  doit<-c(input$Explore_showH,input$Explore_showD,input$Explore_showM,
          input$LGExplore_showH,input$LGExplore_showD,input$LGExplore_showM,
          input$STMethod,input$alpha,input$STPrior)
  
  if (!is.null(exploreResult$Explore_family) && exploreResult$Explore_family!=input$ExploreTab) {
    if (is.null(exploreResultHold[[input$ExploreTab]])) {
      return(ggplot()+plotBlankTheme)
    }
    exploreResult<<-exploreResultHold[[input$ExploreTab]]
  }
  
  if (exploreResult$result$count<2) {
    silentTime<<-0
    pauseWait<<-10
  }
  if (exploreResult$result$count==2) {
    silentTime<<-Sys.time()-time2
  }
  if (exploreResult$result$count>2 && exploreResult$result$count<=cycles2observe) {
    silentTime<<-rbind(silentTime,Sys.time()-time2)
  }
  if (exploreResult$result$count>cycles2observe) {
    pauseWait<<-500
  }
  
  IV<-updateIV()
  IV2<-updateIV2()
  DV<-updateDV()
  
  if (!validExplore || is.null(IV) || is.null(DV)) {return(ggplot()+plotBlankTheme)}
  
  effect<-updateEffect()
  design<-updateDesign()
  evidence<-updateEvidence()
  if (switches$doMetaAnalysis) {
    metaAnalysis<-updateMetaAnalysis()
  }
  
  # this guarantees that we update without recalculating if possible
  explore<-updateExplore()
  
  stopRunning<-TRUE
  # expectedResult$result$showType<<-input$EvidenceEffect_type
  
  if (switches$showAnimation) {
    if (explore$Explore_family!="MetaAnalysis" && !explore$ExploreLongHand) {
      ns<-10^(min(3,floor(log10(max(100,exploreResult$result$count)))))
    } else {
      # ns<-10^(min(2,floor(log10(max(1,exploreResult$result$count)))))
      ns<-10^(min(2,floor(log10(max(exploreResult$nsims/10,exploreResult$result$count)))))
    }
  } else {
    ns<-exploreResult$nsims-exploreResult$result$count
  }
  # if (explore$Explore_family!="MetaAnalysis" && !explore$ExploreLongHand) {
  #   ns<-ns*100
  # }
  if (exploreResult$result$count+ns>exploreResult$nsims){
    ns<-exploreResult$nsims-exploreResult$result$count
  }
  if (ns>0) {
    showNotification(paste0("Explore ",explore$Explore_family," : starting"),id="counting",duration=Inf,closeButton=FALSE,type="message")
    exploreResult$result<<-doExploreAnalysis(IV,IV2,DV,effect,design,evidence,metaAnalysis,explore,exploreResult$result,ns,doingNull=FALSE)
    exploreResult$result$count<<-nrow(exploreResult$result$rIVs)
  }
  if (exploreResult$result$count<exploreResult$nsims) {
    stopRunning<-FALSE
  }
  
  if (!effect$world$worldOn  && (explore$Explore_show=="NHSTErrors" || explore$Explore_show=="FDR")) {
    if (switches$showAnimation) {
      ns<-10^(min(2,floor(log10(max(1,exploreResult$nullresult$count)))))
      if (exploreResult$nullresult$count+ns>exploreResult$nsims){
        ns<-exploreResult$nsims-exploreResult$nullresult$count
      }
    } else {
      ns<-exploreResult$nsims-exploreResult$nullresult$count
    }
    if (ns>0) {
      showNotification(paste0("Explore(null) ",explore$Explore_family," : starting"),id="counting",duration=Inf,closeButton=FALSE,type="message")
      exploreResult$nullresult<<-doExploreAnalysis(IV,IV2,DV,updateEffect(NULL),design,evidence,metaAnalysis,explore,exploreResult$nullresult,ns,doingNull=TRUE)
      exploreResult$nullresult$count<<-nrow(exploreResult$nullresult$rIVs)
    }
    if (exploreResult$nullresult$count<exploreResult$nsims) {
      stopRunning<-FALSE
    }
  } else{
    exploreResult$nullresult<<-NULL
  }
  exploreResult$Explore_type<<-explore$Explore_type
  exploreResult$Explore_show<<-explore$Explore_show
  exploreResult$Explore_typeShow<<-explore$Explore_typeShow
  exploreResult$Explore_family<<-explore$Explore_family
  exploreResult$evidence<<-evidence
  
  switch (explore$Explore_family,
          "Hypothesis"={exploreResultHold$Hypothesis<<-exploreResult},
          "Design"={exploreResultHold$Design<<-exploreResult},
          "MetaAnalysis"={exploreResultHold$MetaAnalysis<<-exploreResult}
  )
  
  
  g<-ggplot()+plotBlankTheme+theme(plot.margin=margin(0,-0.2,0,0,"cm"))
  g<-g+scale_x_continuous(limits = c(0,10),labels=NULL,breaks=NULL)+scale_y_continuous(limits = c(0,10),labels=NULL,breaks=NULL)
  g1<-drawExplore(IV,IV2,DV,effect,design,explore,exploreResult)
  
  g<-g+annotation_custom(grob=ggplotGrob(g1+gridTheme),xmin=0.5,xmax=9.5,ymin=0.5,ymax=9.5)
  
  time2<<-Sys.time()
  if (!stopRunning) {
    if (doStop) {
      invalidateLater(mean(as.numeric(silentTime)*1000)+pauseWait)
    } else {
      invalidateLater(1)
    }
  } else {
    updateActionButton(session,"exploreRunH",label="Run")
    updateActionButton(session,"exploreRunD",label="Run")
    updateActionButton(session,"exploreRunM",label="Run")
    updateActionButton(session,"LGexploreRunH",label="Run")
    updateActionButton(session,"LGexploreRunD",label="Run")
    updateActionButton(session,"LGexploreRunM",label="Run")
    notRunningExplore<<-TRUE
  }
  
  return(g)
}

output$ExplorePlot <- renderPlot( {
  doIt<-c(input$exploreRunH,input$exploreRunD,input$exploreRunM)
  makeExploreGraph()
})


# report explore analysis        
output$ExploreReport <- renderPlot({
  doIt<-c(input$exploreRunH,input$exploreRunD,input$exploreRunM,
          input$STMethod,input$alpha)
  
  if (!is.null(exploreResult$Explore_family) && exploreResult$Explore_family!=input$ExploreTab) {
    if (is.null(exploreResultHold[[input$ExploreTab]])) {
      return(ggplot()+plotBlankTheme)
    }
    exploreResult<<-exploreResultHold[[input$ExploreTab]]
  }
  
  if (exploreResult$result$count<exploreResult$nsims) {
    if (doStop) {
      invalidateLater(as.numeric(mean(silentTime)*1000)+pauseWait)
    } else {
      invalidateLater(1)
    }
  } 
  
  IV<-updateIV()
  IV2<-updateIV2()
  DV<-updateDV()
  
  effect<-updateEffect()
  design<-updateDesign()
  evidence<-updateEvidence()
  
  explore<-updateExplore()
  validExplore<-FALSE
  if (!validExplore || is.null(IV) || is.null(DV)) {return(ggplot()+plotBlankTheme)}
  
  reportExplore(IV,IV2,DV,effect,design,explore,exploreResult)
})

##################################################################################    
