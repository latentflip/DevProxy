_parseUrl = require('url').parse

parseUrl = (url) ->
  _parseUrl(url, true)

class CacheManager
  constructor: (host = 'cache.com') ->
    @cache = {}
    @cacheHost = new RegExp(host)

  shouldHandleRequest: (request) ->
    request.url.match @cacheHost

  manageRequest: (request) ->
    url = parseUrl(request.url)
    if url.query.add
      @cache[url.query.add] = true
    if url.query.delete
      delete(@cache[url.query.delete])

  toString: ->
    "Managing #{@cacheHost}\n\n#{JSON.stringify @cache, null, 2}"

module.exports = CacheManager
