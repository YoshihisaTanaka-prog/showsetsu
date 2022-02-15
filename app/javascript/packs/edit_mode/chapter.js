export default class Chapter {
    createChapter() {
        tObj.createEdit('chapters/new',
            function(){
                $('#main').append("<a id='top'>戻る</a>");
                $('#top').on('click', function(){
                    tObj.selectedTitle(window.sessionStorage.getItem(['title']));
                });
                tObj.fetchSession({chapter: 0});
            }
        );
    }

    editChapter(chapterId) {
        tObj.createEdit('chapters/' + chapterId + '/edit',
            function(){
                tObj.fetchSession({chapter: chapterId})
            },
            'edit-chapter'
        );
    }

    setChapter(chapterId){
        $.get('/chapters/' + chapterId, {token: tObj.log.token},
            function(data){
                tObj.fetchSession({chapter: data.chapter.id, story: '', synopsis: '', character: ''}, function(){
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
                        tObj.setChapter(chapterId);
                    });
                    $('#new-chapter').on('click', function(){
                        tObj.createChapter();
                    });
                    $('#new-story').on('click', function(){
                        tObj.createStory('/stories/new');
                    });
                    $('.story-link').on('click', function(){
                        const storyInfo = $(this).attr('id').split('-');
                        const storyId = storyInfo[0];
                        const storyNum = storyInfo[1];
                        tObj.editStory(storyId, storyNum);
                    });
                    code = "";
                    code += "<a class='go-to-main-link'>タイトル選択に戻る</a><h2>" + data.title.title + "　第" + chapterNum + "章　" + data.chapter.title + "</h2><div id='edit-chapter'></div><hr><div id='story-head'></div><div id='story'></div>";
                    $("#main").html(code);
                    $('.go-to-main-link').on('click', function(){
                        tObj.setInitialMain();
                    });
                    tObj.editChapter(data.chapter.id, data.title.id);
                });
            },
            'json'
        );
    }
}
