no_se_multiple<-TRUE
multiOverlap<-FALSE
valsGap<-1.4

all_cols<-c()

drawExplore<-function(IV,IV2,DV,effect,design,explore,exploreResult){
  rho<-effect$rIV
  
  vals<-exploreResult$result$vals
  if (is.character(vals[1])){
    vals<-((1:length(vals))-1)/(length(vals)-1)
    doLine=FALSE
  } else {doLine=TRUE}
  
  g<-ggplot()
  ybreaks=c()
  ylabels=c()
  switch (explore$Explore_show,
          "EffectSize"={
            ylim<-c(-1,1)
            g<-g+scale_y_continuous(limits=ylim)
            ylabel<-bquote(r[sample])
          },
          "p"={
            ylim<-c(-4,0)
            ylabel<-bquote(log[10](p))
            ybreaks<-c(-4,-3,-2,-1,0)
            ylabels<-c(0.0001,0.001,0.01,0.1,1)
            g<-g+scale_y_continuous(limits=ylim,breaks=ybreaks,labels=ylabels)
          },
          "w"={
            if (wPlotScale=="log10"){
              ylim<-c(-2,0)
              ylabel<-bquote(log[10](w[est]))
              ybreaks=c(-2,-1,0)
              ylabels=c(0.01,0.1,1)
              g<-g+scale_y_continuous(limits=ylim,breaks=ybreaks,labels=ylabels)
            } else {
              ylim<-c(0,1)
              ylabel<-bquote(w[est])
              g<-g+scale_y_continuous(limits=ylim)
            }
          },
          "p(sig)"={
            # ylim<-c(0,1)
            ylabel<-"p(sig)"
            # g<-g+scale_y_continuous(limits=ylim)
          },
          "NHSTErrors"={
            ylim<-c(0,1)
            ylabel<-"Type I"
            g<-g+scale_y_continuous(limits=ylim,sec.axis=sec_axis(~ 1-.,name="Type II"))
            g<-g+theme(axis.title.y.left = element_text(color="darkgreen"),axis.title.y.right = element_text(color="darkred"))
          },
          "p(samp)"={
            ylabel<-paste0("p(r_s=",format(0.123,digits=3),")")
          },
          "FDR"={
            ylim<-c(0,1)
            ylabel<-"False Discovery"
            g<-g+scale_y_continuous(limits=ylim,sec.axis=sec_axis(~ 1-.,name="Misses"))
            g<-g+theme(axis.title.y.left = element_text(color="darkgreen"),axis.title.y.right = element_text(color="darkred"))
          },
          "log(lrs)"={
            ylim<-c(-0.1,10)
            ylabel<-bquote(log[e](lr[s]))
            g<-g+scale_y_continuous(limits=ylim)
          },
          "log(lrd)"={
            ylim<-c(-10,10)
            ylabel<-bquote(log[e](lr[d]))
            g<-g+scale_y_continuous(limits=ylim)
          },
          "k"={
            ylim<-c(-0.01,1.01)
            ylabel<-"k"
            g<-g+scale_y_continuous(limits=ylim)
          },
          "pNull"={
            ylim<-c(-0.01,1.01)
            ylabel<-"pNull"
            g<-g+scale_y_continuous(limits=ylim)
          },
          "PDF"={
            ylim<-c(0,1)
            ylabel<-"PDF"
            g<-g+scale_y_continuous(limits=ylim)
          },
          "S"={
            ylim<-c(min(exploreResult$result$Ss),max(exploreResult$result$Ss))
            ylabel<-"S"
            g<-g+scale_y_continuous(limits=ylim)
          },
          "mean(IV)"={
            ylabel<-"mean(IV)"
            ylim<-c(-1,1)
            },
          "sd(IV)"={ylabel<-"sd(IV)"},
          "skew(IV)"={ylabel<-"skew(IV)"},
          "kurtosis(IV)"={ylabel<-"kurtosis(IV)"},
          "mean(DV)"={ylabel<-"mean(DV)"},
          "sd(DV)"={ylabel<-"sd(DV)"},
          "skew(DV)"={ylabel<-"skew(DV)"},
          "kurtosis(DV)"={ylabel<-"kurtosis(DV)"}
  )

  if (!is.null(IV2) && is.element(explore$Explore_show,c("EffectSize","p","w","p(sig)"))) {
    switch (explore$Explore_show,
            "EffectSize"={use_cols<<-c(hsv(0.1,1,1),hsv(0.1+0.075,1,1),hsv(0.1+0.15,1,1))},
            "p"=         {use_cols<-c(hsv(0,1,1),hsv(0+0.075,1,1),hsv(0+0.15,1,1))},
            "w"=         {use_cols<-c(hsv(0.65,1,1),hsv(0.65+0.075,1,1),hsv(0.65+0.15,1,1))},
            "p(sig)"=    {use_cols<-c("#FFFFFF","#DDDDDD","#AAAAAA")},
    )
    names(use_cols)<-c("direct","unique","total")
    all_cols<<-use_cols
    g<-g+scale_fill_manual(name=explore$Explore_whichShow,values=all_cols)
    use_col_names<-TRUE
  } else {
    all_cols<-c()
    use_col_names<-FALSE
  }
  
  markersize<-7
  ni_max1<-1
  ni_max2<-1
  multi="none"
  if (explore$Explore_typeShow=="all") { # all of direct/unique/total
    markersize<-4
    ni_max1<-3
    multi<-"allTypes"
  } 
  if (explore$Explore_whichShow=="All") { # all of main1 main2 interaction
    markersize<-4
    ni_max2<-3
    multi<-"allEffects"
  } else {
    if (explore$Explore_whichShow=="Mains") { 
      markersize<-6
      ni_max2<-2
      multi<-"mainEffects"
    }
  }
  
  for (ni1 in 1:ni_max1){
    for (ni2 in 1:ni_max2){
      if (ni_max1>1) {
      switch (ni1,
            {explore$Explore_typeShow<-"direct"},
            {explore$Explore_typeShow<-"unique"},
            {explore$Explore_typeShow<-"total"})
      } 
      if (ni_max2>1) {
      switch (ni2,
              {explore$Explore_whichShow<-"Main 1"},
              {explore$Explore_whichShow<-"Main 2"},
              {explore$Explore_whichShow<-"Interaction"})
      }

    extra_y_label<-""
    if (is.null(IV2)){
      rVals<-exploreResult$result$rIVs
      pVals<-exploreResult$result$pIVs
    } else {
      switch (explore$Explore_whichShow,
              "Main 1"={
                rVals<-exploreResult$result$r1[[explore$Explore_typeShow]]
                pVals<-exploreResult$result$p1[[explore$Explore_typeShow]]
                extra_y_label<-paste("Main Effect 1:",explore$Explore_typeShow)
              },
              "Main 2"={
                rVals<-exploreResult$result$r2[[explore$Explore_typeShow]]
                pVals<-exploreResult$result$p2[[explore$Explore_typeShow]]
                extra_y_label<-paste("Main Effect 2:",explore$Explore_typeShow)
              },
              "Interaction"={
                rVals<-exploreResult$result$r3[[explore$Explore_typeShow]]
                pVals<-exploreResult$result$p3[[explore$Explore_typeShow]]
                extra_y_label<-paste("Interaction:",explore$Explore_typeShow)
              }
      )
    }
    nVals<-exploreResult$result$nvals
    
    extra_x_label<-""
    switch (explore$Explore_show,
            "EffectSize"={
              showVals<-rVals
              if (is.null(IV2)){
                col<-"yellow"
                colFill<-col
                lines<-c(0,effect$rIV)
              } else {
                switch (explore$Explore_whichShow,
                        "Main 1"={
                          lines<-c(0,effect$rIV)
                        },
                        "Main 2"={
                          lines<-c(0,effect$rIV2)
                        },
                        "Interaction"={
                          lines<-c(0,effect$rIVIV2DV)
                        }
                )
                col<-all_cols[[explore$Explore_typeShow]]
                colFill<-names(all_cols[explore$Explore_typeShow])
              }
            },
            "p"={
              showVals<-pVals
              lines<-c(0.05)
              if (pPlotScale=="log10"){
                showVals<-log10(showVals)
                lines<-log10(lines)
              }
              if (is.null(IV2)){
                col<-"red"
                colFill<-col
              } else {
                col<-all_cols[[explore$Explore_typeShow]]
                colFill<-names(all_cols[explore$Explore_typeShow])
              }
            },
            "w"={
              showVals<-rn2w(rVals,exploreResult$result$nvals)
              lines<-c(0.05,0.8)
              if (wPlotScale=="log10"){
                showVals<-log10(showVals)
                lines<-log10(lines)
              }
              if (is.null(IV2)){
                col<-"blue"
                colFill<-col
              } else {
                col<-all_cols[[explore$Explore_typeShow]]
                colFill<-names(all_cols[explore$Explore_typeShow])
              }
            },
            "p(sig)"={
              y50<-c()
              y25<-c()
              y75<-c()
              y62<-c()
              y38<-c()
              for (i in 1:length(exploreResult$result$vals)){
                if (explore$Explore_type=="Alpha") {
                  alpha<<-exploreResult$result$vals[i]
                  alphaLLR<<-0.5*qnorm(1-alpha/2)^2
                }
                p<-mean(isSignificant(STMethod,pVals[,i],rVals[,i],nVals[,i],exploreResult$evidence),na.rm=TRUE)
                p_se<-sqrt(p*(1-p)/length(pVals[,i]))
                y50[i]<-p
                y75[i]<-p+p_se*qnorm(0.75)
                y25[i]<-p+p_se*qnorm(0.25)
                y62[i]<-p+p_se*qnorm(0.625)
                y38[i]<-p+p_se*qnorm(0.375)
              }
              lines<-c(0.05,0.8)
              if (is.null(IV2)){
                col<-"white"
                colFill<-col
              } else {
                col<-all_cols[[explore$Explore_typeShow]]
                colFill<-names(all_cols[explore$Explore_typeShow])
              }
            },
            "NHSTErrors"={
              y50<-c()
              y25<-c()
              y75<-c()
              y50e<-c()
              y25e<-c()
              y75e<-c()
              if (effect$world$worldOn) {
                for (i in 1:length(exploreResult$result$vals)){
                  if (explore$Explore_type=="Alpha") {
                    alpha<<-exploreResult$result$vals[i]
                    alphaLLR<<-0.5*qnorm(1-alpha/2)^2
                  }
                  sigs<-isSignificant(STMethod,pVals[,i],rVals[,i],nVals[,i],exploreResult$evidence)
                  nulls<-exploreResult$result$rpIVs[,i]==0
                  p<-sum(!sigs & !nulls,na.rm=TRUE)/length(sigs) 
                  # NB because we plot this upside down 
                  y50[i]<-p
                  y75[i]<-p+sqrt(p*(1-p)/length(pVals[,i]))
                  y25[i]<-p-sqrt(p*(1-p)/length(pVals[,i]))
                  p<-sum(sigs[nulls],na.rm=TRUE)/length(sigs)
                  y50e[i]<-p
                  y75e[i]<-p+sqrt(p*(1-p)/length(pVals[,i]))
                  y25e[i]<-p-sqrt(p*(1-p)/length(pVals[,i]))
                }
              } else {
                for (i in 1:length(exploreResult$result$vals)){
                  if (explore$Explore_type=="Alpha") {
                    alpha<<-exploreResult$result$vals[i]
                    alphaLLR<<-0.5*qnorm(1-alpha/2)^2
                  }
                  p<-mean(!isSignificant(STMethod,pVals[,i],rVals[,i],nVals[,i],exploreResult$evidence),na.rm=TRUE)
                  y50[i]<-p
                  y75[i]<-p+sqrt(p*(1-p)/length(pVals[,i]))
                  y25[i]<-p-sqrt(p*(1-p)/length(pVals[,i]))
                }
                
                peVals<-exploreResult$nullresult$pIVs
                reVals<-exploreResult$nullresult$rIVs
                neVals<-exploreResult$nullresult$nvals
                for (i in 1:length(exploreResult$result$vals)){
                  if (explore$Explore_type=="Alpha") {
                    alpha<<-exploreResult$result$vals[i]
                    alphaLLR<<-0.5*qnorm(1-alpha/2)^2
                  }
                  p<-mean(isSignificant(STMethod,peVals[,i],reVals[,i],neVals[,i],exploreResult$evidence),na.rm=TRUE)
                  y50e[i]<-p
                  y75e[i]<-p+sqrt(p*(1-p)/length(peVals[,i]))
                  y25e[i]<-p-sqrt(p*(1-p)/length(peVals[,i]))
                }
              }
              col<-"red"
              cole<-"green"
              colFill<-col
              lines<-c(0.05)
            },
            "FDR"={
              y50<-c()
              y25<-c()
              y75<-c()
              y50e<-c()
              y25e<-c()
              y75e<-c()
              if (effect$world$worldOn) {
                for (i in 1:length(exploreResult$result$vals)){
                  if (explore$Explore_type=="Alpha") {
                    alpha<<-exploreResult$result$vals[i]
                    alphaLLR<<-0.5*qnorm(1-alpha/2)^2
                  }
                  sigs<-isSignificant(STMethod,pVals[,i],rVals[,i],nVals[,i],exploreResult$evidence)
                  nulls<-exploreResult$result$rpIVs[,i]==0
                  p<-sum(!sigs & !nulls,na.rm=TRUE)/sum(!nulls)
                  y50[i]<-p
                  y75[i]<-p+sqrt(p*(1-p)/length(pVals[,i]))
                  y25[i]<-p-sqrt(p*(1-p)/length(pVals[,i]))
                  p<-sum(sigs & nulls,na.rm=TRUE)/sum(sigs)
                  y50e[i]<-p
                  y75e[i]<-p+sqrt(p*(1-p)/length(pVals[,i]))
                  y25e[i]<-p-sqrt(p*(1-p)/length(pVals[,i]))
                }
              } else {
                for (i in 1:length(exploreResult$result$vals)){
                  if (explore$Explore_type=="Alpha") {
                    alpha<<-exploreResult$result$vals[i]
                    alphaLLR<<-0.5*qnorm(1-alpha/2)^2
                  }
                  p<-mean(isSignificant(STMethod,pVals[,i],rVals[,i],nVals[,i],exploreResult$evidence),na.rm=TRUE)
                  y50[i]<-p
                  y75[i]<-p+sqrt(p*(1-p)/length(pVals[,i]))
                  y25[i]<-p-sqrt(p*(1-p)/length(pVals[,i]))
                }
                
                peVals<-exploreResult$nullresult$pIVs
                reVals<-exploreResult$nullresult$rIVs
                neVals<-exploreResult$nullresult$nvals
                for (i in 1:length(exploreResult$result$vals)){
                  if (explore$Explore_type=="Alpha") {
                    alpha<<-exploreResult$result$vals[i]
                    alphaLLR<<-0.5*qnorm(1-alpha/2)^2
                  }
                  p<-mean(isSignificant(STMethod,peVals[,i],reVals[,i],neVals[,i],exploreResult$evidence),na.rm=TRUE)
                  y50e[i]<-p
                  y75e[i]<-p+sqrt(p*(1-p)/length(peVals[,i]))
                  y25e[i]<-p-sqrt(p*(1-p)/length(peVals[,i]))
                }
              }
              col<-"#FF8600"
              cole<-"#33FF99"
              colFill<-col
              lines<-c(0.05)
            },            "log(lrs)"={
              ns<-exploreResult$result$nvals
              showVals<-r2llr(rVals,ns,"sLLR",exploreResult$evidence$llr,exploreResult$evidence$prior)
              
              if (is.null(IV2)){
                col<-"yellow"
                colFill<-col
                lines<-c(0,effect$rIV)
              } else {
                switch (explore$Explore_whichShow,
                        "Main 1"={
                          lines<-c(0,effect$rIV)
                        },
                        "Main 2"={
                          lines<-c(0,effect$rIV2)
                        },
                        "Interaction"={
                          lines<-c(0,effect$rIVIV2DV)
                        }
                )
                col<-all_cols[[explore$Explore_typeShow]]
                colFill<-names(all_cols[explore$Explore_typeShow])
              }
            },
            "log(lrd)"={
              ns<-exploreResult$result$nvals
              showVals<-r2llr(rVals,ns,"dLLR",exploreResult$evidence$llr,exploreResult$evidence$prior)
              
              if (is.null(IV2)){
                col<-"yellow"
                colFill<-col
                lines<-c(0,effect$rIV)
              } else {
                switch (explore$Explore_whichShow,
                        "Main 1"={
                          lines<-c(0,effect$rIV)
                        },
                        "Main 2"={
                          lines<-c(0,effect$rIV2)
                        },
                        "Interaction"={
                          lines<-c(0,effect$rIVIV2DV)
                        }
                )
                col<-all_cols[[explore$Explore_typeShow]]
                colFill<-names(all_cols[explore$Explore_typeShow])
              }
            },
            "p(llrs)"={
              y50<-c()
              y25<-c()
              y75<-c()
              y62<-c()
              y38<-c()
              ns<-exploreResult$result$nvals
              showVals<-r2llr(rVals,ns,"sLLR",exploreResult$evidence$llr,exploreResult$evidence$prior)
              for (i in 1:length(exploreResult$result$vals)){
                if (explore$Explore_type=="Alpha") {
                  alpha<<-exploreResult$result$vals[i]
                  alphaLLR<<-0.5*qnorm(1-alpha/2)^2
                }
                p<-mean(isSignificant(STMethod,pvals[,i],rvals[,i],nvals[,i],exploreResult$evidence),na.rm=TRUE)
                p_se<-sqrt(p*(1-p)/length(pVals[,i]))
                y50[i]<-p
                y75[i]<-p+p_se*qnorm(0.75)
                y25[i]<-p+p_se*qnorm(0.25)
                y62[i]<-p+p_se*qnorm(0.625)
                y38[i]<-p+p_se*qnorm(0.375)
              }
              lines<-c(0.05,0.8)
              if (is.null(IV2)){
                col<-"white"
                colFill<-col
              } else {
                col<-all_cols[[explore$Explore_typeShow]]
                colFill<-names(all_cols[explore$Explore_typeShow])
              }
            },
            "p(llrd)"={
              y50<-c()
              y25<-c()
              y75<-c()
              y62<-c()
              y38<-c()
              ns<-exploreResult$result$nvals
              showVals<-r2llr(rVals,ns,"dLLR",exploreResult$evidence$llr,exploreResult$evidence$prior)
              for (i in 1:length(exploreResult$result$vals)){
                if (explore$Explore_type=="Alpha") {
                  alpha<<-exploreResult$result$vals[i]
                  alphaLLR<<-0.5*qnorm(1-alpha/2)^2
                }
                p<-mean(isSignificant(STMethod,pvals[,i],rvals[,i],nvals[,i],exploreResult$evidence),na.rm=TRUE)
                p_se<-sqrt(p*(1-p)/length(pVals[,i]))
                y50[i]<-p
                y75[i]<-p+p_se*qnorm(0.75)
                y25[i]<-p+p_se*qnorm(0.25)
                y62[i]<-p+p_se*qnorm(0.625)
                y38[i]<-p+p_se*qnorm(0.375)
              }
              lines<-c(0.05,0.8)
              if (is.null(IV2)){
                col<-"white"
                colFill<-col
              } else {
                col<-all_cols[[explore$Explore_typeShow]]
                colFill<-names(all_cols[explore$Explore_typeShow])
              }
            },
            "k"={
              showVals<-exploreResult$result$ks
              lines<-c()
              col<-"white"
              colFill<-col
            },
            "pNull"={
              showVals<-exploreResult$result$pnulls
              lines<-c()
              col<-"white"
              colFill<-col
            },
            "PDF"={
              showVals<-exploreResult$result$dists
              y50<-c()
              y25<-c()
              y75<-c()
              y62<-c()
              y38<-c()
              for (i in 1:length(exploreResult$result$vals)){
                p<-mean(showVals[,i],na.rm=TRUE)
                p_se<-sqrt(p*(1-p)/length(showVals[,i]))
                y50[i]<-p
                y75[i]<-p+p_se*qnorm(0.75)
                y25[i]<-p+p_se*qnorm(0.25)
                y62[i]<-p+p_se*qnorm(0.625)
                y38[i]<-p+p_se*qnorm(0.375)
              }
              lines<-c()
              col<-"white"
              colFill<-col
            },
            "S"={
              showVals<-exploreResult$result$Ss
              lines<-c()
              col<-"white"
              colFill<-col
            },
            "mean(IV)"={
              showVals<-rVals
              col<-"yellow"
                colFill<-col
                lines<-c()
            }
    )
  
    if (is.element(explore$Explore_show,c("EffectSize","p","w","log(lrs)","log(lrd)","k","S","pNull","mean(IV)"))) {
      quants<-explore$Explore_quants/2
      y75<-c()
      y62<-c()
      y50<-c()
      y38<-c()
      y25<-c()
      for (i in 1:length(exploreResult$result$vals)) {
        y75[i]<-quantile(showVals[,i],0.50+quants,na.rm=TRUE)
        y62[i]<-quantile(showVals[,i],0.50+quants/2,na.rm=TRUE)
        y50[i]<-quantile(showVals[,i],0.50,na.rm=TRUE)
        y38[i]<-quantile(showVals[,i],0.50-quants/2,na.rm=TRUE)
        y25[i]<-quantile(showVals[,i],0.50-quants,na.rm=TRUE)
      }
    y75[y75>ylim[2]]<-ylim[2]
    y62[y62>ylim[2]]<-ylim[2]
    y38[y38>ylim[2]]<-ylim[2]
    y25[y25>ylim[2]]<-ylim[2]
    
    y75[y75<ylim[1]]<-ylim[1]
    y62[y62<ylim[1]]<-ylim[1]
    y38[y38<ylim[1]]<-ylim[1]
    y25[y25<ylim[1]]<-ylim[1]
    y50[y50<ylim[1]]<-NA
    }

    vals_offset<-0
    valsRange<-1
    if (vals[1]<0) valsRange<-2
    # if (multi=="allTypes") {
    #   vals_offset<-(ni1-1)*(valsRange*valsGap)
    # } 
    if (multi=="allEffects" || multi=="mainEffects") {
      vals_offset<-(ni2-1)*(valsRange*valsGap)
    }
    pts1<-data.frame(vals=vals+vals_offset,y50=y50,y25=y25,y75=y75)
    
    if (explore$Explore_show=="NHSTErrors" || explore$Explore_show=="FDR") {
      pts2<-data.frame(vals=vals+vals_offset,y50e=y50e,y25e=y25e,y75e=y75e)
      
      if (doLine) {
        # shaded fills
        areaVals<-c(vals[1],vals,vals[length(vals)])
        # type 2 errors
        areaData<-1-c(0,y50,0)
        ptsNHST<-data.frame(x=areaVals+vals_offset,y=areaData)
        g<-g+geom_polygon(data=ptsNHST,aes(x=x,y=y),fill=col,alpha=0.5)
        # type 1 errors
        areaData<-c(0,y50e,0)
        ptsNHST<-data.frame(x=areaVals+vals_offset,y=areaData)
        g<-g+geom_polygon(data=ptsNHST,aes(x=x,y=y),fill=cole,alpha=0.5)
        # lines & points        
        g<-g+geom_line(data=pts1,aes(x=vals,y=1-y50),color=col)
        g<-g+geom_line(data=pts2,aes(x=vals,y=y50e),color=cole)
        g<-g+geom_point(data=pts1,aes(x=vals,y=1-y50),shape=shapes$parameter, colour = "black", fill = col, size = 7)
        g<-g+geom_point(data=pts2,aes(x=vals,y=y50e),shape=shapes$parameter, colour = "black", fill = cole, size = 7)
      } else {
        # shaded fills
        outline<-c(-1,-1,1,1)*0.1
        areaVals<-rep(vals,each=4)+rep(outline,length(vals))
        ids<-rep(1:length(vals),each=4)
        areaData<-1-rep(c(0,1,1,0),length(vals))*rep(1-y50,each=4)
        ptsNHST<-data.frame(x=areaVals+vals_offset,y=areaData,ids=ids)
        g<-g+geom_polygon(data=ptsNHST,aes(x=x,y=y,group=ids),colour = "black",fill=col,alpha=0.5)
        areaData<-rep(c(0,1,1,0),length(vals))*rep(y50e,each=4)
        ptsNHST<-data.frame(x=areaVals+vals_offset,y=areaData,ids=ids)
        g<-g+geom_polygon(data=ptsNHST,aes(x=x,y=y,group=ids),colour = "black",fill=cole,alpha=0.5)
        # points        
        g<-g+geom_point(data=pts1,aes(x=vals,y=y50),shape=shapes$parameter, colour = "black", fill = col, size = 7)
        g<-g+geom_point(data=pts2,aes(x=vals,y=y50e),shape=shapes$parameter, colour = "black", fill = cole, size = 7)
      }
      if (explore$Explore_show=="NHSTErrors" && effect$world$worldOn) {
        g<-g+geom_hline(yintercept=effect$world$populationNullp,colour="white")
      }
    } else {
      if (doLine) {
        pts1f<-data.frame(x=c(vals,rev(vals))+vals_offset,y=c(y25,rev(y75)))
        pts2f<-data.frame(x=c(vals,rev(vals))+vals_offset,y=c(y38,rev(y62)))
        if (ni_max2==1 || !no_se_multiple) {
          g<-g+geom_polygon(data=pts1f,aes(x=x,y=y),fill=col,alpha=0.5)
          g<-g+geom_polygon(data=pts2f,aes(x=x,y=y),fill=col,alpha=0.45)
        }
        g<-g+geom_line(data=pts1,aes(x=vals,y=y50),color="black")
      } else{
        if (ni_max2==1 || !no_se_multiple){
          g<-g+geom_errorbar(data=pts1,aes(x=vals,ymin=y25,ymax=y75,width=0.7/length(vals)))
        }
      }
      if (use_col_names){
        pts1<-data.frame(x=vals+vals_offset,y=y50,fill=explore$Explore_typeShow)
        g<-g+geom_point(data=pts1,aes(x=x,y=y,fill=fill),shape=shapes$parameter, colour = "black", size = markersize)
      } else {
        g<-g+geom_point(data=pts1,aes(x=vals,y=y50),shape=shapes$parameter, colour = "black",fill=col, size = markersize)
      }
    }
    
    if (is.element(explore$Explore_show,c("EffectSize","Interaction")) && is.element(exploreResult$Explore_type,c("EffectSize","EffectSize1","EffectSize2","Interaction"))){
      pts3<-data.frame(x=c(-1,1),y=c(-1,1))
      g<-g+geom_line(data=pts3,aes(x=x,y=y),colour="yellow", linetype="dotted")
    }
    
    if (explore$Explore_show=="p(sig)" && exploreResult$Explore_type=="SampleSize" && effect$world$populationPDF=="Single"){
      w<-y50
      n<-exploreResult$result$vals
      minrw<-function(r,w,n){sum(abs(w-rn2w(r,n)),na.rm=TRUE)}
      r_est<-optimize(minrw,c(0,0.9),w=w,n=n)
      r_est<-r_est$minimum
      nvals<-seq(min(n),max(n),length.out=101)
      yvals<-rn2w(r_est,nvals)
      ptsn<-data.frame(x=nvals+vals_offset,y=yvals)
      g<-g+geom_line(data=ptsn,aes(x=x,y=y),color="white")
      
      minnw<-function(n,r,w){sum(abs(w-rn2w(r,n)),na.rm=TRUE)}
      n80<-optimize(minnw,c(10,explore$Explore_nRange),w=0.8,r=r_est)
      
      if (sum(n<n80$minimum)>=2 && sum(n>n80$minimum)>=2){
        label<-paste("n80 =",format(n80$minimum,digits=2))
        # label<-paste("n80 =",format(n80$minimum,digits=2),"  r_est =", format(r_est,digits=3))
      } else {
        if (sum(n<n80$minimum)<2) label<-paste("Unsafe result - decrease range")
        if (sum(n>n80$minimum)<2) label<-paste("Unsafe result - increase range")
        # label<-paste("Unsafe result","  r_est =", format(r_est,digits=3))
      }
      if (ni_max2>1){label<-paste(explore$Explore_typeShow,": ",label,sep="")}
      lpts<-data.frame(x=min(n)+vals_offset,y=0.8+(ni_max2-1)/10,label=label)
      g<-g+geom_label(data=lpts,aes(x = x, y = y, label = label), hjust=0, vjust=0, fill = "white",size=3.5)
    }
    if (explore$Explore_show=="p(sig)" && exploreResult$Explore_type=="EffectSize"){
      w<-y50
      r<-exploreResult$result$vals
      minrw<-function(r,w,n){sum(abs(w-rn2w(r,n)),na.rm=TRUE)}
      n_est<-optimize(minrw,c(0,100),w=w,r=r)
      n_est<-n_est$minimum
      rvals<-seq(min(r),max(r),length.out=101)
      yvals<-rn2w(rvals,n_est)
      ptsn<-data.frame(x=rvals+vals_offset,y=yvals)
      g<-g+geom_line(data=ptsn,aes(x=x,y=y),color="white")
      
      minnw<-function(n,r,w){sum(abs(w-rn2w(r,n)),na.rm=TRUE)}
      n80<-optimize(minnw,c(0,0.8),w=0.8,n=n_est)
      
      if (sum(r<n80$minimum)>=2 && sum(r>n80$minimum)>=2){
        label<-paste("n80 =",format(n80$minimum,digits=2))
        # label<-paste("n80 =",format(n80$minimum,digits=2),"  n_est =", format(n_est,digits=3))
      } else {
        if (sum(r<n80$minimum)<2) label<-paste("Unsafe result - decrease range")
        if (sum(r>n80$minimum)<2) label<-paste("Unsafe result - increase range")
        # label<-paste("Unsafe result","  r_est =", format(r_est,digits=3))
      }
      if (ni_max2>1){label<-paste(explore$Explore_typeShow,": ",label,sep="")}
      lpts<-data.frame(x=0+vals_offset,y=0.8+(ni-1)/10,label=label)
      g<-g+geom_label(data=lpts,aes(x = x, y = y, label = label), hjust=0, vjust=0, fill = "white",size=3.5)
    }
  }
  }

  if (multi=="allEffects" || multi=="mainEffects") {
    for (ni2 in 1:ni_max2) {
      switch (ni2,
              {explore$Explore_whichShow<-"Main 1"},
              {explore$Explore_whichShow<-"Main 2"},
              {explore$Explore_whichShow<-"Interaction"}
              )
      if (is.character(exploreResult$result$vals[1])) {
        vals_offset<-(ni2-1)*valsGap+0.5
      } else {
        vals_offset<-(ni2-1)*valsGap*2 
      }
      td<-data.frame(x=vals_offset,y=ylim[2]-diff(ylim)/6,label=explore$Explore_whichShow)
      g<-g+geom_label(data=td,aes(x=x, y=y, label=label,hjust=0.5))
    }
    if (is.character(exploreResult$result$vals[1])) {
      g<-g+geom_vline(aes(xintercept=valsGap*c(1,ni_max2-1)-0.5*(valsGap-1)))
    } else {
      g<-g+geom_vline(aes(xintercept=valsGap*c(1,ni_max2)))
    }
    if (min(vals)<0) {
      tk<-(-2:2)/2
      jk<-2*valsGap
    } else {
      tk<-(0:4)/4
      jk<-valsGap
    }
    if (is.character(exploreResult$result$vals[1])) {
      tk<-seq(0,1,length.out=length(vals))
      g<-g+scale_x_continuous(breaks=c(vals,vals+jk,vals+jk*2),labels=c(exploreResult$result$vals,exploreResult$result$vals,exploreResult$result$vals),limits=c(0,1+jk*2)+c(-1,1)*0.25) +
        theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))
    } else {
    g<-g+scale_x_continuous(breaks=c(tk,tk+jk,tk+jk*2),labels=c(tk,tk,tk),limits=c(tk[1],1+jk*2)+c(-1,1)*0.25)
    }
  } else {
    if (is.character(exploreResult$result$vals[1]))
    g<-g+scale_x_continuous(breaks=vals,labels=exploreResult$result$vals)
  }
  if ((exploreResult$Explore_type=="SampleSize") && (vals[2]-vals[1])!=(vals[3]-vals[2])) {
    g<-g+scale_x_log10(limits=c(min(vals)/2,max(vals)*2))
  }
  if ((exploreResult$Explore_type=="Alpha") && (vals[2]-vals[1])!=(vals[3]-vals[2])) {
    g<-g+scale_x_log10(limits=c(min(vals)/2,max(vals)*2))
  }
  if ((exploreResult$Explore_type=="NoStudies") && (vals[2]-vals[1])!=(vals[3]-vals[2])) {
    g<-g+scale_x_log10(limits=c(min(vals)/2,max(vals)*2))
  }
  
  if (explore$ExploreFull_ylim){
  g<-g+coord_cartesian(ylim = ylim*1.05)
  }
    g<-g+ylab(ylabel)
    switch (exploreResult$Explore_type,
            "EffectSize"={g<-g+xlab(bquote(r[population]))},
            "EffectSize1"={
              g<-g+xlab(bquote(MainEffect1:r[population]))
              # g<-g+annotate("text",x=Inf,y=-Inf, hjust=1, vjust=-1, angle=0, label="Main Effect 1",color="white")
            },
            "EffectSize2"={
              g<-g+xlab(bquote(MainEffect2:r[population]))
              # g<-g+annotate("text",x=Inf,y=-Inf, hjust=1, vjust=-1, angle=0, label="Main Effect 2",color="white")
            },
            "Covariation"={
              g<-g+xlab(bquote(covariation:r[population]))
              # g<-g+annotate("text",x=Inf,y=-Inf, hjust=1, vjust=-1, angle=0, label="Covariation",color="white")
            },
            "Interaction"={
              g<-g+xlab(bquote(interaction:r[population]))
              # g<-g+annotate("text",x=Inf,y=-Inf, hjust=1, vjust=-1, angle=0, label="Interaction",color="white")
            },
            g<-g+xlab(exploreResult$Explore_type)
    )
    
    if (explore$Explore_show=="p(sig)") {
      top<-max(y75,na.rm=TRUE)
      top<-ceil(top*10)/10
      ylim<-c(0,top)
      g<-g+scale_y_continuous(limits=ylim)
    }
    
  g+plotTheme
}

