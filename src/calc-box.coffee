debug = require('debug')('calcbox')

module.exports = class calcBox
  constructor: (params) ->
    {
      @width
      @height
      @length
    } = params if params

  ###
  辺の長さでソートしたのを返す
  ###
  _sortSide: (parcel)->
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

    sides
  ###
  最大長を返す
  side: 'width'/'height'/'length'
  value: 値
  ###
  _longestSide: (parcel)->
    sides = @_sortSide parcel

    sides[0]

  ###
  最短辺を返す
  side: 'width'/'height'/'length'
  value: 値
  ###
  _shortestSide: (parcel)->
    sides = @_sortSide parcel

    sides[2]

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
      width: 'height'
      height: 'length'
      length: 'width'
    LEFT_2 =
      width: 'length'
      height: 'width'
      length: 'height'

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

  _pushParcel: (parcel, table)->

    longestSideOfBox = @_longestSide @

    debug "longestSideOfBox.side: #{longestSideOfBox.side}"
    debug "table[longestSideOfBox.side]: #{table[longestSideOfBox.side]}"
    debug "parcel[table[longestSideOfBox.side]]: #{parcel[table[longestSideOfBox.side]]}"
    @[longestSideOfBox.side] -= parcel[table[longestSideOfBox.side]]

  pushParcel: (parcel)->
    unless @canContain parcel
      return false

    # 箱を最大限に活かすために，
    # 箱の最短辺と荷物の長辺を比較．
    # 入ればそれで箱の容量を減らす．
    # 入らなければ次に短い荷物の辺を比較
    # 以下繰り返し

    sides = @_sortSide parcel
    shortestSideOfBox = @_shortestSide @
    # 箱の最短辺と荷物の長辺を比較して
    for side in sides
      debug "parcel[#{side.side}] = #{parcel[side.side]}"
      if shortestSideOfBox.value > side.value
        debug "shortestSideOfBox.side = #{shortestSideOfBox.side}"
        debug "side.side = #{side.side}"
        table = @_adjustSide shortestSideOfBox, side
        for k,v of table
          debug "box[#{k}]@#{@[k]} : parcel[#{v}]@#{parcel[v]}"
        
        @_pushParcel(parcel, table)
        break


    true
    




