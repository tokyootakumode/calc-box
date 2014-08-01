module.exports = class calcBox
  constructor: (params) ->
    {
      @width
      @height
      @length
    } = params if params

  ###
  最大長を返す
  side: 'width'/'height'/'length'
  value: 値
  ###
  _longestSide: (parcel)->
    sides = [
      side: 'width'
      value: parcel.width
    ,
      side: 'height'
      value: parcel.height
    ,
      side: 'length'
      value: parcel.length
    ]
    sides = sides.sort (a, b)->
      b.value - a.value

    sides[0]

  ###
  最大辺が超えてないか
  ###
  _isOverSide: (parcel)->
    longestSideOfParcel = @_longestSide parcel
    longestSideOfBox = @_longestSide @

    # BOXの最大辺が荷物の最大辺に達するとオーバー
    return longestSideOfBox.value <= longestSideOfParcel.value

  _isOverVolume: (parcel)->
    volumeOfParcel = parcel.width * parcel.height * parcel.length
    volumeOfBox = @width * @height * @length

    return volumeOfBox <= volumeOfParcel

  canContain: (parcel)->
    return null unless parcel

    {
      width
      height
      length
    } = parcel

    return null unless width and height and length

    # 最大辺が箱の最大辺を超えてしまったら入らない
    return false if @_isOverSide parcel

    return false if @_isOverVolume parcel

    true
