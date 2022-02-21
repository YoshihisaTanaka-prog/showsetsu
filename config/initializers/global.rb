class Grobal
    def loop_session_keys
        return [
            'title',
            'chapter',
            'story',
            'character',
            'synopsis',
        ]
    end
    
    def non_loop_session_keys 
        return [
            'design',
            'step',
        ]
    end
end