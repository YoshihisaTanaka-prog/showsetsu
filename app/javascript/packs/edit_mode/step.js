export default class Step {
    setStepAction(){
        $('.edit-step').on("click", function(){});
        $('.delete-step').on("click", function(){});
        $('.new-step').on("click", function(){
            // tObj.loadHtmlCode({step: 0},function(){});
            console.log('clicked');
            tObj.createEdit('/steps/new','body-main', 'step-form');
        });
    }
}