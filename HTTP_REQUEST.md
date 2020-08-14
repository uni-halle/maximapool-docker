# Sample capture of network traffic between ILIAS and the MaximaPool Server

Request:

```
POST /MaximaPool/MaximaPool HTTP/1.1
Host: maxima-pool:8080
Accept: */*
Content-Length: 852
Content-Type: application/x-www-form-urlencoded

input=cab%3Ablock%28%5B%5D%2Cprint%28%22%5BTimeStamp%3D+%5B+0+%5D%2C+Locals%3D+%5B+0%3D%5B+error%3D+%5B%22%29%2C+cte%28%22CASresult%22%2Cerrcatch%28diff%28x%5En%2Cx%29%29%29%2C+print%28%221%3D%5B+error%3D+%5B%22%29%2C+cte%28%22STACKversion%22%2Cerrcatch%28stackmaximaversion%29%29%2C+print%28%222%3D%5B+error%3D+%5B%22%29%2C+cte%28%22MAXIMAversion%22%2Cerrcatch%28MAXIMA_VERSION_STR%29%29%2C+print%28%223%3D%5B+error%3D+%5B%22%29%2C+cte%28%22MAXIMAversionnum%22%2Cerrcatch%28MAXIMA_VERSION_NUM%29%29%2C+print%28%224%3D%5B+error%3D+%5B%22%29%2C+cte%28%22externalformat%22%2Cerrcatch%28adjust_external_format%28%29%29%29%2C+print%28%225%3D%5B+error%3D+%5B%22%29%2C+cte%28%22CAStime%22%2Cerrcatch%28CAStime%3A%222020-08-14+10%3A43%3A50%22%29%29%2C+print%28%22%5D+%5D%22%29%2C+return%28true%29%29%3B%0A&timeout=5000&ploturlbase=!ploturl!&version=2017121800
```

which decodes to:
```
input=cab:block([],
  print("[TimeStamp= [ 0 ], Locals= [ 0=[ error= ["),
  cte("CASresult",errcatch(diff(x^n,x))),
  print("1=[ error= ["),
  cte("STACKversion",errcatch(stackmaximaversion)),
  print("2=[ error= ["),
  cte("MAXIMAversion",errcatch(MAXIMA_VERSION_STR)),
  print("3=[ error= ["),
  cte("MAXIMAversionnum",errcatch(MAXIMA_VERSION_NUM)),
  print("4=[ error= ["),
  cte("externalformat",errcatch(adjust_external_format())),
  print("5=[ error= ["),
  cte("CAStime",errcatch(CAStime:"2020-08-14 10:43:50")),
  print("] ]"),
  return(true));
&timeout=5000
&ploturlbase=!ploturl!
&version=2017121800
```

Response:

```
HTTP/1.1 200 
Content-Type: text/plain;charset=UTF-8
Content-Length: 1152
Date: Fri, 14 Aug 2020 08:43:50 GMT

WARNING:
Couldn't re-execute SBCL with proper personality flags (/proc isn't mounted? setuid?)
Trying to continue anyway.
Maxima restarted.
(%i5) 
(%o5) "/opt/maximapool/2017121800/maximalocal.mac"
(%i6) 
[TimeStamp= [ 0 ], Locals= [ 0=[ error= [ 
], key = [ 
CASresult 
] 
, value = [ 
n*x^(n-1) 
], dispvalue = [ 
n*x^(n-1) 
], display = [ 
n\,x^{n-1} 
] 
],  
1=[ error= [ 
], key = [ 
STACKversion 
] 
, value = [ 
2017121800 
], dispvalue = [ 
2017121800 
], display = [ 
2017121800 
] 
],  
2=[ error= [ 
], key = [ 
MAXIMAversion 
] 
, value = [ 
"5.41.0" 
], dispvalue = [ 
"5.41.0" 
], display = [ 
\mbox{5.41.0} 
] 
],  
3=[ error= [ 
], key = [ 
MAXIMAversionnum 
] 
, value = [ 
41.0 
], dispvalue = [ 
41.0 
], display = [ 
41.0 
] 
],  
4=[ error= [ 
The external format is (UTF-8 REPLACEMENT ...)
and has not been changed.
], key = [ 
externalformat 
] 
, value = [ 
false 
], dispvalue = [ 
false 
], display = [ 
\mathbf{false} 
] 
],  
5=[ error= [ 
], key = [ 
CAStime 
] 
, value = [ 
"2020-08-14 10:43:50" 
], dispvalue = [ 
"2020-08-14 10:43:50" 
], display = [ 
\mbox{2020-08-14 10:43:50} 
] 
],  
] ] 
(%o9) true
(%i10) 
(%o10) 
```
