function setMain(){}

function setPosition(positionId){}

function setStory(){}

function setCharacter(){}

function selectedTitle(titleId){
    $.get('/chapters.json', {title_id: titleId}, 
        function(data){
            window.sessionStorage.setItem(['title'],[titleId]);
            $("#main").html("<h2>" + data.title.title + "</h2>");
            var code = "<h3>章・話</h3><a class='position-main-link'>タイトル選択に戻る</a><br>";
            var i = 1;
            for(var item of data.chapters){
                code += "<a class='position-link' id='" + item.id + "'>第" + i + "章　"+ item.title + "</a><br>";
                // alert(item.title);
                i += 1;
            }
            code += "<a href='/chapters/new'>新規作成</a>";
            $("#position").html(code);
            $('.position-link').on('click', function(){
                var positionId = Number($(this).attr('id'));
                setPosition(positionId);
            });
            $('.position-main-link').on('click', function(){
                window.sessionStorage.setItem(['title'],[]);
                setInitialMain();
            });
        },
        'json'
    );
}

function setInitialMain(){
    $.get('/titles.json', {},
        function(data){
            var code = "";
            for(var item of data){
                code += "<a class='main-link' id='" + item.id + "'>"+ item.title + "</a><br><br>";
            }
            code += "<a href='/titles/new'>新規作成</a>";
            $("#main").html(code);
            $("#position").html("<h3>章・話</h3>");
            $("#story-memo").html("<h3>あらすじメモ</h3>");
            $("#character-memo").html("<h3>キャラクターメモ</h3>");
            $('.main-link').on('click', function(){
                var titleId = $(this).attr('id');
                selectedTitle(titleId);
            });
        },
        'json'
    );
}

window.onload = function(){
    let titleId = window.sessionStorage.getItem(['title']);
    // alert(titleId.length);
    if (titleId == undefined || titleId.length == 0) {
        setInitialMain();
    } else {
        selectedTitle(titleId)
    }
}
