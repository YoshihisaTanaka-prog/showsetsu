function createEditTitle(url) {
    $.get(url, {},
        function (data){
            function sendData() {
                const XHR = new XMLHttpRequest();
                const FD  = new FormData(form);
                XHR.addEventListener("load", function(event) {
                    setInitialMain();
                });
                XHR.addEventListener("error", function(event) {
                    alert('Oups! Something goes wrong.');
                });
                XHR.open("POST", $('#form').attr('action'));
                XHR.send(FD)
            }
            $('#main').html(data);
            const form = document.getElementById('form');
            form.addEventListener('submit', function(event){
                event.preventDefault();
                sendData();
            });
            $('#main').append("<a id='top'>戻る</a>");
            $('#top').on('click', function(){
                setInitialMain();
            });
        },
        'html'
    );
}

function createEditChapter(url) {
    $.get(url, {},
        function (data){
            function sendData() {
                const XHR = new XMLHttpRequest();
                const FD  = new FormData(form);
                XHR.addEventListener("load", function(event) {
                    setInitialMain();
                });
                XHR.addEventListener("error", function(event) {
                    alert('Oups! Something goes wrong.');
                });
                XHR.open("POST", $('#form').attr('action'));
                XHR.send(FD)
            }
            $('#main').html(data);
            const form = document.getElementById('form');
            form.addEventListener('submit', function(event){
                event.preventDefault();
                sendData();
            });
            $('#main').append("<a id='top'>戻る</a>");
            $('#top').on('click', function(){
                selectedTitle(window.sessionStorage.getItem(['title']));
            });
        },
        'html'
    );
}

function setMain(){}

function setPosition(positionId){}

function setStory(){}

function setCharacter(){}

function selectedTitle(titleId){
    $.get('/chapters.json', {title_id: titleId}, 
        function(data){
            window.sessionStorage.setItem(['title'],[titleId]);
            $("#main").html("<a class='go-to-main-link'>タイトル選択に戻る</a><h2>" + data.title.title + "</h2>");
            $('.go-to-main-link').on('click', function(){
                window.sessionStorage.setItem(['title'],[]);
                setInitialMain();
            });
            var code = "<h3>章・話</h3>";
            var i = 1;
            for(var item of data.chapters){
                code += "<a class='position-link' id='" + item.id + "'>第" + i + "章　"+ item.title + "</a><br>";
                i += 1;
            }
            code += "<a id='new-chapter'>新規作成</a>";
            $("#position").html(code);
            $('.position-link').on('click', function(){
                var positionId = Number($(this).attr('id'));
                setPosition(positionId);
            });
            $("#story-memo").html("<h3>あらすじメモ</h3>");
            $("#character-memo").html("<h3>キャラクターメモ</h3>");
            $("#new-chapter").on("click", function(){
                createEditChapter('/chapters/new')
            });
        },
        'json'
    );
}

function setInitialMain(){
    $.get('/titles.json', {},
        function(data){
            var code = "<table>";
            for(var item of data.data){
                code += "<tr><td><a class='main-link' id='" + item.id + "'>"+ item.title + "</a></td>";
                code += "<td><a class='edit-title' id='" + item.id + "'>Edit</a></td>";
                code += "<td><a class='delete-title' id='" + item.id + "'>Destroy</a></td></tr>";
            }
            code += "<tr><td colspan='3' align='center'><a id='new-title'>新規作成</a></td></tr></table>";
            $("#main").html(code);
            $("#position").html("<h3>章・話</h3>");
            $("#story-memo").html("<h3>あらすじメモ</h3>");
            $("#character-memo").html("<h3>キャラクターメモ</h3>");
            $('.main-link').on('click', function(){
                var titleId = $(this).attr('id');
                selectedTitle(titleId);
            });
            $('.edit-title').on('click', function(){
                var titleId = $(this).attr('id');
                createEditTitle('/titles/' + titleId + '/edit');
            });
            $('.delete-title').on('click', function(){
                if (window.confirm('Are you sure you want to delete?')) {
                    var titleId = $(this).attr('id');
                    $.ajax({
                        url: '/titles/' + titleId,
                        type: 'POST',
                        data: {'_method': 'DELETE'} // DELETE リクエストだよ！と教えてあげる。
                    })
                    .done(function() {
                        setInitialMain();
                    })

                    .fail(function() {
                        alert('エラー');
                    });
                }
            });
            $('#new-title').on('click', function(){
                createEditTitle('/titles/new');
            });
        },
        'json'
    );
}

window.onload = function(){
    let titleId = gon.title
    if (titleId == null) {
        setInitialMain();
    } else {
        selectedTitle(titleId)
    }
}
