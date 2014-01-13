@ = require('mho:std', 'mho:app');
var observable = require('mho:observable');
var surface    = require('mho:surface');
var app        = require('mho:app');

var words = observable.ObservableVar({});

function addWord(words, word, definition) {
  words.modify(function(current_words) {
    var definitions = current_words[word] || observable.ObservableVar([]);
    definitions.modify(definitions -> definitions.concat(definition));
    var new_definition = {};
    new_definition[word] = definitions;
    return @.merge(current_words, new_definition);
  });
}

function renderWord([word, defns]) {
  return `<li>$word
    <ul>
      ${defns .. @.transform(defns -> defns .. @.map(d -> `<li>${d}</li>`))}
    </ul>
  </li>`
}

function renderWords(words) {
  return @.map(@.ownPropertyPairs(words), renderWord);
}

function addWordWidget() {
  var resetEmitter = @.Emitter();
  var wordEntered;
  var wordWidget = @.Mechanism(app.TextInput(), function(elem) {
    waitfor {
      elem .. @.when('keyup') {
        |event|
        wordEntered = elem.value;
      }
    } and {
      resetEmitter.wait();
      wordEntered = undefined;
      elem.value = "";
    }
  });
  var defnEntered;
  var defnWidget = @.Mechanism(app.TextInput(), function(elem) {
    waitfor {
      elem .. @.when('keyup') {
        |event|
        defnEntered = elem.value;
      }
    } and {
      resetEmitter.wait();
      defnEntered = undefined;
      elem.value = "";
    }
  });
  var button = @.Mechanism(app.Submit("Save"), function(elem) {
    elem .. @.when('click') { |event|
      addWord(words, wordEntered, defnEntered);
      resetEmitter.emit();
    };
  })
  return [wordWidget, defnWidget, button];
}

surface.appendContent(app.mainContent, `
  <h1>The Ictionary</h1>
  ${addWordWidget()}
  <ul> ${@.transform(words, renderWords)}</ul>
`);
addWord(words, 'Dog', 'A Wolfish Beast');
