source("uiMetaAnalysis.R")


inferType<-list("Basic"=basicType,"Power"=powerType)
if (switches$doLikelihoodInfer) inferType<-c(inferType,list("Likelihood"=likeType))
if (switches$doWorlds) inferType<-c(inferType,list("World"=worldType))
if (switches$doReplications) inferType<-c(inferType,list("Replication"=replicationType))

singleType<-list("Basic" = "EffectSize","Power" = "Power")
if (switches$doLikelihoodInfer) singleType<-c(singleType,list("Likelihood"=likeType))

multipleType<-list("Basic" = "EffectSize","Power" = "Power","NHST errors" = "NHSTErrors","CI limits" = "CILimits")
if (switches$doLikelihoodInfer) multipleType<-c(multipleType,likeType)
multipleType<-c(multipleType,"2D"="2D")


EvidenceTab <-
  
  wellPanel(id="EvidenceMain",
            style = paste("background: ",panelcolours$simulateC), 
            fluidRow(headerText("Make a simulated sample; run multiple samples")),
            # h5("Evidence"),
            tabsetPanel(id="Evidence", type="tabs",
                        tabPanel("Evidence:",value="Evidence",
                        ),
                        # single tab
                        tabPanel("Single",value="Single",id="uiSingle",
                                 style = paste("background: ",subpanelcolours$simulateC), 
                                 wellPanel(id="Single",
                                           style = paste("background: ",subpanelcolours$simulateC,";"),
                                           tags$table(width = "100%",class="myTable",
                                                      tags$tr(
                                                        tags$td(width = "15%", tags$div(style = localStyle, "Show:")),
                                                        tags$td(width = "35%", 
                                                                selectInput("EvidenceInfer_type",label=NULL,
                                                                            singleType,
                                                                            selectize=FALSE)
                                                        ),
                                                        # tags$td(width = "10%", tags$div(style = localStyle, "")),
                                                        tags$td(width = "25%", actionButton("EvidenceHypothesisApply", "Analyze")),
                                                        tags$td(width = "25%", actionButton("EvidencenewSample", "New Sample"))
                                                      )
                                           )
                                 )
                        ),
                        # multiple tab
                        tabPanel("Multiple",value="Multiple",id="uiMultiple",
                                 style = paste("background: ",subpanelcolours$simulateC), 
                                 wellPanel(id="Multiple",
                                           style = paste("background: ",subpanelcolours$simulateC,";"),
                                           tags$table(width = "100%",class="myTable",
                                                      tags$tr(
                                                        tags$td(width = "10%", tags$div(style = localStyle, "Show:")),
                                                        tags$td(width = "40%", 
                                                                selectInput("EvidenceExpected_type",label=NULL,
                                                                            multipleType,
                                                                            selected="Basic",
                                                                            selectize=FALSE)
                                                        ),
                                                        tags$td(width = "25%",
                                                                # conditionalPanel(condition="input.EvidenceExpected_type=='2D'",
                                                                selectInput("EvidenceExpected_par1", label=NULL, 
                                                                            inferType,
                                                                            selected="r", selectize=FALSE)
                                                                # ),
                                                        ),
                                                        tags$td(width = "25%",
                                                                # conditionalPanel(condition="input.EvidenceExpected_type=='2D'",
                                                                selectInput("EvidenceExpected_par2", label=NULL, 
                                                                            inferType,
                                                                            selected="p", selectize=FALSE)
                                                                # ),
                                                        )
                                                      ),
                                                      tags$tr(
                                                        tags$td(width = "10%", tags$div(style = localStyle, "")),
                                                        tags$td(width = "40%", 
                                                                conditionalPanel(condition="input.IV2choice != 'none'",
                                                                                 selectInput("EvidenceEffect_type",label=NULL,
                                                                                             c("direct" = "direct",
                                                                                               "unique" = "unique",
                                                                                               "total" = "total",
                                                                                               "all" = "all",
                                                                                               "coefficients" = "coefficients"),
                                                                                             selectize=FALSE)
                                                                )
                                                        ),
                                                        tags$td(width = "25%", tags$div(style = localStyle, "")),
                                                        tags$td(width = "25%", tags$div(style = localStyle, ""))
                                                      )
                                           ),
                                           tags$table(width = "100%",class="myTable",
                                                      tags$tr(
                                                        tags$td(width = "10%", tags$div(style = localStyle, "Runs:")),
                                                        tags$td(width = "55%", 
                                                                selectInput("EvidenceExpected_length",label=NULL,
                                                                            c("10" = "10",
                                                                              "50" = "50",
                                                                              "100" = "100",
                                                                              "250" = "250",
                                                                              "500" = "500",
                                                                              "1000" = "1000"),
                                                                            selected = "10",
                                                                            selectize=FALSE)
                                                        ),
                                                        tags$td(width = "10%", tags$div(style = localStyle, "Append:")),
                                                        tags$td(width = "5%", checkboxInput("EvidenceExpected_append", label=NULL)),
                                                        tags$td(width = "20%",actionButton("EvidenceExpectedRun", "Run"))
                                                      )
                                           )
                                 )
                        )#,
                        # metaPanel()
                        # options tab
                        ,tabPanel("#",id="EvidenceOptions",
                                  style = paste("background: ",subpanelcolours$simulateC),
                                  wellPanel(
                                    style = paste("background: ",subpanelcolours$simulateC,";"),
                                    tags$table(width = "100%",class="myTable",
                                               tags$tr(
                                                 tags$td(width = "25%", tags$div(style = paste(localStyle,"text-align: left"), "Analysis")),
                                                 tags$td(width = "25%"),
                                                 tags$td(width = "25%", tags$div(style = localPlainStyle, " ")),
                                                 tags$td(width = "25%", 
                                                         # actionButton("LGEvidenceStart","i")
                                                 )
                                               )
                                    ),
                                    tags$table(width = "100%",class="myTable",
                                               tags$tr(
                                                 tags$td(width = "15%", tags$div(style = localPlainStyle, "Welch")),
                                                 tags$td(width = "25%", 
                                                         checkboxInput("Welch",label=NULL,value=evidence$Welch),
                                                 ),
                                                 tags$td(width = "25%", tags$div(style = localPlainStyle, " ")),
                                                 tags$td(width = "25%", tags$div(style = localPlainStyle, " ")),
                                               )
                                    ),
                                    tags$table(width = "100%",class="myTable",
                                               tags$tr(
                                                 tags$td(width="25%", 
                                                         selectInput("STMethod",label=NULL,
                                                                     choices=c("NHST","sLLR","dLLR"),
                                                                     selected="NHST",
                                                                     selectize=FALSE
                                                         )
                                                 ),
                                                 tags$td(width = "15%",tags$div(style = localPlainStyle, "alpha")),
                                                 tags$td(width = "15%",
                                                         numericInput("alpha",label=NULL,value=alpha,step=0.01)
                                                         ),
                                                 tags$td(width = "15%",id="evidencePrior",tags$div(style = localPlainStyle, "prior:")),
                                                 tags$td(width = "30%",
                                                         selectInput("STPrior",label=NULL,
                                                                     choices=c("none","world","prior"),
                                                                     selected="none",
                                                                     selectize=FALSE
                                                         )
                                                 ),
                                               ),
                                               tags$tr(
                                                 tags$td(width="25%"),
                                                 tags$td(width = "15%", id="evidenceLLR1",tags$div(style = localPlainStyle, "llr(0)")),
                                                 tags$td(width = "15%", 
                                                         numericInput("llr2",label=NULL,value=evidence$llr$e2,step = 0.1)),
                                                 tags$td(width = "15%", id="evidenceLLR2",tags$div(style = localPlainStyle, "llr(A)")),
                                                 tags$td(width = "15%", 
                                                         numericInput("llr1",label=NULL,value=evidence$llr$e1,step = 0.1)),
                                                 )
                                    ),
                                    conditionalPanel(condition="input.IV2choice != 'none'",
                                                     tags$table(width = "100%",class="myTable",
                                                                tags$tr(
                                                                  tags$td(width = "30%", tags$div(style = localPlainStyle, "Interaction:")),
                                                                  tags$td(width = "25%", tags$div(style = localPlainStyle, "analyse")),
                                                                  tags$td(width = "10%",checkboxInput("rInteractionOn",label=NULL,value=evidence$rInteractionOn)),
                                                                  tags$td(width = "25%", tags$div(style = localPlainStyle, "show only")),
                                                                  tags$td(width = "10%", checkboxInput("evidenceInteractionOnly", value=evidence$rInteractionOnly, label=NULL)),
                                                                ))),
                                    conditionalPanel(condition="input.IV2choice != 'none'",
                                                     tags$table(width = "100%",class="myTable",
                                                                tags$tr(
                                                                  tags$td(width = "30%", tags$div(style = localPlainStyle, "SSQ Type:")),
                                                                  tags$td(width = "25%", selectInput("ssqType", label=NULL, c("Type1"="Type1","Type2"="Type2","Type3"="Type3"), selected=evidence$ssqType, selectize=FALSE)),
                                                                  tags$td(width = "45%", tags$div(style = localPlainStyle, " ")),
                                                                ),
                                                                tags$tr(
                                                                  tags$td(width = "30%", tags$div(style = localPlainStyle, "Report:")),
                                                                  tags$td(width = "25%", selectInput("dataType", label=NULL, c("Raw"="Raw","Norm"="Norm","RawC"="RawC","NormC"="NormC"), selected=evidence$dataType, selectize=FALSE)),
                                                                  tags$td(width = "25%", selectInput("analysisType", label=NULL, c("Anova"="Anova","Model"="Model"), selected=evidence$analysisType, selectize=FALSE)),
                                                                  tags$td(width = "20%", tags$div(style = localPlainStyle, " ")),
                                                                ))),
                                    tags$table(width = "100%",class="myTable",
                                               tags$tr(
                                                 tags$td(width = "25%", tags$div(style = paste(localStyle,"text-align: left"), "Display")),
                                               ),
                                               tags$tr(
                                                 tags$td(width = "25%", tags$div(style = localPlainStyle, "case order:")),
                                                 tags$td(width = "25%", selectInput("evidenceCaseOrder", choices = c("Alphabetic"="Alphabetic","As Found"="AsFound","Frequency"="Frequency"),selected=evidence$evidenceCaseOrder, label=NULL, selectize=FALSE)),
                                                 tags$td(width = "25%", tags$div(style = localPlainStyle, "scatter plots:")),
                                                 tags$td(width = "25%", selectInput("allScatter", label=NULL, c("none"="none","all"="all","corr only"="corr"), selected=evidence$allScatter, selectize=FALSE)),
                                               )),
                                    tags$table(width = "100%",class="myTable",
                                               tags$tr(
                                                 tags$td(width = "25%", tags$div(style = localPlainStyle, "p-scale:")),
                                                 tags$td(width = "25%", selectInput("pScale", label=NULL, c("linear"="linear","log10"="log10"), selected=evidence$pScale, selectize=FALSE)),
                                                 tags$td(width = "25%", tags$div(style = localPlainStyle, "w-scale:")),
                                                 tags$td(width = "25%", selectInput("wScale", label=NULL, c("linear"="linear","log10"="log10"), selected=evidence$wScale, selectize=FALSE)),
                                               ),
                                               tags$tr(
                                                 tags$td(width = "25%", tags$div(style = localPlainStyle, "n-scale:")),
                                                 tags$td(width = "25%", selectInput("nScale", label=NULL, c("linear"="linear","log10"="log10"), selected=evidence$nScale, selectize=FALSE)),
                                                 tags$td(width = "25%", tags$div(style = localPlainStyle, "")),
                                                 tags$td(width = "25%", tags$div(style = localPlainStyle, ""))
                                               ),
                                    ),
                                    tags$table(width = "100%",class="myTable",
                                               tags$tr(
                                                 tags$td(width = "45%", tags$div(style = localPlainStyle, "long hand:")),
                                                 tags$td(width = "5%", checkboxInput("evidenceLongHand",label=NULL,value=evidence$longHand)),
                                                 tags$td(width = "45%", tags$div(style = localPlainStyle, "show theory:")),
                                                 tags$td(width = "5%", checkboxInput("evidenceTheory",label=NULL,value=evidence$showTheory)),
                                               )),
                                  )
                        )
                        # help tab
                        ,tabPanel(helpChar,value="?",
                                  style = paste("background: ",subpanelcolours$simulateC),
                                  wellPanel(
                                    style = paste("background: ",subpanelcolours$simulateC,";"),
                                    tags$table(width = "100%",class="myTable",
                                               tags$tr(
                                                 tags$div(style = helpStyle, 
                                                          tags$br(HTML('<b>'),"Single simulation:",HTML('</b>')),
                                                          tags$br(HTML('&emsp;'), '1. press "New Sample", nothing else required'),
                                                          tags$br(HTML('&emsp;'), '2. results are found in:'),
                                                          tags$br(HTML('&emsp;'),HTML('&emsp;'), 'Sample: raw data'),
                                                          tags$br(HTML('&emsp;'),HTML('&emsp;'), 'Description: effects'),
                                                          tags$br(HTML('&emsp;'),HTML('&emsp;'), 'Inference: null hypothesis tests'),
                                                          tags$br(HTML('&emsp;'), '3. choose to see:'),
                                                          tags$br(HTML('&emsp;'),HTML('&emsp;'), 'Basic: effect-size & p-value'),
                                                          tags$br(HTML('&emsp;'),HTML('&emsp;'), 'Power: post-hoc power & n80'),
                                                          tags$br(HTML('<b>'),"Multiple simulations: ",HTML('</b>')),
                                                          tags$br(HTML('&emsp;'), '1. choose desired output then press "Run"'),
                                                          tags$br(HTML('&emsp;'),HTML('&emsp;'), '(use the append option to add further simulations)'),
                                                          tags$br(HTML('&emsp;'), '2. results are found in:'),
                                                          tags$br(HTML('&emsp;'),HTML('&emsp;'), 'Expected:')
                                                 ),
                                               )
                                    )
                                  )
                        )
            )
  )
