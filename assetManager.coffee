class AssetManager
  constructor: (cacheManager) ->
    @cacheManager = cacheManager

  asMiddleware: (request, response, done) ->
    @cacheManager.shouldCache(request)
    done(request, response)


module.exports = AssetManager
