debug = require('debug')('calcbox')
_ = require 'lodash'

module.exports = class calcBox
  constructor: (params) ->
    {
      @width
      @height
      @depth
    } = params if params

  ###
  辺の長さでソートしたのを返す
  ###
  _sortSide: (parcel, sort)->
    sides = [
      side: 'width'
      value: parcel.width
    ,
      side: 'height'
      value: parcel.height
    ,
      side: 'depth'
      value: parcel.depth
    ]

    if sort is 'asc'
      sides = sides.sort (a, b)->
        a.value - b.value
    else
      sides = sides.sort (a, b)->
        b.value - a.value

    sides
  ###
  最大長を返す
  side: 'width'/'height'/'depth'
  value: 値
  ###
  _longestSide: (parcel)->
    sides = @_sortSide parcel

    sides[0]

  ###
  最短辺を返す
  side: 'width'/'height'/'depth'
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
    return longestSideOfBox.value < longestSideOfParcel.value

  ###
  最大辺同士を合わせた際に，対応する辺を導き出す
  ###
  _adjustSide: (box, parcel)->
    ASIS =
      width: 'width'
      height: 'height'
      depth: 'depth'
    LEFT_1 =
      width: 'height'
      height: 'depth'
      depth: 'width'
    LEFT_2 =
      width: 'depth'
      height: 'width'
      depth: 'height'
    # @FIXME: ねじれた位置での比較が考慮されていない。
    # 上記3種以外にheight,depthの2辺の順番違いの条件が存在する。

    switch box.side
      when 'width'
        switch parcel.side
          when 'width'
            ASIS
          when 'height'
            LEFT_1
          when 'depth'
            LEFT_2
      when 'height'
        switch parcel.side
          when 'width'
            LEFT_2
          when 'height'
            ASIS
          when 'depth'
            LEFT_1
      when 'depth'
        switch parcel.side
          when 'width'
            LEFT_1
          when 'height'
            LEFT_2
          when 'depth'
            ASIS

  ###
  荷物が箱の残りスペースの範囲に収まっているか
  ###
  _isOverSide: (parcel)->
    table = @_sortSide @
    sortedParcel = @_sortSide parcel
    _.zip(table, sortedParcel).some (side)->
      side[0].value < side[1].value

  ###
  箱の体積を荷物が超えているかをチェックする
  ###
  _isOverVolume: (parcel)->
    volumeOfParcel = parcel.width * parcel.height * parcel.depth
    volumeOfBox = @width * @height * @depth
    return volumeOfBox < volumeOfParcel

  ###
  指定された荷物が箱に入るかどうかを確認する
  ###
  canContain: (parcel)->
    return null unless parcel

    {
      width
      height
      depth
    } = parcel

    return null unless width and height and depth

    # 最大辺が箱の最大辺を超えてしまったら入らない
    return false if @_isOverMaxSide parcel

    # 最大辺を合わせた際に，他の辺が箱の辺の長さを超えた
    return false if @_isOverSide parcel

    # 容量が箱を超えていたら入らない
    return false if @_isOverVolume parcel

    true

  _pushParcel: (parcel, table)->

    shortestSideOfBox = @_shortestSide @

    debug "shortestSideOfBox.side: #{shortestSideOfBox.side}"
    debug "table[shortestSideOfBox.side]: #{table[shortestSideOfBox.side]}"
    debug "parcel[table[shortestSideOfBox.side]]: #{parcel[table[shortestSideOfBox.side]]}"
    @[shortestSideOfBox.side] -= parcel[table[shortestSideOfBox.side]]

    # longestSideOfBox = @_longestSide @
    #
    # debug "longestSideOfBox.side: #{longestSideOfBox.side}"
    # debug "table[longestSideOfBox.side]: #{table[longestSideOfBox.side]}"
    # debug "parcel[table[longestSideOfBox.side]]: #{parcel[table[longestSideOfBox.side]]}"
    # @[longestSideOfBox.side] -= parcel[table[longestSideOfBox.side]]

  pushParcel: (parcel)->
    unless @canContain parcel
      return false

    # 箱に商品を入れる向きを決定し、商品分箱のサイズを小さくする
    #
    # ・箱に最大限に商品を入れるため、
    # 　荷物の最長辺が入る箱の最短長の辺を探し、それらの辺を合わせる向きで商品を箱に入れる。
    # ・商品の向きが決まったら、商品分箱のサイズを小さくして処理終了。

    BoxSides = @_sortSide @, 'asc'
    longestSideOfParcel = @_longestSide parcel
    # 箱の最短辺と荷物の長辺を比較して
    for BoxSide in BoxSides
      debug "box[#{BoxSide.side}] = #{parcel[BoxSide.side]}"
      if longestSideOfParcel.value <= BoxSide.value
        debug "longestSideOfParcel.side = #{longestSideOfParcel.side}"
        debug "BoxSide.side = #{BoxSide.side}"
        table = @_adjustSide longestSideOfParcel, BoxSide
        for k,v of table
          debug "box[#{k}]@#{@[k]} : parcel[#{v}]@#{parcel[v]}"

        @_pushParcel(parcel, table)
        break


    true


    # 箱を最大限に活かすために，
    # 箱の最短辺と荷物の長辺を比較．
    # 入ればそれで箱の容量を減らす．
    # 入らなければ次に短い荷物の辺を比較
    # 以下繰り返し

    # sides = @_sortSide parcel
    # shortestSideOfBox = @_shortestSide @
    # # 箱の最短辺と荷物の長辺を比較して
    # for side in sides
    #   debug "parcel[#{side.side}] = #{parcel[side.side]}"
    #   if shortestSideOfBox.value > side.value
    #     debug "shortestSideOfBox.side = #{shortestSideOfBox.side}"
    #     debug "side.side = #{side.side}"
    #     table = @_adjustSide shortestSideOfBox, side
    #     for k,v of table
    #       debug "box[#{k}]@#{@[k]} : parcel[#{v}]@#{parcel[v]}"
    #
    #     @_pushParcel(parcel, table)
    #     break
    #
    #
    # true
