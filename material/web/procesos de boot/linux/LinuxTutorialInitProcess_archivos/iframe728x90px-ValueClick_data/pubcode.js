(function(a,b){VCM=(function(){if(typeof VCM==="object"){return VCM}return{}}());VCM.media={version:1.2,render:function(j){var x,n=true,s="get.media",q=(j.secure!=undefined)?j.secure:"",B=VCM.media.dimensions(j.media_type),w=Math.random(),D=escape(VCM.media.topReferrer()),o=escape(VCM.media.trustedReferrer()),p=VCM.media.isFrame(),c=(p==1)?VCM.media.cookieReferrer():"",u=VCM.media.validVersion(j.version),r=VCM.media.matchVersion(j.version),C=(j.macro!=undefined)?VCM.media.macroList(j.macro):"",g=(j.target!=undefined)?j.target:"n",f=(j.walsh!=undefined)?("&walsh="+j.walsh):"",v=(j.media_id!=undefined)?("&m="+j.media_id):"",e="",d="";this.isSecure=(q=="off")?false:(q=="on")?true:(q=="auto")?this.isPageSecure():false;if(VCM.media.isPop(j)){if(j.pfc==undefined){j.pfc=14400000}s="pop.cgi";var A=new Date();b.cookie="h2=o; path=/;";w=A.getSeconds();if(b.cookie.indexOf("e=llo")<=0&&b.cookie.indexOf("2=o")>0){A.setTime(A.getTime()+j.pfc);b.cookie="he=llo; path=/; expires="+A.toGMTString()}else{n=false}}else{if(VCM.media.isInvue(j)){if(j.ivfc==undefined){j.ivfc=15}w=Math.floor(Math.random()*7777);b.cookie="h2=o; path=/;";var z=0;var t=0;if(a.innerWidth&&a.innerHeight){z=a.innerWidth;t=a.innerHeight}else{if(b.documentElement.clientWidth>0&&b.documentElement.clientHeight>0){z=b.documentElement.clientWidth;t=b.documentElement.clientHeight}else{z=b.body.clientWidth;t=b.body.clientHeight;if(t>1024){t=1024}}}if(b.cookie.indexOf("n=vue")<=0&&b.cookie.indexOf("2=o")>0&&b.cookie.indexOf("vccap=1")<=0){VCM.media.setCookie("vccap","1",j.ivfc,"/",null,null);d="&window_ht="+t+"&window_wt="+z}else{n=false}}else{if(VCM.media.isInterstitial(j)){n=false;if(j.isfc==undefined){j.isfc=15}if(j.isal!=undefined&&j.isal==1){b.write('<script language="javascript" src="'+this.cdnServer()+'/is.js"><\/script>')}else{var l=j.ishref;if(l.indexOf("get.media")>0){l=unescape(l.substring(l.indexOf("&url=")+5,l.length))}else{if(b.cookie.indexOf("CxIC=1")<=0){var k="&url="+escape(l);l=VCM.media.codeSrc(false,s,j.sid,v,j.media_type,g,j.version,w,p,-1,-1,u,r,C,f,e,D,o,c,d,k);var A=new Date();A.setTime(A.getTime()+j.isfc*1000*60);b.cookie="FCxIC=1; path=/; expires="+A.toGMTString()}}return l}return}else{if(VCM.media.isFlexBanner(j)){if(j.width!=undefined&&j.height!=undefined){e="&w="+j.width+"&h="+j.height}}}}}var h="vcmad_"+Math.floor(Math.random()*100000);x='<div id="'+h+'"></div>';b.write(x);var m=b.getElementById(h);var y={top:-1,left:-1};if(p==0&&m!=undefined){y=VCM.media.coords(m)}if(n){x=VCM.media.codeSrc(true,s,j.sid,v,j.media_type,g,j.version,w,p,y.left,y.top,u,r,C,f,e,D,o,c,d,"");b.write(unescape(x))}},topReferrer:function(){var d=window.location.href;var c=VCM.media.parsedURI(d);if(typeof d!=="undefined"){d=c.protocol+"://"+c.host+c.port+c.path}return d},trustedReferrer:function(){var d="";var c=window.location.search.substring(1);var e=c.split("&");for(i=0;i<e.length;i++){ft=e[i].split("=");if(ft[0]=="vcmref"){d=ft[1];break}}return d},cookieReferrer:function(){var g="tr=";var d=document.cookie.split(";");for(var e=0;e<d.length;e++){var h=d[e];while(h.charAt(0)==" "){h=h.substring(1,h.length)}if(h.indexOf(g)==0){document.cookie='tr="";expires=Thu, 01-Jan-70 00:00:01 GMT;path=/';var f=VCM.media.parsedURI(h.substring(g.length,h.length));if(typeof f!=="undefined"){return f.protocol+"://"+f.host+f.port+f.path}}}return""},isFrame:function(){var c=(window.location!=window.parent.location)?1:0;return c},isFlexBanner:function(c){return(c.media_type!=undefined&&c.media_id!=undefined&&c.media_type==12&&c.media_id==10)},isPop:function(c){return(c.media_type!=undefined&&c.media_id!=undefined&&c.media_type==2&&c.media_id==2)},isInvue:function(c){return(c.media_type!=undefined&&c.media_id!=undefined&&c.media_type==4&&c.media_id==4)},isInterstitial:function(c){return(c.media_type!=undefined&&c.media_id!=undefined&&c.media_type==6&&c.media_id==5)},dimensions:function(c){switch(c){case 1:return{w:468,h:60};case 2:return{w:720,h:400};case 3:return{w:120,h:600};case 4:return{w:250,h:250};case 5:return{w:728,h:90};case 6:return{w:728,h:600};case 7:return{w:160,h:600};case 8:return{w:300,h:250};case 9:return{w:180,h:150};case 10:return{w:300,h:600};case 11:return{w:0,h:0};case 12:return{w:200,h:200};case 13:return{w:320,h:240};default:return{w:0,h:0}}},coords:function(e){var d=0;var c=0;while(e&&!isNaN(e.offsetLeft)&&!isNaN(e.offsetTop)){d+=e.offsetLeft-e.scrollLeft;c+=e.offsetTop-e.scrollTop;e=e.offsetParent}return{top:c,left:d}},validVersion:function(c){return(c==1||c==1.1||c==1.2)},matchVersion:function(c){return(c==VCM.media.version)},macroList:function(e){var d="";for(var c=0;c<e.length;c++){if((e[c].name!=undefined)&&(e[c].name!="")){d=d+"&"+escape(e[c].name)+"="+escape(e[c].value)}}return d},setCookie:function(e,g,c,k,f,j){var d=new Date();d.setTime(d.getTime());if(c){c=c*1000*60}var h=new Date(d.getTime()+c);b.cookie=e+"="+escape(g)+((c)?";expires="+h.toGMTString():"")+((k)?";path="+k:"")+((f)?";domain="+f:"")+((j)?";secure":"")},codeSrc:function(B,d,h,n,f,k,o,y,r,w,p,u,s,A,q,m,x,c,j,g,e){var z=this.mediaServer()+"/w/"+d+"?sid="+h+n+"&tp="+f+"&d=j&t="+k+"&vcm_acv="+o+"&c="+y+"&vcm_ifr="+r+"&vcm_xy="+w+".."+p+"&vcm_vv="+u+"&vcm_vm="+s+A+q+m+"&vcm_pr="+x+"&vcm_tr="+c+"&vcm_cr="+j+g+e;if(B){z='%3Cscript src="'+z+'" type="text/javascript"%3E%3C/script%3E'}return z},parsedURI:function(f){var d={key:["source","protocol","authority","userInfo","user","password","host","port","relative","path","directory","file","query","anchor"],q:{name:"queryKey",parser:/(?:^|&)([^&=]*)=?([^&]*)/g},parser:{loose:/^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/}};var g=d,c=g.parser.loose.exec(f),f={},e=14;while(e--){f[g.key[e]]=c[e]||""}f[g.q.name]={};f[g.key[12]].replace(g.q.parser,function(j,h,k){if(h){f[g.q.name][h]=k}});return f},isPageSecure:function(){var c=(window.location.protocol&&window.location.protocol=="https:")?true:false;return c},cdnServer:function(){return(this.isSecure)?"https://secure.cdn.fastclick.net":"http://cdn.fastclick.net"},mediaServer:function(){return(this.isSecure)?"https://secure.fastclick.net":"http://media.fastclick.net"}}}(window,window.document));
