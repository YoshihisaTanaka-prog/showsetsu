import Rails from "@rails/ujs"
// import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

import Main from './main.js'
import Chapter from './chapter.js'
import Character from './character.js'
import Step from './step.js'
import Story from './story.js'
import Synopsis from './synopsis.js'
import Title from './title.js'

tObj.log = {};
tObj.log.sessionKeyArray = {};
tObj(Main, Chapter, Character, Step, Story, Synopsis, Title);

Rails.start()
ActiveStorage.start()

console.log(ActiveStorage);

window.onload = function(){
    tObj.initialFetchSession(gon);
    console.log('aaaaa');
    let titleId = tObj.log.title;
    if (titleId == null || titleId.length == 0) {
        tObj.setInitialMain();
    } else {
        tObj.selectedTitle(titleId);
    }
}
