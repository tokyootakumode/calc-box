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

  # 荷物を箱につめる。
  # 荷物の最長辺と、その辺に対応する箱の辺以外の辺をどの様に合わせるか調整してあわせ、
  # 荷物分 箱の容量を減らす
  _pushParcel: (parcel, suitableSideOfBox)->

    parcelSides = @_sortSide parcel
    longestSideOfPrcel  = parcelSides[1]
    shortestSideOfPrcel = parcelSides[2]

    # 箱の、荷物の最長辺に合わせる辺以外の一覧を取得する
    boxSides = @_sortSide @
    boxSides = boxSides.filter (boxSide)->
      suitableSideOfBox.side isnt boxSide.side
    longestSideOfBox  = boxSides[0]
    shortestSideOfBox = boxSides[1]

    if longestSideOfPrcel.value > shortestSideOfBox.value
      # 荷物の残りの辺の長い方が、箱の残りの辺の短い方より長い場合、
      # 長い辺同士、短い辺同士をあわせるしかない。
      @[shortestSideOfBox.side] -= shortestSideOfPrcel.value
    else
      # 荷物を入れたあとの箱の容量をできるだけ大きくするため、
      # 荷物の残りの辺の短い方を、箱の残りの辺の長い方とあわせる。
      @[longestSideOfBox.side] -= shortestSideOfPrcel.value

    return true

  pushParcel: (parcel)->
    unless @canContain parcel
      return false

    # 箱に荷物を入れる向きを調整し、荷物分箱のサイズを小さくする
    # ・箱に最大限に荷物を入れるため、
    # 　荷物の最長辺を、箱のできるだけ小さい辺に合わせて箱に入れる。
    # ・荷物の向きが決まったら、荷物分箱のサイズを小さくして処理終了。
    boxSides = @_sortSide @, 'asc'
    longestSideOfParcel = @_longestSide parcel

    # 荷物の最長辺を、箱の最短辺と順番に比較していく
    for boxSide in boxSides
      if longestSideOfParcel.value <= boxSide.value
        debug "longestSideOfParcel.side = #{longestSideOfParcel.side}"
        debug "boxSide.side = #{boxSide.side}"
        return @_pushParcel(parcel, boxSide)
