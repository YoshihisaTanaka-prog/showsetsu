export default class Main {
    restSize(){
        const rootHeight = document.getElementById('root').getBoundingClientRect().height;
        const subHeight = document.getElementById('sub').getBoundingClientRect().height;
        if (rootHeight > subHeight){
            $('#sub').height('' + rootHeight + 'px');
        } else{
            $('#root').height('' + subHeight + 'px');
        }
    }

    setSessionInfo(sessionInfo){
        for (const key in sessionInfo){
            if (tObj.sessionKeyArray.includes(key)) {
                if (sessionInfo[key] == null) {
                    tObj.session[key] = '';
                } else {
                    tObj.session[key] = sessionInfo[key];   
                }
            }
        }
    }

    initialFetchSession(sessionInfo){
        tObj.sessionKeyArray = sessionInfo.session_keys;
        tObj.setSessionInfo(sessionInfo.session_info);
        console.log(tObj.session);
        if (tObj.session.step_id != null) {
            tObj.loadHtmlCode({afterFunc: tObj.setStepAction});   
        } else if (tObj.session.story_id != null) {
            tObj.loadHtmlCode({});
        }
    }

    mixObject(...args){
        var ret = {};
        for(let object of args){
            Object.assign(ret, object);
        }
        return ret;
    }

    loadHtmlCode({params: params = {}, sessionInfo: sessionInfo = {}, afterFunc: afterFunc = function(){}}){
        tObj.setSessionInfo(sessionInfo);
        $.post('/tops.json', tObj.mixObject(params, tObj.session), function(data2){
            const order = data2.order;
            const code = data2.code;
            const session = data2.session;
            console.log(session);
            tObj.setSessionInfo(session);
            console.log(code);
            for (var key of order){
                $('#' + key).html(code[key]);
            }
            afterFunc();
        }, 'json');
    }

    createEdit({url: url, afterLoadedFunc: afterLoadedFunc = function(){}, afterTappedFunc: afterTappedFunc = function(){}, mainId: mainId = 'main', formId: formId, sessionInfo: sessionInfo = {}}) {
        tObj.loadHtmlCode({params: {uri: url, key: mainId}, sessionInfo: sessionInfo,
            afterFunc: function () {
                tObj.updateForm({key: mainId, formId: formId, afterTappedFunc: afterTappedFunc, afterLoadedFunc: afterLoadedFunc});
            }
        });
    }

    updateForm({key: key, formId: formId, afterLoadedFunc: afterLoadedFunc = function(){}, afterTappedFunc: afterTappedFunc = function(){}}){
        const form = document.getElementById(formId);
        form.addEventListener('submit', function(event){
            event.preventDefault();
            const formData  = new FormData(form);
            var formObject = {};
            formData.forEach(function(value, key){
                if (key != '_method') {
                    formObject[key] = value;
                }
            });
            const modelName = formId.split('-')[0];
            const parameters = tObj.mixObject({uri: modelName, key: key}, formObject);
            console.log(parameters);
            tObj.loadHtmlCode({params: parameters, afterFunc: afterTappedFunc});
        });
        afterLoadedFunc();
    }
}