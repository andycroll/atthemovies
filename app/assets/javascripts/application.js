//= require modernizr-2.8.3.custom
//= require turbolinks
//= require local_time

//= require init
//= require pages

document.addEventListener("turbolinks:load", function() {
  atthemovies.init();
})

if (document.readyState != 'loading') {
  atthemovies.init();
} else {
  document.addEventListener('DOMContentLoaded', atthemovies.init());
}
