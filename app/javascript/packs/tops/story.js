tObj.createStory = function(){
    tObj.createEdit('stories/new', function() {
        tObj.fetchSession({story: 0});
    }, 'story', 'story-form');
}

tObj.editStory = function(storyId, storyNum){
    tObj.createEdit('/stories/' + storyId + '/edit',
        function(){
            $('#story-head').html('<h3>第' + storyNum + '話</h3>');
            tObj.fetchSession({story: storyId});
        },
        'story', 'story-form'
    );
}

tObj.setStory = function(storyId){
    $.get('/stories/' + storyId + '/edit', {token: tObj.log.token},
        function(data){
            tObj.fetchSession({story: storyId}, function(){
                // console.log(data);
            });
        }, 'json'
    );
}