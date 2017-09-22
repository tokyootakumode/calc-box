debug = require('debug')('calcbox')
_ = require 'lodash'

module.exports = class CalcBox
  constructor: (params) ->
    {
      @width
      @height
      @depth
    } = params if params
    @parcels = []
    @x = @y = @z = 0

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

  _updatePositions: (parcel, side)->
    switch side
      when 'width'
        @x += parcel.width
      when 'height'
        @z += parcel.height
      when 'depth'
        @y += parcel.depth

  # 荷物を箱につめる。
  # 荷物の最長辺と、その辺に対応する箱の辺以外の辺をどの様に合わせるか調整してあわせ、
  # 荷物分 箱の容量を減らす
  _pushParcel: (parcel, suitableSideOfBox)->

    parcelSides = @_sortSide parcel
    # 荷物の、まだ箱のどの辺に合わせるか決定していない2辺を取得
    longerSideOfPrcel  = parcelSides[1]
    shorterSideOfPrcel = parcelSides[2]

    # 箱の、まだ荷物のどの辺に合わせるか決定していない2辺を取得
    boxSides = @_sortSide @
    boxSides = boxSides.filter (boxSide)->
      suitableSideOfBox.side isnt boxSide.side
    longerSideOfBox  = boxSides[0]
    shorterSideOfBox = boxSides[1]

    p =
      x: @x
      y: @y
      z: @z

    if longerSideOfPrcel.value > shorterSideOfBox.value
      # 荷物の残りの辺の長い方が、箱の残りの辺の短い方より長い場合、
      # 長い辺同士、短い辺同士をあわせるしかない。
      @[shorterSideOfBox.side] -= shorterSideOfPrcel.value
      p[suitableSideOfBox.side] = parcelSides[0].value
      p[shorterSideOfBox.side] = shorterSideOfPrcel.value
      p[longerSideOfBox.side] = longerSideOfPrcel.value
      @_updatePositions p, shorterSideOfBox.side
    else
      # 荷物を入れたあとの箱の容量をできるだけ大きくするため、
      # 荷物の残りの辺の短い方を、箱の残りの辺の長い方とあわせる。
      @[longerSideOfBox.side] -= shorterSideOfPrcel.value
      p[suitableSideOfBox.side] = parcelSides[0].value
      p[longerSideOfBox.side] = shorterSideOfPrcel.value
      p[shorterSideOfBox.side] = longerSideOfPrcel.value
      @_updatePositions p, longerSideOfBox.side
    @parcels.push p

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

  add: (parcel)->
    @parcels.push parcel

  pack: ->
    origBox = _.pick @, ['width', 'height', 'depth', 'x', 'y', 'z', 'parcels']
    [parcels, @parcels] = [_.cloneDeep(origBox.parcels), []]
    parcels.sort (a, b)->
      return r if r = Math.max(b.width, b.height, b.depth) - Math.max(a.width, a.height, a.depth)
      b.width * b.height * b.depth - a.width * a.height * a.depth
    return true if do ()=>
      for p in parcels
        return false unless @pushParcel p
      return true

    _.merge @, origBox
    [parcels, @parcels] = [_.cloneDeep(origBox.parcels), []]
    parcels.sort (a, b)->
      return r if r = Math.min(a.width, a.height, a.depth) - Math.min(b.width, b.height, b.depth)
      a.width * a.height * a.depth - b.width * b.height * b.depth
    for p in parcels
      return false unless @pushParcel p
    return true
