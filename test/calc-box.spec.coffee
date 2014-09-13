require 'coffee-errors'

should = require 'should'
sinon = require 'sinon'
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
      length: 300

    should.exists box
    canContain = do box.canContain
    should.not.exists canContain

describe '1つの荷物を使ったテスト', ->
  it '荷物は横幅・縦幅・奥行きを持っている', ->
    # TODO
    box = new calcBox
      width: 100
      height: 200
      length: 300

    canContain = box.canContain {}
    should.not.exists canContain
  it '箱に入りきるサイズ', ->
    box = new calcBox
      width: 100
      height: 200
      length: 300

    parcel =
      width: 10
      height: 20
      length: 30

    canContain = box.canContain parcel
    should.exists canContain
    canContain.should.be.true

  it '荷物の最大辺が箱の最大辺を超えてしまった', ->
    box = new calcBox
      width: 300
      height: 100
      length: 200

    parcel =
      width: 300
      height: 20
      length: 30

    canContain = box.canContain parcel
    should.exists canContain
    canContain.should.be.false

  it '荷物の最大辺が箱の1辺を超えている', ->
    box = new calcBox
      width: 300
      height: 100
      length: 200

    parcel = 
      width: 250
      height: 10
      length: 20

    canContain = box.canContain parcel
    should.exists canContain
    canContain.should.be.true

  it '荷物の容量が箱の容量を超えている', ->
    box = new calcBox
      width: 100
      height: 50
      length: 80

    parcel = 
      width: 90
      height: 90
      length: 90

    canContain = box.canContain parcel
    should.exists canContain
    canContain.should.be.false

  it '荷物の容量が超えていないが，二番目に長い辺が超えている', ->
    box = new calcBox
      width: 300
      height: 50
      length: 80

    parcel = 
      width: 90
      height: 90
      length: 90

    canContain = box.canContain parcel
    should.exists canContain
    canContain.should.be.false

  it '荷物を入れたあとに残りの容量が減る', ->
    box = new calcBox
      width: 100
      height: 200
      length: 300

    parcelA =
      width: 10
      height: 20
      length: 230

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    box.width.should.eql 100
    box.height.should.eql 200
    box.length.should.eql 290

describe '複数個の荷物を使ったテスト', ->
  it '荷物を入れたあとに箱の残り容量が減る', ->
    box = new calcBox
      width: 100
      height: 200
      length: 300

    parcelA =
      width: 99
      height: 99
      length: 99

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    box.width.should.eql 100
    box.height.should.eql 200
    box.length.should.eql 102

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    box.width.should.eql 100
    box.height.should.eql 101
    box.length.should.eql 102

    r = box.pushParcel parcelA
    should.exists r
    r.should.be.true

    box.width.should.eql 100
    box.height.should.eql 101
    box.length.should.eql 3

    canContain = box.canContain parcelA
    should.exists canContain
    canContain.should.be.false

