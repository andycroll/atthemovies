atthemovies.pages.pages = {
  init: function() {},
  initHome: function() {
    this.getGeoLocation();
  },

  buildGeoLink: function(position) {
    var latitude = position.coords.latitude.toFixed(4);
    var longitude = position.coords.longitude.toFixed(4);
    var link = ' or <a href="/cinemas?near=' + latitude + ',' + longitude + '"">Cinemas Nearby</a>';
    $('h2').append(link);
  },

  getGeoLocation: function() {
    if (Modernizr.geolocation) {
      navigator.geolocation.getCurrentPosition(this.buildGeoLink, this.handleGeoError);
    }
  },

  handleGeoError: function(err) {
    if (err.code == 1) { /* no */ }
  }
}
