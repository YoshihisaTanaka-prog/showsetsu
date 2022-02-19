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

Rails.start()
ActiveStorage.start()

tObj = function(...args){
    for(let clss of args) {
        const inst = new clss();
        for(const funcName of Object.getOwnPropertyNames(clss.prototype)){
            if (funcName != 'constructor') {
                tObj[funcName] = inst[funcName];
            };
        }
    }
    tObj.session = {};
    tObj.sessionKeyArray = {};
}
tObj(Main, Chapter, Character, Step, Story, Synopsis, Title);

window.onload = function(){
    tObj.initialFetchSession(gon);
}
