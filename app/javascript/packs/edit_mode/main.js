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
            if (tObj.log.sessionKeyArray.includes(key)) {
                if (sessionInfo[key] == null) {
                    tObj.log[key] = '';
                } else {
                    tObj.log[key] = sessionInfo[key];   
                }
            }
        }
    }

    fetchSession(sessionInfo, afterFanc){
        tObj.setSessionInfo(sessionInfo);
        function getsessionObject(key){
            const ret = {};
            ret[key] = tObj.log[key];
            return ret;
        }
        var parameterObject = {};
        for (const key of tObj.log.sessionKeyArray){
            Object.assign(parameterObject, getsessionObject(key));
        }
        $.post('/fetch-work-session', parameterObject,
            function(data){
                tObj.setSessionInfo(JSON.parse(data));
                if (afterFanc != null) {
                    afterFanc(JSON.parse(data));
                }
            },
            'html'
        );
    }

    initialFetchSession(sessionInfo){
        tObj.log.sessionKeyArray = sessionInfo.session_keys
        tObj.setSessionInfo(sessionInfo.session_info)
        tObj.loadHtmlCode({});
    }

    mixObject(...args){
        var ret = {};
        for(let object of args){
            Object.assign(ret, object);
        }
        return ret;
    }

    loadHtmlCode({params: params = {}, sessionInfo: sessionInfo = {}, afterFunc: afterFunc = function(){}}){
        tObj.fetchSession(sessionInfo, function(data1){
            console.log(data1);
            $.post('/tops.json', tObj.mixObject(data1, params), function(data2){
                const order = data2.order;
                const code = data2.code;
                const session = data2.session;
                tObj.setSessionInfo(session);
                console.log(code);
                for (var key of order){
                    $('#' + key).html(code[key]);
                }
                if (data1.step != null) {
                    tObj.setStepAction();
                } else {
                    
                }
                if (afterFunc != null) {
                    afterFunc();
                }
            }, 'json');
        });
    }

    createEdit({url: url, afterLoadedFunc: afterLoadedFunc = function(){}, afetrTappedFunc: afetrTappedFunc = function(){}, mainId: mainId = 'main', formId: formId = 'form', sessionInfo: sessionInfo = {}}) {
        tObj.fetchSession(sessionInfo, function(){
            $.post('/tops.json', {uri: url, key: mainId},
                function (data){
                    const dataObject = JSON.parse(data);
                    console.log(dataObject); //たまに使うので残しておく
                    const order = dataObject.order;
                    const code = dataObject.code;
                    const session = data.session;
                    tObj.setSessionInfo(session);
                    for (var key of order){
                        $('#' + key).html(code[key]);
                    }
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
                        const modelsName = ($('#' + formId).attr('action')).split('/')[1];
                        var modelName = '';
                        switch (modelsName) {
                            case 'steps':
                                modelName = 'step';
                                break;
                            default:
                                break;
                        }
                        const parameters = tObj.mixObject({uri: modelName, key: mainId}, formObject);
                        console.log(parameters);
                        $.post('/tops.json', parameters,
                            function(data){
                                // const result = JSON.parse(data);
                                const order = data.order;
                                const code = data.code;
                                const session = data.session;
                                tObj.setSessionInfo(session);
                                console.log(data);
                                for (var key of order){
                                    $('#' + key).html(code[key]);
                                }
                                afetrTappedFunc();
                            },
                            'json'
                        );
                    });
                    afterLoadedFunc();
                    tObj.restSize();
                },
                'html'
            );
        });
    }
}