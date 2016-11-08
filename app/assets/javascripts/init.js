window.atthemovies = {
  init: function() {
    var body = document.querySelectorAll("body")[0];
    var jsController = body.getAttribute("data-js-controller");
    var jsAction = body.getAttribute("data-js-action");

    this.pageJS("atthemovies." + jsController + ".init", window);
    this.pageJS("atthemovies." + jsController + ".init" + jsAction, window);
  },

  pageJS: function(functionName, context) {
    var namespaces = functionName.split(".");
    var func = namespaces.pop();

    for (var i = 0; i < namespaces.length; i++) {
      if(context[namespaces[i]]) {
        context = context[namespaces[i]];
      } else {
        return null;
      }
    }
    if(typeof context[func] === "function") {
      return context[func].apply(context, null);
    } else {
      return null;
    }
  }
}
