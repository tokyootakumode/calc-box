var CalcBox, _, debug;

debug = require('debug')('calcbox');

_ = require('lodash');

module.exports = CalcBox = (function() {
  function CalcBox(params) {
    if (params) {
      this.width = params.width, this.height = params.height, this.depth = params.depth;
    }
    this.parcels = [];
    this.x = this.y = this.z = 0;
  }


  /*
  辺の長さでソートしたのを返す
   */

  CalcBox.prototype._sortSide = function(parcel, sort) {
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

  CalcBox.prototype._longestSide = function(parcel) {
    var sides;
    sides = this._sortSide(parcel);
    return sides[0];
  };


  /*
  最短辺を返す
  side: 'width'/'height'/'depth'
  value: 値
   */

  CalcBox.prototype._shortestSide = function(parcel) {
    var sides;
    sides = this._sortSide(parcel);
    return sides[2];
  };


  /*
  最大辺が超えてないか
   */

  CalcBox.prototype._isOverMaxSide = function(parcel) {
    var longestSideOfBox, longestSideOfParcel;
    longestSideOfParcel = this._longestSide(parcel);
    longestSideOfBox = this._longestSide(this);
    return longestSideOfBox.value < longestSideOfParcel.value;
  };


  /*
  荷物が箱の残りスペースの範囲に収まっているか
   */

  CalcBox.prototype._isOverSide = function(parcel) {
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

  CalcBox.prototype._isOverVolume = function(parcel) {
    var volumeOfBox, volumeOfParcel;
    volumeOfParcel = parcel.width * parcel.height * parcel.depth;
    volumeOfBox = this.width * this.height * this.depth;
    return volumeOfBox < volumeOfParcel;
  };


  /*
  指定された荷物が箱に入るかどうかを確認する
   */

  CalcBox.prototype.canContain = function(parcel) {
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

  CalcBox.prototype._updatePositions = function(parcel, side) {
    switch (side) {
      case 'width':
        return this.x += parcel.width;
      case 'height':
        return this.z += parcel.height;
      case 'depth':
        return this.y += parcel.depth;
    }
  };

  CalcBox.prototype._pushParcel = function(parcel, suitableSideOfBox) {
    var boxSides, longerSideOfBox, longerSideOfPrcel, p, parcelSides, shorterSideOfBox, shorterSideOfPrcel;
    parcelSides = this._sortSide(parcel);
    longerSideOfPrcel = parcelSides[1];
    shorterSideOfPrcel = parcelSides[2];
    boxSides = this._sortSide(this);
    boxSides = boxSides.filter(function(boxSide) {
      return suitableSideOfBox.side !== boxSide.side;
    });
    longerSideOfBox = boxSides[0];
    shorterSideOfBox = boxSides[1];
    p = {
      x: this.x,
      y: this.y,
      z: this.z
    };
    if (longerSideOfPrcel.value > shorterSideOfBox.value) {
      this[shorterSideOfBox.side] -= shorterSideOfPrcel.value;
      p[suitableSideOfBox.side] = parcelSides[0].value;
      p[shorterSideOfBox.side] = shorterSideOfPrcel.value;
      p[longerSideOfBox.side] = longerSideOfPrcel.value;
      this._updatePositions(p, shorterSideOfBox.side);
    } else {
      this[longerSideOfBox.side] -= shorterSideOfPrcel.value;
      p[suitableSideOfBox.side] = parcelSides[0].value;
      p[longerSideOfBox.side] = shorterSideOfPrcel.value;
      p[shorterSideOfBox.side] = longerSideOfPrcel.value;
      this._updatePositions(p, longerSideOfBox.side);
    }
    this.parcels.push(p);
    return true;
  };

  CalcBox.prototype.pushParcel = function(parcel) {
    var boxSide, boxSides, j, len, longestSideOfParcel;
    if (!this.canContain(parcel)) {
      return false;
    }
    boxSides = this._sortSide(this, 'asc');
    longestSideOfParcel = this._longestSide(parcel);
    for (j = 0, len = boxSides.length; j < len; j++) {
      boxSide = boxSides[j];
      if (longestSideOfParcel.value <= boxSide.value) {
        debug("longestSideOfParcel.side = " + longestSideOfParcel.side);
        debug("boxSide.side = " + boxSide.side);
        return this._pushParcel(parcel, boxSide);
      }
    }
  };

  CalcBox.prototype.add = function(parcel) {
    return this.parcels.push(parcel);
  };

  CalcBox.prototype.pack = function() {
    var j, len, origBox, p, parcels, ref, ref1;
    origBox = _.pick(this, ['width', 'height', 'depth', 'x', 'y', 'z', 'parcels']);
    ref = [_.cloneDeep(origBox.parcels), []], parcels = ref[0], this.parcels = ref[1];
    parcels.sort(function(a, b) {
      var r;
      if (r = Math.max(b.width, b.height, b.depth) - Math.max(a.width, a.height, a.depth)) {
        return r;
      }
      return b.width * b.height * b.depth - a.width * a.height * a.depth;
    });
    if ((function(_this) {
      return function() {
        var j, len, p;
        for (j = 0, len = parcels.length; j < len; j++) {
          p = parcels[j];
          if (!_this.pushParcel(p)) {
            return false;
          }
        }
        return true;
      };
    })(this)()) {
      return true;
    }
    _.merge(this, origBox);
    ref1 = [_.cloneDeep(origBox.parcels), []], parcels = ref1[0], this.parcels = ref1[1];
    parcels.sort(function(a, b) {
      var r;
      if (r = Math.min(a.width, a.height, a.depth) - Math.min(b.width, b.height, b.depth)) {
        return r;
      }
      return a.width * a.height * a.depth - b.width * b.height * b.depth;
    });
    for (j = 0, len = parcels.length; j < len; j++) {
      p = parcels[j];
      if (!this.pushParcel(p)) {
        return false;
      }
    }
    return true;
  };

  return CalcBox;

})();
