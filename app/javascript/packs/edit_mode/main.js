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
        console.log('set');
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
                    afterFanc();
                }
            },
            'html'
        );
    }

    initialFetchSession(sessionInfo){
        tObj.log.sessionKeyArray = sessionInfo.session_keys
        tObj.setSessionInfo(sessionInfo.session_info)
        
    }

    createEdit(url, func, mainId = 'main', formId = 'form') {
        $.get(url + '.html', {token: tObj.log.token},
            function (data){
                // console.log(data); //たまに使うので残しておく
                $('#sub').height('');
                $('#root').height('');
                $('#' + mainId).html(data);
                const form = document.getElementById(formId);
                form.addEventListener('submit', function(event){
                    event.preventDefault();
                    const formData  = new FormData(form);
                    var formObject = {};
                    formData.forEach(function(value, key){
                        formObject[key] = value;
                    });
                    formObject.token = tObj.log.token
                    $.post($('#' + formId).attr('action') + '.json', formObject,
                        function(data){
                            switch (data.type){
                                case 'title':
                                    tObj.selectedTitle(data.id);
                                case 'chapter':
                                    tObj.setChapter(data.id);
                                case 'story':
                                    tObj.setStory(data.id);
                            }
                        },
                        'json'
                    );
                });
                if (func != null){
                    func();
                }
                tObj.restSize();
            },
            'html'
        );
    }
}