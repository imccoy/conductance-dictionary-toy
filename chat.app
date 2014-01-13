@ = require('mho:std');
var observable = require('mho:observable');
var surface    = require('mho:surface');
var app        = require('mho:app');

var words = observable.ObservableVar({});

function addWord(words, word, definition) {
  words.modify(function(current_words) {
    var definitions = current_words[word];
    if (definitions == undefined) {
      definitions = observable.ObservableVar([]);
    }
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

surface.appendContent(app.mainContent, `
  <h1>The Ictionary</h1>
  <ul> ${@.transform(words, renderWords)}</ul>
`);
addWord(words, 'Dog', 'A Wolfish Beast');
