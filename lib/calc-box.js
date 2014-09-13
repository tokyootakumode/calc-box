var calcBox, debug;

debug = require('debug')('calcbox');

module.exports = calcBox = (function() {
  function calcBox(params) {
    if (params) {
      this.width = params.width, this.height = params.height, this.depth = params.depth;
    }
  }


  /*
  辺の長さでソートしたのを返す
   */

  calcBox.prototype._sortSide = function(parcel) {
    var sides;
    sides = [
      {
        side: 'width',
        value: parcel.width
      }, {
        side: 'height',
        value: parcel.height
      }, {
        side: 'depth',
        value: parcel.depth
      }
    ];
    sides = sides.sort(function(a, b) {
      return b.value - a.value;
    });
    return sides;
  };


  /*
  最大長を返す
  side: 'width'/'height'/'depth'
  value: 値
   */

  calcBox.prototype._longestSide = function(parcel) {
    var sides;
    sides = this._sortSide(parcel);
    return sides[0];
  };


  /*
  最短辺を返す
  side: 'width'/'height'/'depth'
  value: 値
   */

  calcBox.prototype._shortestSide = function(parcel) {
    var sides;
    sides = this._sortSide(parcel);
    return sides[2];
  };


  /*
  最大辺が超えてないか
   */

  calcBox.prototype._isOverMaxSide = function(parcel) {
    var longestSideOfBox, longestSideOfParcel;
    longestSideOfParcel = this._longestSide(parcel);
    longestSideOfBox = this._longestSide(this);
    return longestSideOfBox.value <= longestSideOfParcel.value;
  };


  /*
  最大辺同士を合わせた際に，対応する辺を導き出す
   */

  calcBox.prototype._adjustSide = function(box, parcel) {
    var ASIS, LEFT_1, LEFT_2;
    ASIS = {
      width: 'width',
      height: 'height',
      depth: 'depth'
    };
    LEFT_1 = {
      width: 'height',
      height: 'depth',
      depth: 'width'
    };
    LEFT_2 = {
      width: 'depth',
      height: 'width',
      depth: 'height'
    };
    switch (box.side) {
      case 'width':
        switch (parcel.side) {
          case 'width':
            return ASIS;
          case 'height':
            return LEFT_1;
          case 'depth':
            return LEFT_2;
        }
        break;
      case 'height':
        switch (parcel.side) {
          case 'width':
            return LEFT_2;
          case 'height':
            return ASIS;
          case 'depth':
            return LEFT_1;
        }
        break;
      case 'depth':
        switch (parcel.side) {
          case 'width':
            return LEFT_1;
          case 'height':
            return LEFT_2;
          case 'depth':
            return ASIS;
        }
    }
  };


  /*
  最大辺を合わせた際に，残りの辺が箱からはみ出ていないか
   */

  calcBox.prototype._isOverSide = function(parcel) {
    var k, longestSideOfBox, longestSideOfParcel, table, v;
    longestSideOfParcel = this._longestSide(parcel);
    longestSideOfBox = this._longestSide(this);
    table = this._adjustSide(longestSideOfBox, longestSideOfParcel);
    for (k in table) {
      v = table[k];
      if (this[k] <= parcel[v]) {
        return true;
      }
    }
    return false;
  };


  /*
  箱の体積を荷物が超えているかをチェックする
   */

  calcBox.prototype._isOverVolume = function(parcel) {
    var volumeOfBox, volumeOfParcel;
    volumeOfParcel = parcel.width * parcel.height * parcel.depth;
    volumeOfBox = this.width * this.height * this.depth;
    return volumeOfBox <= volumeOfParcel;
  };


  /*
  指定された荷物が箱に入るかどうかを確認する
   */

  calcBox.prototype.canContain = function(parcel) {
    var depth, height, width;
    if (!parcel) {
      return null;
    }
    width = parcel.width, height = parcel.height, depth = parcel.depth;
    if (!(width && height && depth)) {
      return null;
    }
    if (this._isOverMaxSide(parcel)) {
      return false;
    }
    if (this._isOverSide(parcel)) {
      return false;
    }
    if (this._isOverVolume(parcel)) {
      return false;
    }
    return true;
  };

  calcBox.prototype._pushParcel = function(parcel, table) {
    var longestSideOfBox;
    longestSideOfBox = this._longestSide(this);
    debug("longestSideOfBox.side: " + longestSideOfBox.side);
    debug("table[longestSideOfBox.side]: " + table[longestSideOfBox.side]);
    debug("parcel[table[longestSideOfBox.side]]: " + parcel[table[longestSideOfBox.side]]);
    return this[longestSideOfBox.side] -= parcel[table[longestSideOfBox.side]];
  };

  calcBox.prototype.pushParcel = function(parcel) {
    var k, shortestSideOfBox, side, sides, table, v, _i, _len;
    if (!this.canContain(parcel)) {
      return false;
    }
    sides = this._sortSide(parcel);
    shortestSideOfBox = this._shortestSide(this);
    for (_i = 0, _len = sides.length; _i < _len; _i++) {
      side = sides[_i];
      debug("parcel[" + side.side + "] = " + parcel[side.side]);
      if (shortestSideOfBox.value > side.value) {
        debug("shortestSideOfBox.side = " + shortestSideOfBox.side);
        debug("side.side = " + side.side);
        table = this._adjustSide(shortestSideOfBox, side);
        for (k in table) {
          v = table[k];
          debug("box[" + k + "]@" + this[k] + " : parcel[" + v + "]@" + parcel[v]);
        }
        this._pushParcel(parcel, table);
        break;
      }
    }
    return true;
  };

  return calcBox;

})();
