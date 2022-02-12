tObj.createTitle = function() {
    tObj.createEdit('/titles/new',
        function(){
            $('#main').append("<a id='top'>戻る</a>");
            $('#top').on('click', function(){
                tObj.setInitialMain();
            });
        }
    );
}

tObj.editTitle = function(titleId) {
    tObj.createEdit('/titles/' + titleId + '/edit', null, 'title');
}


tObj.selectedTitle = function(titleId){
    $.get('/chapters.json', {title_id: titleId, token: tObj.log.token}, 
        function(data){
            tObj.fetchSession({title: titleId}, function(){
                $('#sub').height('');
                $('#root').height('');
                $("#main").html("<a class='go-to-main-link'>タイトル選択に戻る</a><h2>" + data.title.title + "</h2><div id='title'></div>");
                $('.go-to-main-link').on('click', function(){
                    tObj.setInitialMain();
                });
                tObj.editTitle(titleId);
                var code = "<h3>章・話</h3>";
                var i = 1;
                for(var item of data.chapters){
                    code += "<a class='chapter-link' id='" + item.id + "'>第" + i + "章　"+ item.title + "</a><br>";
                    i += 1;
                }
                code += "<a id='new-chapter'>新章作成</a>";
                $("#position").html(code);
                $('.chapter-link').on('click', function(){
                    var chapterId = Number($(this).attr('id'));
                    tObj.setChapter(chapterId);
                });
                $("#story-memo").html("<h3>あらすじメモ</h3>");
                $("#character-memo").html("<h3>キャラクターメモ</h3>");
                $("#new-chapter").on("click", function(){
                    tObj.createChapter('/chapters/new')
                });
                tObj.restSize();
            });
        },
        'json'
    );
}

tObj.setInitialMain = function (){
    $.get('/titles.json', {token: tObj.log.token},
        function(data){
            tObj.fetchSession({title: ''}, function(){
                $('#sub').height('');
                $('#root').height('');
                var code = "<table>";
                for(var item of data.data){
                    code += "<tr><td><a class='main-link' id='" + item.id + "'>"+ item.title + "</a></td>";
                    code += "<td><a class='delete-title' id='" + item.id + "'>Destroy</a></td></tr>";
                }
                code += "<tr><td colspan='3' align='center'><a id='new-title'>新規作成</a></td></tr></table><div id='title></div>";
                $("#main").html(code);
                $("#position").html("<h3>章・話</h3>");
                $("#story-memo").html("<h3>あらすじメモ</h3>");
                $("#character-memo").html("<h3>キャラクターメモ</h3>");
                $('.main-link').on('click', function(){
                    const titleId = $(this).attr('id');
                    tObj.selectedTitle(titleId);
                });
                $('.delete-title').on('click', function(){
                    if (window.confirm('Are you sure you want to delete?')) {
                        const titleId = $(this).attr('id');
                        $.post('/titles/' + titleId, {_method : 'DELETE'},
                            function(){
                                tObj.setInitialMain();
                            }
                        ), 'html'
                    }
                });
                $('#new-title').on('click', function(){
                    tObj.createTitle();
                });
                tObj.restSize();
            });
        },
        'json'
    );
}