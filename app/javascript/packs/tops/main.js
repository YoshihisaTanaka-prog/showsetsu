window.onload = function(){
    topsObject.initialFetchSession(gon);
    let titleId = gon.title
    if (titleId == null || titleId.length == 0) {
        topsObject.setInitialMain();
    } else {
        topsObject.selectedTitle(titleId);
    }
}

topsObject.restSize = function(){
    const rootHeight = document.getElementById('root').getBoundingClientRect().height;
    const subHeight = document.getElementById('sub').getBoundingClientRect().height;
    if (rootHeight > subHeight){
        $('#sub').height('' + rootHeight + 'px');
    } else{
        $('#root').height('' + subHeight + 'px');
    }
}

topsObject.getSessionInfo = function(key){
    return window.sessionStorage.getItem([key]);
}

topsObject.fetchSession = function(sessionInfo, afterFanc){
    const sessionKeyArray = ['title','chapter','story','synopsis','character','design'];
    if (sessionInfo.title == '') {
        for (let index = 0; index < 5; index++) {
            window.sessionStorage.setItem([sessionKeyArray[index]],['']);
        }
    } else if (sessionInfo.chapter == ''){
        for (let index = 1; index < 5; index++) {
            window.sessionStorage.setItem([sessionKeyArray[index]],['']);
        }        
    } else {
        for (const key in sessionInfo){
            if (sessionKeyArray.includes(key)){
                window.sessionStorage.setItem([key], [String(sessionInfo[key])]);
            }
        }
    }
    function getsessionObject(key){
        const ret = {};
        ret[key] = topsObject.getSessionInfo([key]);
        return ret;
    }
    var parameterObject = {};
    for (const key of sessionKeyArray){
        Object.assign(parameterObject, getsessionObject(key));
    }
    $.post('/fetch-work-session', parameterObject,
        function(){
            if (afterFanc != null) {
                afterFanc();
            }
        },
        'html'
    );
}

topsObject.initialFetchSession = function(sessionInfo){
    for (const key in sessionInfo){
        if (sessionInfo[key] == null){
            window.sessionStorage.setItem([key], ['']);
        }
        else{
            window.sessionStorage.setItem([key], [String(sessionInfo[key])]);
        }
    }
}

topsObject.createEdit = function(url, func, mainId = 'main', formId = 'form') {
    $.get(url + '.html', {},
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
                console.log(formObject);
                $.post($('#' + formId).attr('action') + '.json', formObject,
                    function(data){
                        switch (data.type){
                            case 'title':
                                topsObject.selectedTitle(data.id);
                            case 'chapter':
                                topsObject.setChapter(data.id);
                            case 'story':
                                topsObject.setStory(data.id);
                        }
                    },
                    'json'
                );
            });
            if (func != null){
                func();
            }
            topsObject.restSize();
        },
        'html'
    );
}

topsObject.createChapter = function() {
    topsObject.createEdit('chapters/new',
        function(){
            $('#main').append("<a id='top'>戻る</a>");
            $('#top').on('click', function(){
                topsObject.selectedTitle(window.sessionStorage.getItem(['title']));
            });
            topsObject.fetchSession({chapter: 0});
        }
    );
}

topsObject.editChapter = function(chapterId) {
    topsObject.createEdit('chapters/' + chapterId + '/edit',
        function(){
            topsObject.fetchSession({chapter: chapterId})
        },
        'edit-chapter'
    );
}

topsObject.createStory = function(){
    topsObject.createEdit('stories/new', function() {
        topsObject.fetchSession({story: 0});
    }, 'story', 'story-form');
}

topsObject.editStory = function(storyId, storyNum){
    topsObject.createEdit('/stories/' + storyId + '/edit',
        function(){
            $('#story-head').html('<h3>第' + storyNum + '話</h3>');
            topsObject.fetchSession({story: storyId});
        },
        'story', 'story-form'
    );
}

topsObject.setChapter = function(chapterId){
    $.get('/chapters/' + chapterId + '.json', {},
        function(data){
            topsObject.fetchSession({chapter: data.chapter.id, story: '', synopsis: '', character: ''}, function(){
                var code = "<h3>章・話</h3>";
                var chapterNum = 0;
                var chapterIndex = 1;
                for(var chapterItem of data.chapters){
                    code += "<a class='chapter-link' id='" + chapterItem.id + "'>第" + chapterIndex + "章　"+ chapterItem.title + "</a><br>";
                    var storyIndex = 0;
                    if (chapterItem.id == data.chapter.id) {
                        chapterNum = chapterIndex;
                        code += "<div>";
                        for(var storyItem of data.stories){
                            code += "　<a class='story-link' id='" + storyItem.id + "-" + (chapterItem.first_story_num + storyIndex) + "'>第" + (chapterItem.first_story_num + storyIndex) + "話　" + storyItem.title + "</a><br>";
                            storyIndex += 1;
                        }
                        code += "　<a id='new-story'>話を追加</a>";
                        code += "</div>";
                    }
                    chapterIndex += 1;
                }
                code += "<a id='new-chapter'>新章追加</a>";
                $("#position").html(code);
                $('.chapter-link').on('click', function(){
                    const chapterId = $(this).attr('id');
                    topsObject.setChapter(chapterId);
                });
                $('#new-chapter').on('click', function(){
                    topsObject.createChapter();
                });
                $('#new-story').on('click', function(){
                    topsObject.createStory('/stories/new');
                });
                $('.story-link').on('click', function(){
                    const storyInfo = $(this).attr('id').split('-');
                    const storyId = storyInfo[0];
                    const storyNum = storyInfo[1];
                    topsObject.editStory(storyId, storyNum);
                });
                code = "";
                code += "<a class='go-to-main-link'>タイトル選択に戻る</a><h2>" + data.title.title + "　第" + chapterNum + "章　" + data.chapter.title + "</h2><div id='edit-chapter'></div><hr><div id='story-head'></div><div id='story'></div>";
                $("#main").html(code);
                $('.go-to-main-link').on('click', function(){
                    topsObject.setInitialMain();
                });
                topsObject.editChapter(data.chapter.id, data.title.id);
            });
        },
        'json'
    );
}

topsObject.setStory = function(storyId){
    $.get('/stories/' + storyId + '.json', {},
        function(data){
            topsObject.fetchSession({story: storyId}, function(){
                console.log(data);
            });
            console.log(data);
        }, 'json'
    );
}

topsObject.setCharacter = function(){}

