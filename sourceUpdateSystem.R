################################################################        
# update basic functions
# set prediction, design, evidence variables from UI
#


# PREDICTION & DESIGN & EVIDENCE
updateEffect<-function(type=0){
  if (debug) print("     updateEffect")
  
  if (switches$doWorlds) {
    world<-list(worldOn=input$world_on,populationPDF=input$world_distr,
                populationPDFk=input$world_distr_k,populationRZ=input$world_distr_rz,
                populationNullp=input$world_distr_Nullp)
  } else {
    world<-list(worldOn=FALSE,populationPDF="Single",populationPDFk=NA,populationRZ=NA,populationNullp=NA)
  }
  if (is.null(world$worldOn)) {world$worldOn<-FALSE}
  
  if (is.null(type)) {
    effect<-list(rIV=0,rIV2=0,rIVIV2=0,rIVIV2DV=0,
                 Heteroscedasticity=input$Heteroscedasticity,Welch=input$Welch,ResidDistr=input$ResidDistr,
                 world=world
    )
  } else {
    effect<-list(rIV=input$rIV,rIV2=input$rIV2,rIVIV2=input$rIVIV2,rIVIV2DV=input$rIVIV2DV,
                 Heteroscedasticity=input$Heteroscedasticity,Welch=input$Welch,ResidDistr=input$ResidDistr,
                 world=world
    )
  }
  if (effect$world$worldOn==FALSE) {
    effect$world$populationPDF<-"Single"
    effect$world$populationRZ<-"r"
    effect$world$populationPDFk<-effect$rIV
    effect$world$populationNullp<-0
  }
  if (is.null(oldEffect)) {
    effect$Heteroscedasticity<-checkNumber(effect$Heteroscedasticity)
    effect$world$populationPDFk<-checkNumber(effect$world$populationPDFk)
    effect$world$populationNullp<-checkNumber(effect$world$populationNullp)
  } else {
    effect$Heteroscedasticity<-checkNumber(effect$Heteroscedasticity,oldEffect$Heteroscedasticity)
    effect$world$populationPDFk<-checkNumber(effect$world$populationPDFk,oldEffect$world$populationPDFk)
    effect$world$populationNullp<-checkNumber(effect$world$populationNullp,oldEffect$world$populationNullp)
  }
  oldEffect<<-effect
  
  if (debug) print("     updateEffect - exit")
  effect
}

updateDesign<-function(){
  if (debug) print("     updateDesign")
  design<-list(sN=input$sN, sNRand=input$sNRand,sNRandK=input$sNRandK,
               sMethod=input$sMethod ,sIV1Use=input$sIV1Use,sIV2Use=input$sIV2Use, 
               sRangeOn=input$sRangeOn, sIVRange=input$sIVRange, sDVRange=input$sDVRange, 
               sDependence=input$sDependence, sOutliers=input$sOutliers, sClustering=input$sClustering,
               sCheating=input$sCheating,sCheatingK=input$sCheatingK,
               sReplicationOn=input$sReplicationOn,sReplPower=input$sReplPower,
               sReplSigOnly=input$sReplSigOnly,sReplRepeats=input$sReplRepeats,sReplCorrection=input$sReplCorrection,
               sReplKeep=input$sReplKeep,sReplTails=input$sReplTails,
               sN_Strata=input$sN_Strata, sR_Strata=input$sR_Strata,
               sNClu_Cluster=input$sNClu_Cluster, sRClu_Cluster=input$sRClu_Cluster,
               sNClu_Convenience=input$sNClu_Convenience, sRClu_Convenience=input$sRClu_Convenience, sNCont_Convenience=input$sNCont_Convenience, sRCont_Convenience=input$sRCont_Convenience, sRSpread_Convenience=input$sRSpread_Convenience,
               sNClu_Snowball=input$sNClu_Snowball, sRClu_Snowball=input$sRClu_Snowball, sNCont_Snowball=input$sNCont_Snowball, sRCont_Snowball=input$sRCont_Snowball, sRSpread_Snowball=input$sRSpread_Snowball
  )
  if (is.null(oldDesign)) {
    design$sNRandK<-checkNumber(design$sNRandK)
    design$sReplPower<-checkNumber(design$sReplPower)
  } else {
    design$sNRandK<-checkNumber(design$sNRandK,oldDesign$sNRandK)
    design$sReplPower<-checkNumber(design$sReplPower,oldDesign$sReplPower)
  }
  oldDesign<<-design
  if (variablesHeld=="Data" && !applyingAnalysis && switches$doBootstrap) {design$sMethod<-"Resample"}
  if (debug) print("     updateDesign - exit")
  design
}

updateEvidence<-function(){
  if (debug) print("     updateEvidence")
  evidence<-list(rInteractionOn=input$rInteractionOn,
                 rInteractionOnly=input$rInteractionOnly,
                 showType=input$EvidenceEffect_type,
                 showTheory=input$evidenceTheory,
                 allScatter=input$allScatter,
                 longHand=input$evidenceLongHand,
                 ssqType=input$ssqType,
                 llr=list(e1=input$llr1,e2=input$llr2),
                 evidenceCaseOrder=input$evidenceCaseOrder,Welch=input$Welch,
                 dataType=input$dataType,analysisType=input$analysisType,
                 pScale=input$pScale,wScale=input$wScale,nScale=input$nScale,
                 usePrior=input$STPrior,
                 prior=list(worldOn=FALSE,populationPDF="",
                            populationPDFk=0,populationRZ="r",
                            populationNullp=0)
  )
  switch(input$STPrior,
         "none"={
           evidence$prior=list(worldOn=input$world_on,populationPDF="Uniform",
                               populationPDFk=0,populationRZ="z",
                               populationNullp=0.5)
         },
         "world"={
           evidence$prior=list(worldOn=input$world_on,populationPDF=input$world_distr,
                               populationPDFk=input$world_distr_k,populationRZ=input$world_distr_rz,
                               populationNullp=input$world_distr_Nullp)
         },
         "prior"={
           evidence$prior=list(worldOn=input$world_on,populationPDF=input$likelihoodPrior_distr,
                               populationPDFk=input$likelihoodPrior_distr_k,populationRZ=input$likelihoodPrior_distr_rz,
                               populationNullp=input$likelihoodPrior_Nullp)
         }
  )
  if (!switches$doWorlds) {
    evidence$prior$worldOn<-FALSE
  }
  
  if (debug) print("     updateEvidence - exit")
  evidence
}

##################################################################################  
