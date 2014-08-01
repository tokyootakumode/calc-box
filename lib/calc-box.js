var calcBox;

module.exports = calcBox = (function() {
  function calcBox(params) {
    if (params) {
      this.width = params.width, this.height = params.height, this.length = params.length;
    }
  }


  /*
  最大長を返す
  side: 'width'/'height'/'length'
  value: 値
   */

  calcBox.prototype._longestSide = function(parcel) {
    var sides;
    sides = [
      {
        side: 'width',
        value: parcel.width
      }, {
        side: 'height',
        value: parcel.height
      }, {
        side: 'length',
        value: parcel.length
      }
    ];
    sides = sides.sort(function(a, b) {
      return b.value - a.value;
    });
    return sides[0];
  };


  /*
  最大辺が超えてないか
   */

  calcBox.prototype._isOverSide = function(parcel) {
    var longestSideOfBox, longestSideOfParcel;
    longestSideOfParcel = this._longestSide(parcel);
    longestSideOfBox = this._longestSide(this);
    return longestSideOfBox.value <= longestSideOfParcel.value;
  };

  calcBox.prototype._isOverVolume = function(parcel) {
    var volumeOfBox, volumeOfParcel;
    volumeOfParcel = parcel.width * parcel.height * parcel.length;
    volumeOfBox = this.width * this.height * this.length;
    return volumeOfBox <= volumeOfParcel;
  };

  calcBox.prototype.canContain = function(parcel) {
    var height, length, width;
    if (!parcel) {
      return null;
    }
    width = parcel.width, height = parcel.height, length = parcel.length;
    if (!(width && height && length)) {
      return null;
    }
    if (this._isOverSide(parcel)) {
      return false;
    }
    if (this._isOverVolume(parcel)) {
      return false;
    }
    return true;
  };

  return calcBox;

})();