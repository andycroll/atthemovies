atthemovies.pages.pages = {
  init: function() {},
  initHome: function() {
    this.buildGeoLink();
    this.clickHandlerGeoLink();
  },

  buildGeoLink: function() {
    if (Modernizr.geolocation) {
      var link = ' or <a id="geoLink" href="">Cinemas Nearby</a>';
      $('h2').append(link);
    }
  },

  clickHandlerGeoLink: function() {
    if (Modernizr.geolocation) {
      $('#geoLink').on('click', function() {
        navigator.geolocation.getCurrentPosition(function(position) {
          var latitude = position.coords.latitude.toFixed(4);
          var longitude = position.coords.longitude.toFixed(4);
          $('#geoLink').attr('href', '/cinemas?near=' + latitude + ',' + longitude).click();
        }, this.handleGeoError);
      })
    }
  },

  handleGeoError: function(err) {
    if (err.code == 1) { /* no */ }
  }
}
