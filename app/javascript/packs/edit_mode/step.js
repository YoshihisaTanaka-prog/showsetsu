export default class Step {
    setStepAction(){
        $('#set-step').on('click', function(){
            tObj.loadHtmlCode({},{step: -1});
        });
        $('.edit-step').on("click", function(){
            const id = $(this).attr('id');
            tObj.createEdit({url: 'steps/' + id + '/edit', mainId: 'body-main', formId: 'step-form', 
                afterLoadedFunc: function(){
                    $('#body-main').append('<br><br><a class="step-back">戻る</a>');
                    $('.step-back').on('click', function(){
                        tObj.loadHtmlCode({
                            sessionInfo: {step: -1},
                            afterFunc: tObj.setStepAction
                        });
                    });
                },
                afterTappedFunc: tObj.setStepAction
            });
        });
        $('.delete-step').on("click", function(){
            if (confirm('本当に削除しますか？')) {
                const id = $(this).attr('id');
                tObj.loadHtmlCode({
                    params: {uri: 'steps/' + id + '/delete', key: 'body-main'},
                    sessionInfo: {step: -1},
                    afterFanc: tObj.setStepAction
                });
            }
        });
        $('.new-step').on("click", function(){
            console.log('clicked');
            tObj.createEdit({url: 'steps/new', mainId: 'body-main', formId: 'step-form',
                afterLoadedFunc: function(){
                    $('#body-main').append('<br><br><a class="step-back">戻る</a>');
                    $('.step-back').on('click', function(){
                        tObj.loadHtmlCode({
                            sessionInfo: {step: -1},
                            afterFunc: tObj.setStepAction
                        });
                    });
                },
                afterTappedFunc: tObj.setStepAction
            });
        });
        if (tObj.session.step > 0){
            console.log('updated for edit');
            tObj.updatedForm({key: 'body-main', formId: 'step-form',
                afterLoadedFunc: function(){
                    $('#body-main').append('<br><br><a class="step-back">戻る</a>');
                    $('.step-back').on('click', function(){
                        tObj.loadHtmlCode({
                            sessionInfo: {step: -1},
                            afterFanc: tObj.setStepAction
                        });
                    });
                },
                afterTappedFunc: tObj.setStepAction
            });
        }
    }
}