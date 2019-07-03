#web scraping using Open API in r

library(XML)
library(data.table)
library(stringr)
library(ggplot2)

api_url = "http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcAptTrade?serviceKey="
service_key = "***********************"

locCode <-c("11110","11140","11170","11200","11215","11230","11260","11290","11305","11320","11350","11380","11410","11440","11470","11500","11530","11545","11560","11590","11620","11650","11680","11710","11740")
locCode_nm <-c("���α�","�߱�","��걸","������","������","���빮��","�߶���","���ϱ�","���ϱ�","������","�����","����","���빮��","������","��õ��","������","���α�","��õ��","��������","���۱�","���Ǳ�","���ʱ�","������","���ı�","������")
datelist <-c("201801","201802","201803","201804","201805","201806","201807","201808","201809","201810","201811","201812")

urllist <- list()
cnt <-0
for(i in 1:length(locCode)){
  for(j in 1:length(datelist)){
    cnt=cnt+1
    urllist[cnt] <-paste0(api_url,service_key, "&LAWD_CD=", locCode[i],"&DEAL_YMD=",datelist[j]) 
  }
} # ������ �ŷ������ �ٲ㰡�鼭 url�� urllist ����Ʈ�� ����

total<-list()
for(i in 1:length(urllist)){
  item <- list()
  item_temp_dt<-data.table()
  
  #xml ���� �ҷ�����
  raw.data <- xmlTreeParse(urllist[i], useInternalNodes = TRUE,encoding = "utf-8")
  rootNode <- xmlRoot(raw.data)  
  
  #�� ��° ������Ʈ�� 'items' ������Ʈ�� ������ items�� ����
  items <- rootNode[[2]][['items']]
  
  
  size <- xmlSize(items)
  
  for(i in 1:size){
    item_temp <- xmlSApply(items[[i]],xmlValue) #xml ��� ������Ʈ�� ���� ������ ���鼭 �ش� ������Ʈ�� ������ �ִ� ���� ����
    item_temp_dt <- data.table(price=item_temp[1],
                               con_year=item_temp[2],
                               year=item_temp[3],
                               dong=item_temp[4],
                               aptname=item_temp[5],
                               month=item_temp[6],
                               date=item_temp[7],
                               area=item_temp[8],
                               bungi=item_temp[9],
                               loccode=item_temp[10],
                               floor=item_temp[11])
    item[[i]]<-item_temp_dt #�ϳ��� url�� ���� ������ ����
  }
  total[[i]]<-rbindlist(item) #��ü url�� ���� ������ 
}

result_apt_data = rbindlist(total)

#���� �ڵ忡 ���� �´� ������ �� �߰�
lapply(locCode,function(x){result_apt_data[loc==x,gu:=locCode_nm[which(locCode==x)]]})





