http = require "http"
sys = require "sys"
express = require('express')
app = express()
CacheManager = require './cacheManager'
AssetManager = require './assetManager'

cleanHost = (host) ->
  host.replace ':80', ''

cacheManager = new CacheManager('cache.com')
assetManager = new AssetManager(cacheManager)

console.log cacheManager

http.createServer( (request, response) ->
  if cacheManager.shouldHandleRequest(request)
    cacheManager.manageRequest(request)
    response.end(cacheManager.toString())
  else
    assetManager.asMiddleware request, response, (request, response) ->

      sys.log request.connection.remoteAddress + ": " + request.method + " " + request.url

      proxy = http.createClient(80, cleanHost(request.headers["host"]))

      proxy_request = proxy.request(request.method, request.url, request.headers)

      proxy_request.addListener "response", (proxy_response) ->
        proxy_response.addListener "data", (chunk) ->
          response.write chunk, "binary"

        proxy_response.addListener "end", ->
          response.end()

        response.writeHead proxy_response.statusCode, proxy_response.headers

      request.addListener "data", (chunk) ->
        proxy_request.write chunk, "binary"

      request.addListener "end", ->
        proxy_request.end()

).listen 8089
