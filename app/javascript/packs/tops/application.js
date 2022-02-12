import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

import BarMain from './main.js'
import BarChapter from './chapter.js'
import BarCharacter from './character.js'
import BarStep from './step.js'
import BarStory from './story.js'
import BarSynopsis from './synopsis.js'
import BarTitle from './title.js'

Rails.start()
ActiveStorage.start()
