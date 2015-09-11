var _, calcBox, debug;

debug = require('debug')('calcbox');

_ = require('lodash');

module.exports = calcBox = (function() {
  function calcBox(params) {
    if (params) {
      this.width = params.width, this.height = params.height, this.depth = params.depth;
    }
  }


  /*
  辺の長さでソートしたのを返す
   */

  calcBox.prototype._sortSide = function(parcel, sort) {
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
    if (sort === 'asc') {
      sides = sides.sort(function(a, b) {
        return a.value - b.value;
      });
    } else {
      sides = sides.sort(function(a, b) {
        return b.value - a.value;
      });
    }
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
    return longestSideOfBox.value < longestSideOfParcel.value;
  };


  /*
  荷物が箱の残りスペースの範囲に収まっているか
   */

  calcBox.prototype._isOverSide = function(parcel) {
    var sortedParcel, table;
    table = this._sortSide(this);
    sortedParcel = this._sortSide(parcel);
    return _.zip(table, sortedParcel).some(function(side) {
      return side[0].value < side[1].value;
    });
  };


  /*
  箱の体積を荷物が超えているかをチェックする
   */

  calcBox.prototype._isOverVolume = function(parcel) {
    var volumeOfBox, volumeOfParcel;
    volumeOfParcel = parcel.width * parcel.height * parcel.depth;
    volumeOfBox = this.width * this.height * this.depth;
    return volumeOfBox < volumeOfParcel;
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

  calcBox.prototype._pushParcel = function(parcel, suitableSideOfBox) {
    var boxSide, boxSides, i, len, shortestSideOfPrcel;
    boxSides = this._sortSide(this);
    shortestSideOfPrcel = this._shortestSide(parcel);
    for (i = 0, len = boxSides.length; i < len; i++) {
      boxSide = boxSides[i];
      if (suitableSideOfBox.side !== boxSide.side) {
        this[boxSide.side] -= shortestSideOfPrcel.value;
        return true;
      }
    }
    return false;
  };

  calcBox.prototype.pushParcel = function(parcel) {
    var boxSide, boxSides, i, len, longestSideOfParcel;
    if (!this.canContain(parcel)) {
      return false;
    }
    boxSides = this._sortSide(this, 'asc');
    longestSideOfParcel = this._longestSide(parcel);
    for (i = 0, len = boxSides.length; i < len; i++) {
      boxSide = boxSides[i];
      if (longestSideOfParcel.value <= boxSide.value) {
        debug("longestSideOfParcel.side = " + longestSideOfParcel.side);
        debug("boxSide.side = " + boxSide.side);
        return this._pushParcel(parcel, boxSide);
      }
    }
  };

  return calcBox;

})();
