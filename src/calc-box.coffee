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
  _isOverMaxSide: (parcel)->
    longestSideOfParcel = @_longestSide parcel
    longestSideOfBox = @_longestSide @

    # BOXの最大辺が荷物の最大辺に達するとオーバー
    return longestSideOfBox.value <= longestSideOfParcel.value

  ###
  最大辺同士を合わせた際に，対応する辺を導き出す
  ###
  _adjustSide: (box, parcel)->
    ASIS =
      width: 'width'
      height: 'height'
      length: 'length'
    LEFT_1 =
      width: 'length'
      height: 'width'
      length: 'height'
    LEFT_2 =
      width: 'height'
      height: 'length'
      length: 'width'

    switch box.side
      when 'width'
        switch parcel.side
          when 'width'
            ASIS
          when 'height'
            LEFT_1
          when 'length'
            LEFT_2
      when 'height'
        switch parcel.side
          when 'width'
            LEFT_2
          when 'height'
            ASIS
          when 'length'
            LEFT_1
      when 'length'
        switch parcel.side
          when 'width'
            LEFT_1
          when 'height'
            LEFT_2
          when 'length'
            ASIS

  ###
  最大辺を合わせた際に，残りの辺が箱からはみ出ていないか
  ###
  _isOverSide: (parcel)->
    longestSideOfParcel = @_longestSide parcel
    longestSideOfBox = @_longestSide @

    table = @_adjustSide longestSideOfBox, longestSideOfParcel

    for k, v of table
      if @[k] <= parcel[v]
        return true

    false    

  ###
  箱の体積を荷物が超えているかをチェックする
  ###
  _isOverVolume: (parcel)->
    volumeOfParcel = parcel.width * parcel.height * parcel.length
    volumeOfBox = @width * @height * @length

    return volumeOfBox <= volumeOfParcel

  ###
  指定された荷物が箱に入るかどうかを確認する
  ###
  canContain: (parcel)->
    return null unless parcel

    {
      width
      height
      length
    } = parcel

    return null unless width and height and length

    # 最大辺が箱の最大辺を超えてしまったら入らない
    return false if @_isOverMaxSide parcel

    # 最大辺を合わせた際に，他の辺が箱の辺の長さを超えた
    return false if @_isOverSide parcel

    # 容量が箱を超えていたら入らない
    return false if @_isOverVolume parcel


    true
