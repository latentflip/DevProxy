http = require('http')
sys  = require('sys')
fs = require 'fs'
gzip = require 'zlib'

caches = 'http://floatapp.com/css/960.css'
cached = true

http.createServer((request, response) ->
  caching = !!request.url.match(caches)
  
  if caching and !cached
    cacheFile = fs.createWriteStream(__dirname + '/960.css', { flags: 'w+' })

  sys.log(request.connection.remoteAddress + ": " + request.method + " " + request.url)

  host = request.headers['host']
  host = host.split(':')[0]
  proxy = http.createClient(80, host)
  
  proxy_request = proxy.request(request.method, request.url, request.headers)

  proxy_request.addListener 'response', (proxy_response) ->
    if caching and !cached
      gunzip = gzip.createGunzip()
      proxy_response.pipe(gunzip).pipe(cacheFile)
    
    if caching and cached
      zip = gzip.createGzip()
      
      cacheFile = fs.createReadStream(__dirname + '/960.css')
      cacheFile.pipe(zip).pipe(response)

    else
      proxy_response.addListener 'data', (chunk) ->
        response.write(chunk, 'binary')

      proxy_response.addListener 'end', ->
        response.end()

    response.writeHead(proxy_response.statusCode, proxy_response.headers)
    
  request.addListener 'data', (chunk) ->
    proxy_request.write(chunk, 'binary')
  
  request.addListener 'end', ->
    proxy_request.end()
    
).listen(8089)

