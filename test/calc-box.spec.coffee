require 'coffee-errors'

should = require 'should'
combinatorics = require 'js-combinatorics'

# using compiled JavaScript file here to be sure module works
calcBox = require '../lib/calc-box.js'


describe 'check generals', ->
  it 'construct box with no params', ->
    box = new calcBox
    should.exists box
  it 'construct box with not enough params', ->
    box = new calcBox
      width: 10
    should.exists box
  it 'canContainは必ずparcelを受け取る', ->
    box = new calcBox
      width: 100
      height: 200
      depth: 300

    should.exists box
    canContain = do box.canContain
    should.not.exists canContain

describe '1つの荷物を使ったテスト', ->
  it '荷物は横幅・縦幅・奥行きを持っている', ->
    # TODO
    box = new calcBox
      width: 100
      height: 200
      depth: 300

    canContain = box.canContain {}
    should.not.exists canContain
  it '箱に入りきるサイズ', ->
    box = new calcBox
      width: 100
      height: 200
      depth: 300

    parcel =
      width: 10
      height: 20
      depth: 30

    canContain = box.canContain parcel
    should.exists canContain
    canContain.should.be.true

  it '箱の内側にぴったり入りきるサイズ', ->
    box = new calcBox
      width: 100
      height: 200
      depth: 300

    parcel =
      width: 100
      height: 200
      depth: 300

    canContain = box.canContain parcel
    should.exists canContain
    canContain.should.be.true

  it '荷物の最大辺が箱の最大辺を超えてしまった', ->
    box = new calcBox
      width: 300
      height: 100
      depth: 200

    parcel =
      width: 301
      height: 20
      depth: 30

    canContain = box.canContain parcel
    should.exists canContain
    canContain.should.be.false

  it '荷物の最大辺が箱の1辺を超えている', ->
    box = new calcBox
      width: 300
      height: 100
      depth: 200

    parcel =
      width: 250
      height: 10
      depth: 20

    canContain = box.canContain parcel
    should.exists canContain
    canContain.should.be.true

  it '荷物の容量が箱の容量を超えている', ->
    box = new calcBox
      width: 100
      height: 50
      depth: 80

    parcel =
      width: 90
      height: 90
      depth: 90

    canContain = box.canContain parcel
    should.exists canContain
    canContain.should.be.false

  it '荷物の容量が超えていないが，二番目に長い辺が超えている', ->
    box = new calcBox
      width: 300
      height: 50
      depth: 80

    parcel =
      width: 90
      height: 90
      depth: 90

    canContain = box.canContain parcel
    should.exists canContain
    canContain.should.be.false

  it '荷物を入れたあとに残りの容量が減る', ->
    box = new calcBox
      width: 100
      height: 200
      depth: 300

    parcelA =
      width: 10
      height: 20
      depth: 230

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    box.width.should.eql 100
    box.height.should.eql 190
    box.depth.should.eql 300

  it '荷物を入れたあとに残りの容量が減る2', ->
    box = new calcBox
      width: 100
      height: 200
      depth: 300

    parcelA =
      width: 10
      height: 110
      depth: 230

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    box.width.should.eql 90
    box.height.should.eql 200
    box.depth.should.eql 300

describe '複数個の荷物を使ったテスト', ->
  it '荷物を入れたあとに箱の残り容量が減る(荷物が直方体)', ->
    box = new calcBox
      width: 100
      height: 200
      depth: 300

    parcelA =
      width: 98
      height: 99
      depth: 100

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    box.width.should.eql 100
    box.height.should.eql 200
    box.depth.should.eql 104

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    box.width.should.eql 100
    box.height.should.eql 102
    box.depth.should.eql 104

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    box.width.should.eql 100
    box.height.should.eql 102
    box.depth.should.eql 6

    canContain = box.canContain parcelA
    should.exists canContain
    canContain.should.be.false

  it '荷物を入れたあとに箱の残り容量が減る(荷物が立方体)', ->
    box = new calcBox
      width: 100
      height: 200
      depth: 300

    parcelA =
      width: 99
      height: 99
      depth: 99

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    box.width.should.eql 100
    box.height.should.eql 200
    box.depth.should.eql 102

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    box.width.should.eql 100
    box.height.should.eql 101
    box.depth.should.eql 102

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    box.width.should.eql 100
    box.height.should.eql 101
    box.depth.should.eql 3

    canContain = box.canContain parcelA
    should.exists canContain
    canContain.should.be.false

describe '箱の向きについて', ->
  MARK_IV =
    width: 38.1 # 15 inch
    height: 30.48 #12 inch
    depth: 20.32 # 8 inch
  combinatorics.permutation([21, 30, 20]).toArray().map (size)->
    width: size[0]
    height: size[1]
    depth: size[2]
  .forEach (parcel)->
    describe "#{parcel.width}w x #{parcel.height}h x #{parcel.depth}d が", ->
      it "MARK IV箱に入ること", ->
        box = new calcBox MARK_IV
        box.canContain(parcel).should.be.true

describe '過去に問題があったケースが再現しない事のテスト', ->
  it '期待通りの箱に期待通りの個数荷物が入る', ->
    # Maihama の BOX4 のサイズ
    box = new calcBox
      width: 51
      height: 29
      depth: 30

    parcelA =
      width: 21
      height: 30
      depth: 3

    i = 1
    while i <= 20
      # 箱に1つ商品を入れる
      r = box.pushParcel parcelA
      should.exists r
      if i <= 19
        r.should.be.true
      else
        r.should.be.false
      i++
