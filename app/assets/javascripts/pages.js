atthemovies.pages = {
  initHome: function() {
    this.buildGeoLink();
    this.clickHandlerGeoLink();
  },

  buildGeoLink: function() {
    if (Modernizr.geolocation) {
      var link = ' or <a id="geoLink" href="">Cinemas Nearby</a>';
      var headerTwo = document.querySelectorAll('h2')[0]
      headerTwo.innerHTML = headerTwo.innerHTML + link;
    }
  },

  clickHandlerGeoLink: function() {
    if (Modernizr.geolocation) {
      var geoLink = document.querySelectorAll('#geoLink')[0]
      geoLink.addEventListener('click', function() {
        navigator.geolocation.getCurrentPosition(function(position) {
          var latitude = position.coords.latitude.toFixed(4);
          var longitude = position.coords.longitude.toFixed(4);
          geoLink.setAttribute('href', '/cinemas?near=' + latitude + ',' + longitude);

          var event = document.createEvent('HTMLEvents');
          event.initEvent('click', true, false);
          geoLink.dispatchEvent(event);
        }, this.handleGeoError);
      })
    }
  },

  handleGeoError: function(err) {
    if (err.code == 1) { /* no */ }
  }
}
