@Utilities =
  applyParams: (obj, thisValue, params) ->
    if typeof obj is 'function'
      return obj.call thisValue, params
    else
      return obj
