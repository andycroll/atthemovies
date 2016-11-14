window.atthemovies = {
  init: function() {
    var body = document.querySelectorAll("body")[0];
    var jsController = body.getAttribute("data-js-controller");
    var jsAction = body.getAttribute("data-js-action");

    this.pageJS("atthemovies." + jsController + ".init", window);
    this.pageJS("atthemovies." + jsController + ".init" + jsAction, window);
  },

  // pass a string to call a namespaced function that may not exist
  pageJS: function(functionString, context) {
    var namespaces = functionString.split(".");
    var functionName = namespaces.pop();

    // recursively loop into existing namespaces, else return harmlessly
    for (var i = 0; i < namespaces.length; i++) {
      if(context[namespaces[i]]) {
        context = context[namespaces[i]];
      } else {
        return null;
      }
    }

    // call the function if it exists in this context, else return harmlessly
    if(typeof context[functionName] === "function") {
      return context[functionName].apply(context, null);
    } else {
      return null;
    }
  }
}
